# PeacePay Mobile App - Build Instructions

## Prerequisites

1. **Flutter SDK** (version 3.2.0 or higher)
   ```bash
   flutter --version
   ```

2. **Android Studio** (for Android builds)
   - Android SDK 35
   - Android NDK
   - Java 17

3. **Xcode** (for iOS builds, macOS only)
   - Xcode 15 or higher
   - CocoaPods

## Setup

### 1. Clone Repository
```bash
git clone https://github.com/HealthFlowEgy/peacepay-mobile.git
cd peacepay-mobile
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Code (if using build_runner)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Android Build

### Development Build (Debug)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Production Build (Release)

#### Step 1: Create Keystore (first time only)
```bash
keytool -genkey -v -keystore android/keystore/peacepay-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias peacepay -storepass YOUR_PASSWORD -keypass YOUR_PASSWORD
```

#### Step 2: Configure Signing
Copy `android/key.properties.example` to `android/key.properties` and fill in your values:
```properties
storeFile=keystore/peacepay-release.jks
storePassword=YOUR_KEYSTORE_PASSWORD
keyAlias=peacepay
keyPassword=YOUR_KEY_PASSWORD
```

#### Step 3: Build Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Step 4: Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

## iOS Build

### Development Build
```bash
cd ios && pod install && cd ..
flutter build ios --debug
```

### Production Build

#### Step 1: Configure Signing in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target → Signing & Capabilities
3. Select your Team and configure signing

#### Step 2: Build for App Store
```bash
flutter build ipa --release
```
Output: `build/ios/ipa/peacepay.ipa`

## Environment Configuration

### Build for Different Environments

**Development:**
```bash
flutter build apk --dart-define=ENVIRONMENT=development
```

**Staging:**
```bash
flutter build apk --dart-define=ENVIRONMENT=staging
```

**Production:**
```bash
flutter build apk --dart-define=ENVIRONMENT=production
```

## Firebase Setup (Required for Push Notifications)

### Android
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create/select your project
3. Add Android app with package name: `com.peacepay.pay`
4. Download `google-services.json`
5. Place in `android/app/google-services.json`

### iOS
1. Add iOS app with bundle ID: `com.peacepay.pay`
2. Download `GoogleService-Info.plist`
3. Place in `ios/Runner/GoogleService-Info.plist`

## API Configuration

The app is configured to connect to:
- **Production**: `http://142.93.108.213/api/v1`

To change the API endpoint, edit:
- `lib/backend/services/api_endpoint.dart`
- Or use environment variables with `lib/config/environment.dart`

## Troubleshooting

### Android Build Issues

**Gradle sync failed:**
```bash
cd android && ./gradlew clean && cd ..
flutter clean
flutter pub get
```

**SDK version mismatch:**
Ensure `android/app/build.gradle` has:
```gradle
compileSdkVersion 35
minSdkVersion 25
targetSdkVersion 35
```

### iOS Build Issues

**Pod install failed:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

**Signing issues:**
Open Xcode and manually configure signing certificates.

## App Store Submission Checklist

### Google Play Store
- [ ] App Bundle (.aab) built with release signing
- [ ] App icons (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (phone and tablet)
- [ ] Privacy policy URL
- [ ] Content rating questionnaire completed

### Apple App Store
- [ ] IPA built with distribution certificate
- [ ] App icons (1024x1024 PNG)
- [ ] Screenshots for all device sizes
- [ ] Privacy policy URL
- [ ] App Review information

## Support

For build issues, contact: support@peacepay.me
