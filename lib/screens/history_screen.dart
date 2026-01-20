import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/car.dart';
import '../models/customer.dart';
import '../models/rental.dart';
import '../services/firestore_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _filterCtrl = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _filterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Rental History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _filterCtrl,
              style: const TextStyle(color: Colors.black),
              onChanged: (val) =>
                  setState(() => _filterQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Filter by car or customer',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Rental>>(
              stream: firestore.rentalsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rentals = snapshot.data!;
                if (rentals.isEmpty) {
                  return const Center(child: Text('No rental history'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: rentals.length,
                  itemBuilder: (context, index) {
                    final rental = rentals[index];
                    return _HistoryCard(
                      rental: rental,
                      filterQuery: _filterQuery,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Rental rental;
  final String filterQuery;

  const _HistoryCard({required this.rental, required this.filterQuery});

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        firestore.getCar(rental.carId).then((car) => car),
        firestore.getCustomer(rental.customerId).then((customer) => customer),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final car = snapshot.data![0] as Car?;
        final customer = snapshot.data![1] as Customer?;

        // Apply filter
        if (filterQuery.isNotEmpty) {
          final carMatch =
              car?.name.toLowerCase().contains(filterQuery) ?? false;
          final customerMatch =
              customer?.fullName.toLowerCase().contains(filterQuery) ?? false;
          if (!carMatch && !customerMatch) {
            return const SizedBox.shrink();
          }
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (car != null)
                  Text(
                    '${car.name} (${car.registrationNumber})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 6),
                if (customer != null) Text('Customer: ${customer.fullName}'),
                if (customer != null) Text('Phone: ${customer.phoneNumber}'),
                const SizedBox(height: 8),
                Text(
                  'Rental Date: ${DateFormat('yyyy-MM-dd').format(rental.createdAt)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Duration: ${rental.durationHours ~/ 24} days',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
