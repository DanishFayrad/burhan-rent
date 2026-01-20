import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/car.dart';
import '../models/customer.dart';
import '../models/rental.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class RentalDetailScreen extends StatefulWidget {
  const RentalDetailScreen({super.key});

  @override
  State<RentalDetailScreen> createState() => _RentalDetailScreenState();
}

class _RentalDetailScreenState extends State<RentalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final rentalId = ModalRoute.of(context)?.settings.arguments as String?;
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    if (rentalId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rental Detail')),
        body: const Center(child: Text('No rental selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.cardColor,
                  title: const Text(
                    'Delete Rental?',
                    style: TextStyle(color: Colors.black),
                  ),
                  content: const Text(
                    'Are you sure you want to delete this rental record? This cannot be undone.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: AppTheme.accentRed),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await firestore.deleteRental(rentalId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rental deleted successfully'),
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Rental?>(
        future: firestore.getRental(rentalId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rental = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rental Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Car?>(
                  future: firestore.getCar(rental.carId),
                  builder: (context, carSnapshot) {
                    final car = carSnapshot.data;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Car Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (car != null) ...[
                            if (car.imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  car.imageUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.directions_car,
                                    size: 64,
                                    color: Colors.white24,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            _DetailRow('Name', car.name),
                            _DetailRow('Registration', car.registrationNumber),
                            _DetailRow(
                              'Price/Day',
                              '\$${car.rentPricePerDay.toStringAsFixed(2)}',
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                FutureBuilder<Customer?>(
                  future: firestore.getCustomer(rental.customerId),
                  builder: (context, custSnapshot) {
                    final customer = custSnapshot.data;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Customer Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              if (customer != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: AppTheme.accentRed,
                                  ),
                                  tooltip: 'Delete Customer',
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: AppTheme.cardColor,
                                        title: const Text(
                                          'Delete Customer?',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        content: const Text(
                                          'Are you sure you want to delete this customer? This action cannot be undone.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text(
                                              'Delete Customer',
                                              style: TextStyle(
                                                color: AppTheme.accentRed,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true) {
                                      await firestore.deleteCustomer(
                                        customer.id,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Customer deleted successfully',
                                            ),
                                          ),
                                        );
                                        // Might need to refresh UI or pop
                                        setState(
                                          () {},
                                        ); // Refresh to show null/deleted state
                                      }
                                    }
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (customer != null) ...[
                            if (customer.photoUrl != null)
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    customer.photoUrl!,
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              Center(
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white24,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            _DetailRow('Name', customer.fullName),
                            _DetailRow('Phone', customer.phoneNumber),
                            _DetailRow('ID', customer.idNumber),
                            _DetailRow('Address', customer.address),
                          ] else
                            const Text(
                              'Customer data not found',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rental Schedule',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        'Start Date',
                        DateFormat('yyyy-MM-dd').format(rental.startAt),
                      ),
                      _DetailRow(
                        'Duration',
                        '${rental.durationHours ~/ 24} days',
                      ),
                      _DetailRow(
                        'Total Hours',
                        '${rental.durationHours} hours',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Return Car'),
                          content: const Text('Mark this rental as completed?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Return'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await firestore.setCarAvailable(rental.carId, true);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Car returned successfully!'),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Return Car'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
