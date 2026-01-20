# Burhan Rent – Complete Screen Flow Guide

## 11-Screen Application Flow

### 1️⃣ **Splash Screen** (`splash_screen.dart`)
- **Path:** Shown on app startup
- **Features:**
  - Animated fade-in logo and app title
  - Auto-navigates to login after 3 seconds
  - Beautiful gradient background (deep purple)
- **Navigation:** → Login Screen (auto)

---

### 2️⃣ **Login Screen** (`login_screen.dart`)
- **Path:** `/login`
- **Features:**
  - Email/password input with validation
  - Toggle password visibility
  - Gradient background matching brand
  - Link to register screen
  - Loading indicator during auth
- **Actions:**
  - Login with Firebase Auth
  - On success → Dashboard
  - Link to Register if no account
- **Navigation:** → Dashboard (on success) | Register Screen (link)

---

### 3️⃣ **Register Screen** (`register_screen.dart`)
- **Path:** `/register`
- **Features:**
  - Email, password, confirm password fields
  - Real-time password validation (min 6 chars)
  - Matching password check
  - Same beautiful UI as login
- **Actions:**
  - Create new admin account
  - Auto-login after registration
  - Success message
- **Navigation:** → Dashboard (auto after register) | Back to Login

---

### 4️⃣ **Dashboard** (`dashboard_screen.dart`)
- **Path:** `/dashboard` (home after auth)
- **Features:**
  - Welcome message personalized
  - **Stats Cards** (real-time from Firestore):
    - Total Cars count
    - Active Rentals count
  - **Quick Action Buttons:**
    - Add Car
    - View Cars
    - View Customers
    - Active Rentals
    - Rental History
  - Logout button in AppBar
- **Navigation Hub:** Links to all major screens
- **Navigation:** → All other screens via buttons

---

### 5️⃣ **Car List Screen** (`car_list_screen.dart`)
- **Path:** `/cars`
- **Features:**
  - Grid view of all cars
  - Car image (network or placeholder)
  - Car name, registration number
  - Daily rental price
  - Availability status (Available/Rented badge)
  - Real-time updates via Firestore stream
  - FloatingActionButton to add car
- **Actions:**
  - Add new car (FAB)
  - Tap car to view details (optional future feature)
- **Navigation:** → Add Car Form | Home

---

### 6️⃣ **Add/Edit Car Screen** (`car_form_screen.dart`)
- **Path:** `/add-car`
- **Features:**
  - Car image picker (gallery)
  - Form fields:
    - Car name/model
    - Registration number
    - Rent price per day (number input)
  - Image upload to Firebase Storage
  - Form validation
  - Loading indicator
- **Actions:**
  - Upload image to Storage
  - Save car to Firestore
  - Auto-set `available: true` and `createdAt: now`
  - Success message
- **Navigation:** → Car List (on success)

---

### 7️⃣ **Customer List Screen** (`customer_list_screen.dart`)
- **Path:** `/customers`
- **Features:**
  - List of all customers
  - Customer avatar (from photo or placeholder)
  - Search/filter by name or phone
  - Real-time search as you type
  - FloatingActionButton to add customer
- **Actions:**
  - Search customers
  - Tap customer → Customer Profile
  - Add new customer (FAB)
- **Navigation:** → Customer Profile | Add Customer | Dashboard

---

### 8️⃣ **Add Customer Screen** (`add_customer_screen.dart`)
- **Path:** `/add-customer`
- **Features:**
  - Customer photo picker (gallery)
  - Form fields:
    - Full name
    - Phone number
    - CNIC/ID number
    - Address (multi-line)
  - Image upload to Firebase Storage
  - Form validation
  - Loading indicator
- **Actions:**
  - Upload customer photo to Storage
  - Save customer to Firestore
  - Success message
- **Note:** Can also be called from Rental Form
- **Navigation:** → Customer List (on success)

---

### 9️⃣ **Rent Car Screen** (`rental_form_screen.dart`)
- **Path:** `/rent-car`
- **Features:**
  - **Car Selection:**
    - Dropdown of available cars only
    - Shows car name + registration
  - **Rental Duration:**
    - Slider picker (1–30 days)
    - Visual duration display
  - **Start Date:**
    - Date picker (from today onward)
  - **Customer Details Section:**
    - Customer photo picker
    - Full name, phone, ID, address
    - All required fields
  - Combined workflow: Add customer + create rental in one go
- **Actions:**
  - Select available car
  - Set rental dates/duration
  - Enter/upload customer info
  - Submit:
    1. Upload customer photo → Storage
    2. Create customer record → Firestore
    3. Mark car as unavailable
    4. Create rental record → Firestore
  - Success message
- **Navigation:** → Active Rentals (on success) | Dashboard

---

