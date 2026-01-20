# Burhan Rent – Firebase Setup & Configuration Guide

## Complete 11-Screen App with Authentication & Real-time Database

This guide covers the **complete Firebase setup** needed to run the full Burhan Rent application with all 11 screens.

---

## Table of Contents

1. [Firebase Project Setup](#firebase-project-setup)
2. [Android Configuration](#android-configuration)
3. [iOS Configuration](#ios-configuration)
4. [Firestore Security Rules](#firestore-security-rules)
5. [Firebase Storage Rules](#firebase-storage-rules)
6. [Complete Setup Checklist](#complete-setup-checklist)
7. [Troubleshooting](#troubleshooting)

---

## Firebase Project Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `burhan-rent` (or your choice)
4. Enable Google Analytics (optional but recommended)
5. Create project
6. Wait for completion (1-2 minutes)

### Step 2: Enable Required Services

In your Firebase project, enable these services:

#### **Cloud Firestore**
1. Left sidebar → **Firestore Database**
2. Click **"Create Database"**
3. Select **"Start in test mode"** (for development)
4. Choose location (default is fine)
5. Create
   - ⚠️ **Note:** Test mode allows all reads/writes. See [Firestore Security Rules](#firestore-security-rules) for production rules.

#### **Firebase Storage**
1. Left sidebar → **Storage**
2. Click **"Get Started"**
3. Start in test mode
4. Choose default bucket location
5. Done

#### **Authentication**
1. Left sidebar → **Authentication**
2. Click **"Get Started"**
3. Go to **Sign-in method** tab
4. Enable **Email/Password**
   - Click email/password option
   - Enable "Email/Password"
   - Enable "Email link (passwordless sign-in)" (optional)
   - Save

---

## Android Configuration

### Step 1: Download google-services.json

1. In Firebase Console, click **"Project Settings"** (gear icon)
2. Go to **"Your apps"** section
3. Find or add your **Android app**:
   - Package name: `com.example.burhan_rent_admin`
   - Debug signing certificate SHA-1 (optional for now)
4. Click **"google-services.json"** download button
5. Save the file locally

### Step 2: Add google-services.json to Project

1. Open Terminal:
   ```bash
   cd /Users/macbook/Desktop/burhan_rent_admin
   ```

2. Place the downloaded file:
   ```bash
   cp ~/Downloads/google-services.json android/app/google-services.json
   ```

3. Verify placement:
   ```bash
   ls -la android/app/google-services.json
   ```
   Should show: `-rw-r--r--  ...  google-services.json`

### Step 3: Configure Gradle

**Check `android/build.gradle`** – should include:
```gradle
buildscript {
  repositories {
    google()
    mavenCentral()
  }
  dependencies {
    classpath 'com.android.tools.build:gradle:7.0.0'
    classpath 'com.google.gms:google-services:4.3.15'  // Firebase plugin
    classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.5.31'
  }
}
```

**Check `android/app/build.gradle`** – should include:
```gradle
plugins {
  id 'com.android.application'
  id 'kotlin-android'
  id 'com.google.gms.google-services'  // Apply Firebase plugin
}

android {
  compileSdkVersion 33
  
  defaultConfig {
    applicationId "com.example.burhan_rent_admin"
    minSdkVersion 21  // Important: min API 21 for Firebase
    targetSdkVersion 33
  }
}

dependencies {
  // Firebase deps (auto-added by Flutter)
  implementation 'com.google.firebase:firebase-analytics:21.1.1'
  implementation 'com.google.firebase:firebase-core:21.1.1'
  // etc.
}
```

### Step 4: Test Android Setup

```bash
flutter pub get
flutter clean
flutter run -d "emulator-5554"  # or your device ID
```

---

## iOS Configuration

### Step 1: Download GoogleService-Info.plist

1. In Firebase Console, click **"Project Settings"** (gear icon)
2. Go to **"Your apps"** → Find iOS app (or add it)
   - Bundle ID: `com.example.burhanRentAdmin`
3. Click **"GoogleService-Info.plist"** download button
4. Save locally

### Step 2: Add to Xcode

1. Open Xcode workspace:
   ```bash
   open ios/Runner.xcworkspace  # NOT .xcodeproj
   ```

2. In Xcode, right-click **Runner** in left sidebar → **"Add Files to Runner"**

3. Select downloaded `GoogleService-Info.plist`

4. Check:
   - ✓ "Copy items if needed"
   - ✓ "Add to targets: Runner"

5. Click **"Add"**

6. Verify file appears in Xcode under **Runner** → **Runner** folder

### Step 3: Update iOS Deployment Target

1. In Xcode, select **Runner** project
2. Select **Runner** target
3. Go to **Build Settings** tab
4. Search for **"Deployment Target"** or **"iOS Deployment Target"**
5. Set to **11.0** or higher (Firebase requirement)
   - Repeat for **Runner** and **RunnerTests** targets

### Step 4: Update Podfile (if needed)

Open `ios/Podfile` and ensure:
```ruby
platform :ios, '11.0'  # or higher

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

### Step 5: Test iOS Setup

```bash
flutter clean
flutter pub get
flutter run -d "iPhone 14"  # or your simulator
```

---

## Firestore Security Rules

### Development Rules (Test Mode)
For quick testing **only** (current default):
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **WARNING:** This allows anyone to read/write all data. Use only for development!

### Production Rules (Recommended)
For a real production app:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Only authenticated users can access
    match /cars/{document=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        request.auth.token.admin == true;
    }
    
    match /customers/{document=**} {
      allow read, create, update: if request.auth != null;
      allow delete: if request.auth != null && 
        request.auth.token.admin == true;
    }
    
    match /rentals/{document=**} {
      allow read, create, update: if request.auth != null;
      allow delete: if request.auth != null && 
        request.auth.token.admin == true;
    }
  }
}
```

**To Apply Rules:**
1. Firebase Console → **Firestore Database**
2. Go to **"Rules"** tab
3. Paste rules above
4. Click **"Publish"**

---

## Firebase Storage Rules

### Development Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

### Production Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;  // Anyone can view images
      allow write: if request.auth != null;  // Only authenticated users can upload
    }
  }
}
```

**To Apply:**
1. Firebase Console → **Storage**
2. Go to **"Rules"** tab
3. Paste rules
4. Click **"Publish"**

---

## Complete Setup Checklist

### ✅ Firebase Project
- [ ] Firebase project created
- [ ] Firestore Database enabled (test mode)
- [ ] Firebase Storage enabled
- [ ] Firebase Authentication enabled with Email/Password

### ✅ Android Setup
- [ ] `google-services.json` downloaded from Firebase Console
- [ ] `google-services.json` placed in `android/app/`
- [ ] `android/build.gradle` includes Firebase plugin
- [ ] `android/app/build.gradle` applies `com.google.gms.google-services`
- [ ] Min SDK version ≥ 21

### ✅ iOS Setup
- [ ] `GoogleService-Info.plist` downloaded from Firebase Console
- [ ] `GoogleService-Info.plist` added to Xcode (Runner target)
- [ ] iOS deployment target ≥ 11.0
- [ ] Podfile has correct platform version

### ✅ Code & Dependencies
- [ ] `pubspec.yaml` has all Firebase packages
- [ ] `flutter pub get` runs without errors
- [ ] `flutter analyze` passes (no errors)

### ✅ Testing
- [ ] `flutter run` starts on Android/iOS without crashes
- [ ] Splash screen appears
- [ ] Login screen loads
- [ ] Can create account with Firebase Auth
- [ ] Dashboard loads with stats
- [ ] Can add car (uploads to Storage)
- [ ] Can view car list in real-time

---

## Troubleshooting

### Firebase Not Initializing

**Error:** `PlatformException: Failed to load FirebaseOptions from resource`

**Solution:**
1. Verify `google-services.json` exists in `android/app/`
2. Run `flutter clean`
3. Run `flutter pub get`
4. Rebuild: `flutter run`

---

### Firestore Connection Issues

**Error:** `permission-denied: Missing or insufficient permissions`

**Solution:**
1. Check Firestore Security Rules (should be in test mode)
2. Verify Firebase project ID matches `google-services.json`
3. Check internet connection

---

### Image Upload Fails

**Error:** `Permission denied in Firebase Storage`

**Solution:**
1. Check Firebase Storage rules allow write:
   ```
   allow write: if true;  // for development
   ```
2. Verify image file < 5MB
3. Check app has camera/gallery permissions

**For iOS:**
Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Need access to photos for car and customer images</string>
<key>NSCameraUsageDescription</key>
<string>Need camera access for photos</string>
```

---

### App Crashes on Startup

**Error:** `PlatformException` or `FirebaseException`

**Solution:**
1. Ensure Firebase CLI is installed:
   ```bash
   npm install -g firebase-tools
   ```
2. Verify Firebase project is active
3. Check `pubspec.yaml` has all Firebase packages
4. Update Flutter:
   ```bash
   flutter upgrade
   ```

---

### Xcode Build Fails (iOS)

**Error:** `GoogleService-Info.plist not found` or `CFBundleIdentifier` mismatch

**Solution:**
1. Open `ios/Runner.xcworkspace` (not `.xcodeproj`)
2. Verify `GoogleService-Info.plist` exists in Xcode file tree under **Runner**
3. Verify Bundle ID in Xcode matches Firebase app:
   - Xcode: **Runner** → **Build Settings** → **Product Bundle Identifier**
   - Firebase: Project Settings → Apps → Bundle ID
4. Re-add `GoogleService-Info.plist` if needed

---

### Gradle Build Fails (Android)

**Error:** `google-services.json not found` or version conflicts

**Solution:**
1. Verify file path:
   ```bash
   ls -la android/app/google-services.json
   ```
2. Ensure `android/app/build.gradle` has:
   ```gradle
   id 'com.google.gms.google-services'
   ```
3. Ensure `android/build.gradle` has:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.15'
   ```
4. Update Gradle wrapper:
   ```bash
   flutter pub get
   flutter clean
   flutter run
   ```

---

## Next Steps After Setup

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Test Authentication:**
   - Register new admin account
   - Verify email is created in Firebase Console

3. **Test Car Management:**
   - Add a car with image
   - Verify image in Firebase Storage
   - Check car in Firestore under `/cars` collection

4. **Test Rental Workflow:**
   - Create rental
   - Verify customer record created
   - Check rental in Firestore under `/rentals`
   - View rental details and return car

5. **Verify Real-time Updates:**
   - Open app on two devices
   - Add car on device 1
   - Verify it appears instantly on device 2

---

## Production Deployment

### Before Going Live:

1. **Update Security Rules** (not test mode)
2. **Enable Authentication** if not already
3. **Set up backups** for Firestore (Firebase Blaze plan)
4. **Configure email** for password resets
5. **Test on real devices** (iOS + Android)
6. **Load test** with sample data
7. **Monitor Firebase quotas**:
   - Firestore: 50k reads/day free
   - Storage: 1GB/month free

### Build for Deployment:

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
# Then submit via Xcode to App Store
```

---

## Support & Resources

- [Firebase Docs](https://firebase.google.com/docs)
- [Flutter Firebase Docs](https://firebase.google.com/docs/flutter/setup)
- [Firestore Security](https://firebase.google.com/docs/firestore/security/start)
- [Firebase Console](https://console.firebase.google.com/)

---

**All set! Your Burhan Rent app is ready to connect to Firebase. Happy building! 🚗🔥**

