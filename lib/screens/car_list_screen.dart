import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/car.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'car_form_screen.dart';
import 'rental_form_screen.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  // Key to force StreamBuilder rebuild
  Key _streamKey = UniqueKey();

  void _refreshList() {
    setState(() {
      _streamKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Cars',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textBlack,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshList,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Seed Data',
            onPressed: () => _seedData(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Car>>(
        key: _streamKey,
        stream: firestore.carsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final cars = snapshot.data!;
          if (cars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No cars added yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a new car',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return _CarCard(car: car, onDeleted: _refreshList);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-car');
          _refreshList();
        },
        backgroundColor: AppTheme.accentRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _seedData(BuildContext context) async {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    final cars = [
      {
        'name': 'Suzuki Wagon R',
        'registration_number': 'ABC-123',
        'rent_price_per_day': 3000,
        'available': true,
        'image_url':
            'https://images.unsplash.com/photo-1542362567-b07e54358753?q=80&w=600&auto=format&fit=crop',
        'transmission': 'Manual',
        'seating_capacity': 4,
        'fuel_type': 'Petrol',
      },
      {
        'name': 'Suzuki Cultus',
        'registration_number': 'XYZ-789',
        'rent_price_per_day': 4000,
        'available': true,
        'image_url':
            'https://images.unsplash.com/photo-1583121274602-3e2820c69888?q=80&w=600&auto=format&fit=crop',
        'transmission': 'Automatic',
        'seating_capacity': 5,
        'fuel_type': 'Petrol',
      },
      {
        'name': 'Suzuki Alto',
        'registration_number': 'LMN-456',
        'rent_price_per_day': 2500,
        'available': true,
        'image_url':
            'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=600&auto=format&fit=crop',
        'transmission': 'Manual',
        'seating_capacity': 4,
        'fuel_type': 'Petrol',
      },
      {
        'name': 'Honda City',
        'registration_number': 'ICT-999',
        'rent_price_per_day': 6000,
        'available': true,
        'image_url':
            'https://images.unsplash.com/photo-1619682817481-e994891cd1f5?q=80&w=600&auto=format&fit=crop',
        'transmission': 'Automatic',
        'seating_capacity': 5,
        'fuel_type': 'Petrol',
      },
      {
        'name': 'Honda Civic',
        'registration_number': 'LHR-555',
        'rent_price_per_day': 8000,
        'available': true,
        'image_url':
            'https://images.unsplash.com/photo-1623969270319-3a0562854911?q=80&w=600&auto=format&fit=crop',
        'transmission': 'Automatic',
        'seating_capacity': 5,
        'fuel_type': 'Petrol',
      },
      {
        'name': 'Toyota Prado',
        'registration_number': 'BF-2022',
        'rent_price_per_day': 25000,
        'available': true,
        'image_url':
            'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=600&auto=format&fit=crop',
        'transmission': 'Automatic',
        'seating_capacity': 7,
        'fuel_type': 'Diesel',
      },
      {
        'name': 'Toyota Land Cruiser',
        'registration_number': 'V8-2023',
        'rent_price_per_day': 35000,
        'available': true,
        'image_url':
            'https://images.unsplash.com/photo-1594502184342-28efcb0a5748?q=80&w=600&auto=format&fit=crop',
        'transmission': 'Automatic',
        'seating_capacity': 7,
        'fuel_type': 'Petrol',
      },
      {
        'name': 'Audi A6',
        'registration_number': 'AUD-001',
        'rent_price_per_day': 40000,
        'available': true,
        'image_url':
            'https://images.unsplash.com/photo-1603584173870-7b2310d65dbc?q=80&w=600&auto=format&fit=crop',
        'transmission': 'Automatic',
        'seating_capacity': 5,
        'fuel_type': 'Petrol',
      },
      {
        'name': 'Mercedes-Benz C-Class',
        'registration_number': 'BENZ-99',
        'rent_price_per_day': 45000,
        'available': true,
        'image_url':
            'https://images.unsplash.com/photo-1617788138017-80ad40651399?q=80&w=600&auto=format&fit=crop',
        'transmission': 'Automatic',
        'seating_capacity': 5,
        'fuel_type': 'Petrol',
      },
      {
        'name': 'Toyota Fortuner',
        'registration_number': 'FOR-111',
        'rent_price_per_day': 28000,
        'available': true,
        'image_url':
            'https://images.unsplash.com/photo-1503376763036-066120622c74?q=80&w=600&auto=format&fit=crop',
        'transmission': 'Automatic',
        'seating_capacity': 7,
        'fuel_type': 'Diesel',
      },
    ];

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Seeding 10 cars...')));

    for (final car in cars) {
      car['created_at'] = DateTime.now().toIso8601String();
      await firestore.addCar(car);
    }

    _refreshList();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data seeding complete!')));
  }
}

class _CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onDeleted;

  const _CarCard({required this.car, required this.onDeleted});

  void _showOptionsMenu(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit, color: AppTheme.accentBlue),
                ),
                title: const Text('Edit Car'),
                subtitle: const Text('Modify car details'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarFormScreen(car: car),
                    ),
                  ).then((_) => onDeleted()); // Refresh after edit
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.car_rental,
                    color: AppTheme.accentGreen,
                  ),
                ),
                title: const Text('Rent This Car'),
                subtitle: Text(
                  car.available
                      ? 'Create a new rental'
                      : 'Car is not available',
                ),
                enabled: car.available,
                onTap: car.available
                    ? () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RentalFormScreen(carId: car.id),
                          ),
                        );
                      }
                    : null,
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: AppTheme.accentRed),
                ),
                title: const Text(
                  'Delete Car',
                  style: TextStyle(color: AppTheme.accentRed),
                ),
                subtitle: const Text('Permanently remove this car'),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, firestore);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FirestoreService firestore) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.accentRed),
            SizedBox(width: 8),
            Text('Delete Car'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${car.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await firestore.deleteCar(car.id);
                // Call refresh callback immediately after deletion
                onDeleted();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${car.name} deleted'),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.accentRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptionsMenu(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Car Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  car.imageUrl != null
                      ? Image.network(
                          ImageHelper.fixImageUrl(car.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildCarPlaceholder();
                          },
                        )
                      : _buildCarPlaceholder(),

                  // Availability Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: car.available
                            ? AppTheme.accentGreen.withOpacity(0.9)
                            : AppTheme.accentRed.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        car.available ? 'Available' : 'Rented',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Options icon
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Car Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      car.registrationNumber,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.settings, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          car.transmission,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.local_gas_station,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          car.fuelType,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PKR ${car.rentPricePerDay.toStringAsFixed(0)}/day',
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.directions_car, size: 40, color: Colors.grey),
      ),
    );
  }
}