### 🔟 **Active Rentals Screen** (`active_rentals_screen.dart`)
- **Path:** `/active-rentals`
- **Features:**
  - Real-time list of all active rentals (via Firestore stream)
  - Rental card showing:
    - Car info (name, registration)
    - Customer info (name, phone)
    - Start date (formatted)
    - Duration (days + hours)
  - "View Details" button per rental
  - FloatingActionButton to create new rental
- **Actions:**
  - Tap "View Details" → Rental Detail Screen
  - Add new rental (FAB)
- **Navigation:** → Rental Detail | Rent Car | Dashboard

---

### 1️⃣1️⃣ **Rental Detail Screen** (`rental_detail_screen.dart`)
- **Path:** `/rental-detail` (with rental ID argument)
- **Features:**
  - **Full Rental Information:**
    - Car image (if available)
    - Car name, registration, daily price
    - Customer photo (if available)
    - Customer full details (name, phone, ID, address)
    - Rental start date
    - Rental duration (days + hours)
  - **"Return Car" Button:**
    - Confirmation dialog
    - Marks car as available again
    - Updates Firestore
  - Success notification
- **Actions:**
  - View all rental and customer details
  - Return car (complete rental)
- **Navigation:** → Active Rentals (after return) | Dashboard

---

### Additional: **Rental History Screen** (`history_screen.dart`)
- **Path:** `/history`
- **Features:**
  - List all rentals (all-time, ordered by newest first)
  - Filter by car name or customer name
  - Real-time search
  - Rental cards showing:
    - Car and customer info
    - Rental creation date
    - Duration
  - No action buttons (read-only view)
- **Purpose:** Admin dashboard for reporting and audits
- **Navigation:** → Dashboard

---

### Additional: **Customer Profile Screen** (`customer_profile_screen.dart`)
- **Path:** `/customer-profile` (with customer ID argument)
- **Features:**
  - Customer photo (or placeholder)
  - Personal details (name, phone, ID, address)
  - **Rental History Section:**
    - All rentals by this customer
    - Car details per rental (name, registration)
    - Rental dates and duration
- **Purpose:** View customer record and rental history
- **Navigation:** → Active Rentals | Rental History

---

## Navigation Flow Diagram

```
Splash Screen (auto 3s)
    ↓
Login Screen ← → Register Screen
    ↓ (auth success)
Dashboard (HOME)
    ├→ Add Car → Car List ↔ Dashboard
    ├→ Cars → Car List → Dashboard
    ├→ Customers → Customer List ↔ Add Customer
    │                ↓
    │           Customer Profile → Active Rentals
    ├→ Active Rentals → Rent Car
    │                 ↓
    │          Rental Detail (Return Car) ↔ Active Rentals
    └→ History ↔ Dashboard
```

---

## Data Models Used

### Car
```
id, name, registrationNumber, rentPricePerDay, available, imageUrl, createdAt
```

### Customer
```
id, fullName, phoneNumber, idNumber, address, photoUrl, createdAt
```

### Rental
```
id, carId, customerId, startAt, durationHours, createdAt
```

---

## Firebase Collections & Firestore Structure

### `/cars` Collection
- Auto-generated doc ID
- Fields: name, registrationNumber, rentPricePerDay, available, imageUrl, createdAt

### `/customers` Collection
- Auto-generated doc ID
- Fields: fullName, phoneNumber, idNumber, address, photoUrl, createdAt

### `/rentals` Collection
- Auto-generated doc ID
- Fields: carId, customerId, startAt, durationHours, createdAt

---

## Key Features & Workflows

### ✅ Authentication
- Email/Password sign-up and login via Firebase Auth
- Session persistence
- Logout on dashboard

### ✅ Car Management
- Add cars with photos
- Real-time car list with availability status
- Mark cars as rented/available

### ✅ Customer Management
- Add customers independently or during rental
- Customer profiles with rental history
- Search/filter by name or phone

### ✅ Rental Management
- Create rentals linking car + customer
- Automatic car availability updates
- View active rentals and details
- Return car (complete rental)
- Rental history for reporting

### ✅ Image Upload
- Car photos → Firebase Storage
- Customer photos → Firebase Storage
- Secure CDN URLs returned

### ✅ Real-time Updates
- Firestore streams for cars, rentals, customers
- Live stats on dashboard
- Instant availability updates

---

## Setup Checklist

- [ ] Firebase project created
- [ ] `google-services.json` placed in `android/app/`
- [ ] `GoogleService-Info.plist` added to Xcode (iOS)
- [ ] Firestore collections created (auto-created on first write)
- [ ] Firebase Storage enabled
- [ ] Firebase Auth enabled
- [ ] Security rules configured (test or production)
- [ ] `flutter pub get`
- [ ] Run on device/emulator: `flutter run`

---

**All 11 screens fully implemented and ready for Firebase configuration!**
