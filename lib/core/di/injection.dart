import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initializeDependencies() async {
  // Initialize Hive boxes
  await Hive.openBox('settings');
  await Hive.openBox('cache');
  
  // Clear expired cache on startup
  final cacheBox = Hive.box('cache');
  // Add any cache cleanup logic here
}

// Secure storage instance
const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);
