import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/car.dart';
import '../models/customer.dart';
import '../models/rental.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class CustomerProfileScreen extends StatelessWidget {
  final String? customerId;

  const CustomerProfileScreen({super.key, this.customerId});

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    // In a real app, pass customerId from navigation or provider
    // For now, show a demo or retrieve from arguments
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    final id = customerId ?? args;

    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Profile')),
        body: const Center(child: Text('No customer selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Profile')),
      body: FutureBuilder<Customer?>(
        future: firestore.getCustomer(id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final customer = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Photo
                if (customer.photoUrl != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        customer.photoUrl!,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.2,
                        // fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, size: 80),
                    ),
                  ),
                const SizedBox(height: 20),
                // Customer Details
                Text(
                  'Personal Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _DetailRow('Name', customer.fullName),
                _DetailRow('Phone', customer.phoneNumber),
                _DetailRow('ID Number', customer.idNumber),
                _DetailRow('Address', customer.address),
                const SizedBox(height: 24),
                // Rental History
                Text(
                  'Rental History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Rental>>(
                  future: firestore.getCustomerRentals(id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final rentals = snapshot.data!;
                    if (rentals.isEmpty) {
                      return const Text('No rental history');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rentals.length,
                      itemBuilder: (context, index) {
                        final rental = rentals[index];
                        return FutureBuilder<Car?>(
                          future: firestore.getCar(rental.carId),
                          builder: (context, carSnapshot) {
                            final car = carSnapshot.data;
                            if (car == null) return const SizedBox.shrink();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              clipBehavior: Clip.antiAlias,
                              color: AppTheme.cardColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Car Image
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.2,
                                    child: car.imageUrl != null
                                        ? Image.network(
                                            ImageHelper.fixImageUrl(
                                              car.imageUrl,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.directions_car,
                                              size: 64,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  // Car & Rental Details
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                car.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryAction
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                car.registrationNumber,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryAction,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Specs Row
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.settings,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              car.transmission,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.local_gas_station,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              car.fuelType,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),
                                        // Rental Dates
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.black87,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Rented on: ${DateFormat('MMM dd, yyyy').format(rental.startAt)}',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.timer,
                                              size: 16,
                                              color: Colors.black87,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Duration: ${rental.durationHours ~/ 24} days',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
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
