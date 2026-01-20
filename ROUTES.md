# Routes & Navigation Reference

## Complete Route Map

| # | Screen | Route | File | Auth Required |
|---|--------|-------|------|---|
| 1 | Splash | (home) | `splash_screen.dart` | ❌ |
| 2 | Login | `/login` | `login_screen.dart` | ❌ |
| 3 | Register | `/register` | `register_screen.dart` | ❌ |
| 4 | Dashboard | `/dashboard` | `dashboard_screen.dart` | ✅ |
| 5 | Car List | `/cars` | `car_list_screen.dart` | ✅ |
| 6 | Add Car | `/add-car` | `car_form_screen.dart` | ✅ |
| 7 | Customer List | `/customers` | `customer_list_screen.dart` | ✅ |
| 8 | Add Customer | `/add-customer` | `add_customer_screen.dart` | ✅ |
| 9 | Rent Car | `/rent-car` | `rental_form_screen.dart` | ✅ |
| 10 | Active Rentals | `/active-rentals` | `active_rentals_screen.dart` | ✅ |
| 11 | Rental Detail | `/rental-detail` | `rental_detail_screen.dart` | ✅ |
| — | History | `/history` | `history_screen.dart` | ✅ |
| — | Customer Profile | `/customer-profile` | `customer_profile_screen.dart` | ✅ |

## Navigation Stack Flow

```
HOME (Auth Router)
├─ No Auth User → Login Screen
│  ├─ Register Button → Register Screen
│  │  └─ Back → Login Screen
│  └─ Login Success → Dashboard
│
└─ Auth User → Dashboard (Home)
   ├─ Add Car Button → Add Car Form → Dashboard
   ├─ View Cars Button → Car List → Dashboard
   ├─ View Customers Button → Customer List
   │  ├─ Add Customer FAB → Add Customer → Customer List
   │  └─ Tap Customer → Customer Profile
   ├─ Active Rentals Button → Active Rentals
   │  ├─ Add Rental FAB → Rent Car Form → Active Rentals
   │  └─ View Details → Rental Detail
   │     ├─ Return Car → Active Rentals
   │     └─ Back → Active Rentals
   ├─ History Button → History Screen → Dashboard
   └─ Logout → Login Screen
```

## Route Arguments

### Routes with Arguments

| Route | Argument | Type | Description |
|-------|----------|------|---|
| `/rental-detail` | rentalId | String | Rental ID from /rentals collection |
| `/customer-profile` | customerId | String | Customer ID from /customers collection |

### Example Navigation with Arguments

```dart
// Navigate to rental detail
Navigator.pushNamed(
  context,
  '/rental-detail',
  arguments: rental.id,
);

// Retrieve in destination screen
final rentalId = ModalRoute.of(context)?.settings.arguments as String?;
```

## Main App Router

```dart
// In main.dart
class _HomeRouter extends StatelessWidget {
  const _HomeRouter();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return StreamBuilder<dynamic>(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();  // Loading state
        }

        if (snapshot.hasData) {
          return const DashboardScreen();  // Authenticated
        }

        return const LoginScreen();  // Not authenticated
      },
    );
  }
}
```

## Material Routes Defined

```dart
// In main.dart MaterialApp
routes: {
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
}
```

## Common Navigation Patterns

### Push (New Screen)
```dart
Navigator.pushNamed(context, '/add-car');
```

### Pop (Go Back)
```dart
Navigator.pop(context);
```

### Push with Arguments
```dart
Navigator.pushNamed(
  context,
  '/rental-detail',
  arguments: rental.id,
);
```

### Push Replacement (Clear Previous)
```dart
Navigator.pushReplacementNamed(context, '/dashboard');
```

### Pop Until (Go Back to Specific Screen)
```dart
Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
```

## Screen-Specific Features

### Dashboard
- Logout in AppBar
- Navigation to all major features
- Real-time stats (Firestore streams)

### Car List
- Grid view with FAB to add car
- Real-time car updates
- Availability badges

### Customer List
- Search/filter by name or phone
- FAB to add customer
- Tap to view profile

### Active Rentals
- Real-time rental list
- Tap to view rental details
- FAB to create new rental

### Rental Detail
- Full rental + customer + car info
- Return car button
- Confirmation dialog

### History
- Filter by car name or customer
- All-time rental list
- Read-only view

## Best Practices

1. **Always use named routes** – Easier to maintain
2. **Pop instead of navigate** – When going back to previous screen
3. **Use arguments for IDs** – Don't pass entire objects
4. **Handle null arguments** – Check if route argument exists
5. **Use replacement for auth** – `pushReplacementNamed` when user logs out
6. **StreamBuilder for auth** – Automatically route based on auth state

## Testing Routes

To test all routes work correctly:

```bash
# Start app
flutter run

# Test each route in order:
# 1. Splash → Login (auto 3s)
# 2. Login → Register → back → Login
# 3. Login → Dashboard (after auth)
# 4. Dashboard → All other screens
```

---

All routes are type-safe and follow Flutter Material design conventions.
