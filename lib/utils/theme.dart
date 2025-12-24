import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'custom_color.dart';

class Themes {
  final _box = GetStorage();
  final _key = 'userTheme'; // saved theme key in storage

  // Save selected user theme: 'buyer', 'seller', 'delivery'
  void changeUserTheme(String userType) {
    _box.write(_key, userType);
    if (userType == 'buyer') {
      Get.changeTheme(buyer);
    } else if (userType == 'seller') {
      Get.changeTheme(seller);
    } else if (userType == 'delivery') {
      Get.changeTheme(delivery);
    }
  }

  // Load saved user theme or default to 'buyer'
  String get savedUserTheme => _box.read(_key) ?? 'buyer';

  // Define Buyer ThemeData
  static final buyer = ThemeData(
    useMaterial3: true,
    primaryColor: CustomColor.primaryLightColor,
    scaffoldBackgroundColor: CustomColor.primaryLightScaffoldBackgroundColor,
    brightness: Brightness.light,
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Cairo',
        ),
    // add more styling if needed
  );

  // Define Seller ThemeData
  static final seller = ThemeData(
    useMaterial3: true,
    primaryColor: CustomColor.primaryDarkColor,
    scaffoldBackgroundColor: CustomColor.primaryLightScaffoldBackgroundColor,
    brightness: Brightness.light,
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Cairo',
        ),
    // add more styling if needed
  );

  // Define Delivery ThemeData (optional)
  static final delivery = ThemeData(
    useMaterial3: true,
    primaryColor: Colors.deepOrange,
    scaffoldBackgroundColor: Colors.orange.shade50,
    brightness: Brightness.light,
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Cairo',
        ),
    // customize as you want
  );
}
