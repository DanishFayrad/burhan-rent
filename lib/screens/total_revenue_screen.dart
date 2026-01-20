import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/car.dart';
import '../models/rental.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class TotalRevenueScreen extends StatefulWidget {
  const TotalRevenueScreen({super.key});

  @override
  State<TotalRevenueScreen> createState() => _TotalRevenueScreenState();
}

class _TotalRevenueScreenState extends State<TotalRevenueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Total Revenue',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textBlack,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accentRed,
          unselectedLabelColor: AppTheme.textMediumGrey,
          indicatorColor: AppTheme.accentRed,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'By Car', icon: Icon(Icons.directions_car)),
            Tab(text: 'By Date', icon: Icon(Icons.calendar_today)),
          ],
        ),
      ),
      body: StreamBuilder<List<Rental>>(
        stream: firestore.rentalsStream(),
        builder: (context, rentalSnapshot) {
          if (rentalSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rentals = rentalSnapshot.data ?? [];

          return StreamBuilder<List<Car>>(
            stream: firestore.carsStream(),
            builder: (context, carSnapshot) {
              if (carSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final cars = carSnapshot.data ?? [];
              final carMap = {for (var car in cars) car.id: car};

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildCarWiseSummary(rentals, carMap),
                  _buildDateWiseSummary(rentals, carMap),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCarWiseSummary(List<Rental> rentals, Map<String, Car> carMap) {
    // Group rentals by car
    final Map<String, List<Rental>> carRentals = {};
    for (var rental in rentals) {
      carRentals.putIfAbsent(rental.carId, () => []).add(rental);
    }

    if (carRentals.isEmpty) {
      return _buildEmptyState('No rentals found');
    }

    // Calculate total revenue
    double totalRevenue = 0;
    for (var entry in carRentals.entries) {
      final car = carMap[entry.key];
      if (car != null) {
        for (var rental in entry.value) {
          final days = (rental.durationHours / 24).ceil();
          totalRevenue += car.rentPricePerDay * days;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Revenue Card
          _buildTotalRevenueCard(totalRevenue),
          const SizedBox(height: 24),

          // Section Header
          const Text(
            'Revenue by Car',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBlack,
            ),
          ),
          const SizedBox(height: 16),

          // Car-wise breakdown
          ...carRentals.entries.map((entry) {
            final car = carMap[entry.key];
            final carRentalsList = entry.value;

            if (car == null) return const SizedBox.shrink();

            // Calculate metrics for this car
            int totalDays = 0;
            double carRevenue = 0;
            for (var rental in carRentalsList) {
              final days = (rental.durationHours / 24).ceil();
              totalDays += days;
              carRevenue += car.rentPricePerDay * days;
            }

            return _buildCarRevenueCard(
              car: car,
              rentals: carRentalsList,
              totalDays: totalDays,
              totalRevenue: carRevenue,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDateWiseSummary(List<Rental> rentals, Map<String, Car> carMap) {
    // Group rentals by date
    final Map<String, List<Rental>> dateRentals = {};
    for (var rental in rentals) {
      final dateKey = DateFormat('yyyy-MM-dd').format(rental.startAt);
      dateRentals.putIfAbsent(dateKey, () => []).add(rental);
    }

    if (dateRentals.isEmpty) {
      return _buildEmptyState('No rentals found');
    }

    // Sort by date (newest first)
    final sortedDates = dateRentals.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Calculate total revenue
    double totalRevenue = 0;
    for (var entry in dateRentals.entries) {
      for (var rental in entry.value) {
        final car = carMap[rental.carId];
        if (car != null) {
          final days = (rental.durationHours / 24).ceil();
          totalRevenue += car.rentPricePerDay * days;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Revenue Card
          _buildTotalRevenueCard(totalRevenue),
          const SizedBox(height: 24),

          // Section Header
          const Text(
            'Daily Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBlack,
            ),
          ),
          const SizedBox(height: 16),

          // Date-wise breakdown
          ...sortedDates.map((dateKey) {
            final dateRentalsList = dateRentals[dateKey]!;
            final date = DateTime.parse(dateKey);

            // Calculate metrics for this date
            double dayRevenue = 0;
            List<String> carNames = [];

            for (var rental in dateRentalsList) {
              final car = carMap[rental.carId];
              if (car != null) {
                final days = (rental.durationHours / 24).ceil();
                dayRevenue += car.rentPricePerDay * days;
                if (!carNames.contains(car.name)) {
                  carNames.add(car.name);
                }
              }
            }

            return _buildDateRevenueCard(
              date: date,
              rentals: dateRentalsList,
              carNames: carNames,
              totalRevenue: dayRevenue,
              carMap: carMap,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotalRevenueCard(double totalRevenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accentRed, Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentRed.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Total Revenue',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'PKR ${NumberFormat('#,###').format(totalRevenue)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'From all rentals',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarRevenueCard({
    required Car car,
    required List<Rental> rentals,
    required int totalDays,
    required double totalRevenue,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: car.imageUrl != null
              ? Image.network(
                  ImageHelper.fixImageUrl(car.imageUrl),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildCarPlaceholder();
                  },
                )
              : _buildCarPlaceholder(),
        ),
        title: Text(
          car.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.textBlack,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${rentals.length} rentals • $totalDays days',
              style: const TextStyle(
                color: AppTheme.textMediumGrey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PKR ${NumberFormat('#,###').format(totalRevenue)}',
              style: const TextStyle(
                color: AppTheme.accentGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Rental details
          ...rentals.map((rental) {
            final days = (rental.durationHours / 24).ceil();
            final rentAmount = car.rentPricePerDay * days;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      size: 20,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy').format(rental.startAt),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$days days @ PKR ${NumberFormat('#,###').format(car.rentPricePerDay)}/day',
                          style: const TextStyle(
                            color: AppTheme.textMediumGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'PKR ${NumberFormat('#,###').format(rentAmount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDateRevenueCard({
    required DateTime date,
    required List<Rental> rentals,
    required List<String> carNames,
    required double totalRevenue,
    required Map<String, Car> carMap,
  }) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final isYesterday = DateUtils.isSameDay(
      date,
      DateTime.now().subtract(const Duration(days: 1)),
    );

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = DateFormat('EEEE, MMM dd').format(date);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isToday
                ? AppTheme.accentGreen.withOpacity(0.1)
                : AppTheme.accentBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('dd').format(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isToday ? AppTheme.accentGreen : AppTheme.accentBlue,
                ),
              ),
              Text(
                DateFormat('MMM').format(date),
                style: TextStyle(
                  fontSize: 12,
                  color: isToday ? AppTheme.accentGreen : AppTheme.accentBlue,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          dateLabel,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.textBlack,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${rentals.length} cars rented',
              style: const TextStyle(
                color: AppTheme.textMediumGrey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PKR ${NumberFormat('#,###').format(totalRevenue)}',
              style: const TextStyle(
                color: AppTheme.accentGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Cars rented on this date
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: carNames
                .map(
                  (name) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.accentGold.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 16,
                          color: AppTheme.accentGold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: const TextStyle(
                            color: AppTheme.textBlack,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          // Rental details
          ...rentals.map((rental) {
            final car = carMap[rental.carId];
            if (car == null) return const SizedBox.shrink();

            final days = (rental.durationHours / 24).ceil();
            final rentAmount = car.rentPricePerDay * days;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: car.imageUrl != null
                        ? Image.network(
                            ImageHelper.fixImageUrl(car.imageUrl),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.directions_car,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$days days @ PKR ${NumberFormat('#,###').format(car.rentPricePerDay)}/day',
                          style: const TextStyle(
                            color: AppTheme.textMediumGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'PKR ${NumberFormat('#,###').format(rentAmount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCarPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.directions_car, color: Colors.grey, size: 30),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 18),
          ),
        ],
      ),
    );
  }
}
