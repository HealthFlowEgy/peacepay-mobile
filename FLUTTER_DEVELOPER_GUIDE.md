# PeacePay Flutter Developer Guide

This guide provides step-by-step instructions for Flutter developers to set up, run, and build the PeacePay mobile application.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Project Setup](#project-setup)
4. [Running the App](#running-the-app)
5. [Building for Production](#building-for-production)
6. [Project Structure](#project-structure)
7. [API Integration](#api-integration)
8. [Firebase Configuration](#firebase-configuration)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

| Software | Version | Download |
|----------|---------|----------|
| Flutter SDK | 3.19+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.3+ | Included with Flutter |
| Android Studio | Latest | [developer.android.com](https://developer.android.com/studio) |
| Xcode (macOS only) | 15+ | App Store |
| VS Code (recommended) | Latest | [code.visualstudio.com](https://code.visualstudio.com/) |

### VS Code Extensions

- Flutter
- Dart
- Flutter Riverpod Snippets (optional)

---

## Environment Setup

### 1. Install Flutter

```bash
# macOS/Linux
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Windows - Download from flutter.dev and add to PATH

# Verify installation
flutter doctor
```

### 2. Configure Android Development

```bash
# Accept Android licenses
flutter doctor --android-licenses

# Verify Android setup
flutter doctor
```

### 3. Configure iOS Development (macOS only)

```bash
# Install CocoaPods
sudo gem install cocoapods

# Verify iOS setup
flutter doctor
```

---

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/HealthFlowEgy/peacepay-mobile.git
cd peacepay-mobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Endpoint

Edit `lib/backend/services/api_endpoint.dart`:

```dart
class ApiEndpoint {
  // Production API
  static const String mainDomain = "http://142.93.108.213/api/v1";
  
  // For local development (optional)
  // static const String mainDomain = "http://10.0.2.2:8000/api/v1"; // Android emulator
  // static const String mainDomain = "http://localhost:8000/api/v1"; // iOS simulator
}
```

### 4. Firebase Configuration (Already Configured)

The Firebase configuration files are already in place:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

---

## Running the App

### List Available Devices

```bash
flutter devices
```

### Run on Android Emulator

```bash
# Start emulator
flutter emulators --launch <emulator_id>

# Run app
flutter run
```

### Run on iOS Simulator (macOS only)

```bash
# Open iOS Simulator
open -a Simulator

# Run app
flutter run
```

### Run on Physical Device

```bash
# Android: Enable USB debugging on device
# iOS: Trust the computer on device

flutter run -d <device_id>
```

### Run with Hot Reload

```bash
flutter run
# Press 'r' for hot reload
# Press 'R' for hot restart
```

---

## Building for Production

### Android APK

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only)

```bash
# Build for iOS
flutter build ios --release

# Open in Xcode for archive and distribution
open ios/Runner.xcworkspace
```

### Android Signing Configuration

1. Create a keystore:
```bash
keytool -genkey -v -keystore ~/peacepay-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias peacepay
```

2. Create `android/key.properties`:
```properties
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=peacepay
storeFile=/path/to/peacepay-upload-key.jks
```

3. Build signed APK:
```bash
flutter build apk --release
```

---

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── backend/
│   ├── constants/           # App constants
│   ├── models/              # Data models
│   └── services/            # API services
│       ├── api_endpoint.dart
│       ├── api_services.dart
│       └── ...
├── config/
│   └── environment.dart     # Environment configuration
├── controller/              # GetX controllers
│   ├── auth/
│   ├── dashboard/
│   └── ...
├── views/                   # UI screens
│   ├── auth/
│   ├── dashboard/
│   └── ...
├── widgets/                 # Reusable widgets
│   ├── buttons/
│   ├── inputs/
│   └── ...
└── routes/                  # App routing
```

---

## API Integration

### Base Configuration

The app connects to the backend at: `http://142.93.108.213/api/v1`

### Available Endpoints

| Category | Endpoints |
|----------|-----------|
| Auth | `/user/login`, `/user/register`, `/user/verify-otp` |
| Wallet | `/wallet/balance`, `/wallet/add-money`, `/wallet/send` |
| PeaceLink | `/peacelinks`, `/peacelinks/create`, `/peacelinks/{id}` |
| Cashout | `/cashout/request`, `/cashout/history` |
| Disputes | `/disputes`, `/disputes/{id}` |
| KYC | `/kyc/submit`, `/kyc/status` |
| Notifications | `/notifications`, `/notifications/read` |

### Making API Calls

```dart
import 'package:peacepay/backend/services/api_services.dart';

// Example: Login
final response = await ApiServices.loginApi(
  phone: '01012345678',
  password: 'password123',
);

// Example: Get wallet balance
final wallet = await ApiServices.walletBalanceApi();
```

---

## Firebase Configuration

### Push Notifications

The app is configured to receive push notifications via Firebase Cloud Messaging (FCM).

**Notification Types:**
- `peacelink_created` - New PeaceLink created
- `peacelink_approved` - PeaceLink approved by merchant
- `peacelink_delivered` - Delivery confirmed
- `peacelink_released` - Funds released
- `dispute_opened` - Dispute opened
- `dispute_resolved` - Dispute resolved
- `cashout_completed` - Cashout completed
- `cashout_failed` - Cashout failed

### Testing Push Notifications

1. Get the FCM token from the app logs
2. Use Firebase Console to send a test notification
3. Or use the backend API to trigger notifications

---

## Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues

```bash
# Run diagnostics
flutter doctor -v

# Clean and rebuild
flutter clean
flutter pub get
```

#### 2. Android Build Errors

```bash
# Clean Gradle cache
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 3. iOS Build Errors (macOS)

```bash
# Update CocoaPods
cd ios
pod deintegrate
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

#### 4. API Connection Issues

- Verify the backend is running: `curl http://142.93.108.213/api/health`
- Check network permissions in `AndroidManifest.xml`
- For iOS, check `Info.plist` for App Transport Security settings

#### 5. Firebase Issues

- Ensure `google-services.json` is in `android/app/`
- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Check Firebase Console for app registration

### Getting Help

- Flutter Documentation: [flutter.dev/docs](https://flutter.dev/docs)
- Firebase Documentation: [firebase.google.com/docs](https://firebase.google.com/docs)
- Project Issues: [GitHub Issues](https://github.com/HealthFlowEgy/peacepay-mobile/issues)

---

## Quick Reference

### Useful Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run app in debug mode |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS app |
| `flutter clean` | Clean build files |
| `flutter doctor` | Check environment |
| `flutter devices` | List available devices |
| `flutter logs` | View device logs |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `API_BASE_URL` | Backend API URL | `http://142.93.108.213/api/v1` |
| `ENVIRONMENT` | App environment | `production` |

---

## Contact

For questions or support, contact the development team.

**Repository:** https://github.com/HealthFlowEgy/peacepay-mobile
**Backend API:** http://142.93.108.213
