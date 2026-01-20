# Burhan Rent – Car Rental Management App

A full-featured Flutter mobile app for managing car rentals with real-time database, image uploads, and customer tracking.

## Quick Start

### Prerequisites
- Flutter 3.10.3+
- Firebase project (free tier OK)
- macOS, iOS, or Android device/emulator

### Setup (2 minutes)

1. **Clone & Install:**
   ```bash
   cd /Users/macbook/Desktop/burhan_rent_admin
   flutter pub get
   ```

2. **Firebase Setup:** See [README_FIREBASE_SETUP.md](README_FIREBASE_SETUP.md)
   - Create Firebase project
   - Download `google-services.json` (Android) & `GoogleService-Info.plist` (iOS)
   - Place in correct directories

3. **Run:**
   ```bash
   flutter run
   ```

## Features

### 🚗 Car Management
- Add cars with photos, model, registration number, and daily rental price
- View cars in grid/list with availability status
- Real-time updates via Firestore streams

### 🔐 Customer & Rental Tracking
- Create rental records with customer details
- Upload customer photos for identification
- Automatic car availability updates (rented ↔ available)
- View complete rental history per customer

### 📸 Image Upload
- Upload car photos during car creation
- Upload customer profile photos
- Images stored in Firebase Storage with CDN URLs

### 📱 User Interface
- Material Design 3
- Intuitive forms with validation
- Date/time pickers for rental scheduling
- Profile screens with rental history

## Architecture

**State Management:** Provider (services + dependency injection)  
**Database:** Firestore (documents, real-time streams)  
**Storage:** Firebase Storage  
**UI:** Material 3 design system  

## File Structure

```
lib/
├── main.dart                          # App entry, Firebase init, routes
├── models/                            # Data models
│   ├── car.dart
│   ├── customer.dart
│   └── rental.dart
├── services/                          # Firebase services
│   ├── firestore_service.dart         # CRUD operations
│   └── storage_service.dart           # Image upload
└── screens/                           # UI screens
    ├── car_list_screen.dart           # Car listing (home)
    ├── car_form_screen.dart           # Add car form
    ├── rental_form_screen.dart        # Create rental + customer
    └── customer_profile_screen.dart   # Customer details & history
```

## Usage Examples

### Add a Car
```
Home → Tap "+" → Fill form → Upload image → Save
```

### Create a Rental
```
Home → "Rent a Car" → Select car → Enter customer details → Complete rental
```

### View Customer
```
Navigation → Customer Profile → See details & rental history
```

## Configuration

### Firestore Security Rules (Test Mode)
```firestore
match /{document=**} {
  allow read, write: if true;  // For development only!
}
```

See [README_FIREBASE_SETUP.md](README_FIREBASE_SETUP.md) for production rules.

## Dependencies

- `firebase_core` – Firebase initialization
- `cloud_firestore` – Real-time database
- `firebase_storage` – Image storage
- `provider` – State management
- `image_picker` – Camera/gallery access
- `intl` – Date/time formatting
- `uuid` – Unique ID generation

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `google-services.json` not found | Download from Firebase Console, place in `android/app/` |
| Image upload fails | Check Firebase Storage rules allow write |
| Firestore not connecting | Verify Firebase project enabled, internet connected |
| App crashes on startup | Run `flutter clean && flutter pub get` |

See [README_FIREBASE_SETUP.md](README_FIREBASE_SETUP.md) for detailed setup & troubleshooting.

## Next Steps

- [ ] Complete Firebase setup (follow guide)
- [ ] Run on device/emulator
- [ ] Test car addition & rental flow
- [ ] Add authentication (Firebase Auth)
- [ ] Implement rental return workflow
- [ ] Deploy to App Store / Play Store

## License

MIT License

---

For full Firebase configuration and deployment guide, see **README_FIREBASE_SETUP.md**.
# burhan-rent
# burhan-rent
