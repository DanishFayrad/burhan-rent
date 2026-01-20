import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/active_rentals_screen.dart';
import 'screens/add_customer_screen.dart';
import 'screens/car_form_screen.dart';
import 'screens/car_list_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/customer_profile_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/rental_detail_screen.dart';
import 'screens/rental_form_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/total_revenue_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vjrykbdajcdleyiheozc.supabase.co',
    anonKey: 'sb_publishable_XTY5u0a1Or3fUZgmW7dH-Q_D3T-_oZP',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<StorageService>(create: (_) => StorageService()),
      ],
      child: MaterialApp(
        title: 'Burhan Rent',
        theme: AppTheme.darkTheme,
        home: const SplashScreen(), // Start with Splash
        routes: {
          '/home': (context) => const _HomeRouter(), // Route for Auth Wrapper
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/cars': (context) => const CarListScreen(),
          '/add-car': (context) => const CarFormScreen(),
          '/customers': (context) => const CustomerListScreen(),
          '/add-customer': (context) => const AddCustomerScreen(),
          '/rent-car': (context) => const RentalFormScreen(),
          '/active-rentals': (context) => const ActiveRentalsScreen(),
          '/rental-detail': (context) => const RentalDetailScreen(),
          '/history': (context) => const HistoryScreen(),
          '/customer-profile': (context) => const CustomerProfileScreen(),
          '/total-revenue': (context) => const TotalRevenueScreen(),
        },
      ),
    );
  }
}

class _HomeRouter extends StatelessWidget {
  const _HomeRouter();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
