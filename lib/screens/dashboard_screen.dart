import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/car.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('BURHAN RENT', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.accentRed),
            onPressed: () async {
              await auth.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.primaryDarkGrey,
                ),
              ),
            ),

            // Active Cars Carousel Section
            SizedBox(
              height: 320,
              child: StreamBuilder<List<Car>>(
                stream: firestore.carsStream(), // Reuse existing stream
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final cars = snapshot.data ?? [];
                  final activeCars = cars.where((c) => c.available).toList();

                  if (activeCars.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Center(
                        child: Text(
                          'No Active Cars Available',
                          style: TextStyle(color: AppTheme.primaryDarkGrey),
                        ),
                      ),
                    );
                  }

                  return PageView.builder(
                    controller: PageController(viewportFraction: 0.85),
                    itemCount: activeCars.length,
                    itemBuilder: (context, index) {
                      final car = activeCars[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Car Image
                            car.imageUrl != null
                                ? Image.network(
                                    ImageHelper.fixImageUrl(car.imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[900],
                                    child: const Icon(
                                      Icons.directions_car,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  ),

                            // Gradient Overlay
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black87],
                                  stops: [0.5, 1.0],
                                ),
                              ),
                            ),

                            // Car Info
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    car.name,
                                    style: const TextStyle(
                                      color: Colors
                                          .white, // Keep white on image overlay
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${car.rentPricePerDay} / day',
                                    style: const TextStyle(
                                      color: AppTheme.accentGold,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
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
              ),
            ),

            const SizedBox(height: 32),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryDarkGrey,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reusing Quick Action Buttons with new styling needs refactor in _QuickActionButton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _QuickActionButton(
                    label: 'Car List',
                    icon: Icons.list_alt,
                    color: Colors.black,
                    onPressed: () => Navigator.pushNamed(context, '/cars'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    label: 'Add New Car',
                    icon: Icons.add_circle_outline,
                    color: Colors.black,
                    onPressed: () => Navigator.pushNamed(context, '/add-car'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    label: 'Manage Rentals',
                    icon: Icons.key,
                    color: Colors.black,
                    onPressed: () =>
                        Navigator.pushNamed(context, '/active-rentals'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    label: 'View Customers',
                    icon: Icons.people_outline,
                    color: Colors.black,
                    onPressed: () => Navigator.pushNamed(context, '/customers'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    label: 'Total Revenue',
                    icon: Icons.analytics_outlined,
                    color: Colors.black,
                    onPressed: () =>
                        Navigator.pushNamed(context, '/total-revenue'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black54,
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          side: BorderSide(color: Colors.black.withOpacity(0.05)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
