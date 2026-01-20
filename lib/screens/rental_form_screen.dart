import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/car.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class RentalFormScreen extends StatefulWidget {
  final String? carId;

  const RentalFormScreen({super.key, this.carId});

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();

  String? _selectedCarId;
  DateTime? _startDate;
  int _durationDays = 1;

  @override
  void initState() {
    super.initState();
    _selectedCarId = widget.carId;
  }

  File? _pickedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (file != null) {
      setState(() => _pickedImage = File(file.path));
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedCarId == null ||
        _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final storage = Provider.of<StorageService>(context, listen: false);

    try {
      String? photoUrl;
      final customerId = const Uuid().v4();

      // Upload image if selected
      if (_pickedImage != null) {
        try {
          final path = 'customers/$customerId.jpg';
          photoUrl = await storage
              .uploadFile(_pickedImage!, path)
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () {
                  throw Exception('Image upload timed out');
                },
              );
          print('Image uploaded: $photoUrl');
        } catch (e) {
          print('Image upload error: $e - Using placeholder');
          // Use placeholder/dummy image on upload failure
          photoUrl = 'placeholder_$customerId.jpg';
        }
      } else {
        // No image selected - use default placeholder
        photoUrl = 'no_image.jpg';
        print('No image selected - using placeholder');
      }

      // Save customer
      final customerData = {
        'full_name': _fullNameCtrl.text.trim(),
        'phone_number': _phoneCtrl.text.trim(),
        'id_number': _idCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'photo_url': photoUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      final savedCustomerId = await firestore
          .addCustomer(customerData)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Customer save timed out'),
          );

      print('Customer saved: $savedCustomerId');

      // Mark car as unavailable
      await firestore
          .setCarAvailable(_selectedCarId!, false)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Car update timed out'),
          );

      print('Car marked unavailable');

      // Save rental
      final rentalData = {
        'car_id': _selectedCarId,
        'customer_id': savedCustomerId,
        'start_at': _startDate!.toIso8601String(),
        'duration_hours': _durationDays * 24,
        'created_at': DateTime.now().toIso8601String(),
      };

      await firestore
          .addRental(rentalData)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Rental save timed out'),
          );

      print('Rental saved successfully');

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rental created successfully!'),
            backgroundColor: AppTheme.accentGreen,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back after short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      print('Submit error: $e');

      if (mounted) {
        setState(() => _isLoading = false);

        String errorMessage = 'Error: $e';
        if (e.toString().contains('timed out')) {
          errorMessage = 'Operation timed out. Check your internet connection.';
        } else if (e.toString().contains('Car update') ||
            e.toString().contains('Customer save') ||
            e.toString().contains('Rental save')) {
          errorMessage = 'Failed to save data. Check your internet connection.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.accentRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _idCtrl.dispose();
    _addressCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Rent a Car')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Select Car
              StreamBuilder<List<Car>>(
                stream: firestore.carsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final availableCars = snapshot.data!
                      .where((c) => c.available)
                      .toList();
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCarId,
                    style: const TextStyle(color: Colors.black),
                    hint: const Text('Select a car'),
                    items: availableCars
                        .map(
                          (car) => DropdownMenuItem(
                            value: car.id,
                            child: Text(
                              '${car.name} (${car.registrationNumber})',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCarId = val;
                      });
                    },
                    validator: (v) => v == null ? 'Select a car' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              // Rental duration
              TextFormField(
                controller: _durationCtrl,
                readOnly: true,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Duration: $_durationDays days',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await showDialog<int>(
                        context: context,
                        builder: (context) =>
                            _DurationPicker(initialDays: _durationDays),
                      );
                      if (result != null) {
                        setState(() => _durationDays = result);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Start date
              TextFormField(
                readOnly: true,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Start date',
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: _startDate != null
                      ? DateFormat('yyyy-MM-dd').format(_startDate!)
                      : '',
                ),
                onTap: _selectDate,
                validator: (v) => _startDate == null ? 'Select date' : null,
              ),
              const SizedBox(height: 16),
              // Customer Info
              const Text(
                'Customer Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: _pickedImage != null
                    ? Image.file(_pickedImage!, height: 180, fit: BoxFit.cover)
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        color: Colors.grey[200],
                        child: const Icon(Icons.add_a_photo, size: 48),
                      ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(labelText: 'Phone number'),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'CNIC / ID number',
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryBlack,
                              ),
                            ),
                          )
                        : Text(
                            'Complete Rental',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  color: AppTheme.primaryBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationPicker extends StatefulWidget {
  final int initialDays;
  const _DurationPicker({required this.initialDays});

  @override
  State<_DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<_DurationPicker> {
  late int _days;

  @override
  void initState() {
    super.initState();
    _days = widget.initialDays;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Duration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_days days',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _days.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '$_days days',
            onChanged: (val) => setState(() => _days = val.toInt()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _days),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
