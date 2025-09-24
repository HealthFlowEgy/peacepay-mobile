import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../backend_utils/constants.dart';

const String tokenKey = "tokenKey";
const String emailKey = "emailKey";
const String userIdKey = "userIdKey";
const String isLoggedInKey = "isLoggedInKey";
const String isDataLoadedKey = "isDataLoadedKey";
const String isOnBoardDoneKey = "isOnBoardDoneKey";
const String mustCheckPinKey = "mustCheckPinKey";
const String language = "language";
const String smallLanguage = "smallLanguage";
const String capitalLanguage = "capitalLanguage";
const String hasPinKey = "hasPinKey";
const String firstLoginDoneKey = "firstLoginDoneKey";

const String lastRouteKey = "lastRouteKey";

class LocalStorage {
  static Future<void> saveUserId({required int id}) async {
    final box = GetStorage();
    await box.write(userIdKey, id);
  }

  static Future<void> saveEmail({required String email}) async {
    final box = GetStorage();
    await box.write(emailKey, email);
  }

  static Future<void> saveToken({required String token}) async {
    final box = GetStorage();
    await box.write(tokenKey, token);
  }

  static Future<void> isLoginSuccess({required bool isLoggedIn}) async {
    final box = GetStorage();
    await box.write(isLoggedInKey, isLoggedIn);
  }

  static Future<void> dataLoaded({required bool isDataLoad}) async {
    final box = GetStorage();
    await box.write(isDataLoadedKey, isDataLoad);
  }

  static Future<void> saveOnboardDoneOrNot({required bool isOnBoardDone}) async {
    final box = GetStorage();
    await box.write(isOnBoardDoneKey, isOnBoardDone);
  }

  static Future<void> changeLanguage() async {
    final box = GetStorage();
    await box.remove(language);
  }

  static int? getUserId() {
    return GetStorage().read(userIdKey) ?? (-1);
  }

  static String? getEmail() {
    return GetStorage().read(emailKey) ?? "";
  }

  static String? getToken() {
    var rtrn = GetStorage().read(tokenKey);
    debugPrint(rtrn == null ? "##Token is null###" : "");
    return rtrn;
  }

  static bool isLoggedIn() {
    return GetStorage().read(isLoggedInKey) ?? false;
  }

  static bool isDataLoaded() {
    return GetStorage().read(isDataLoadedKey) ?? false;
  }

  static Future<void> saveHasPin({required bool hasPin}) async {
    final box = GetStorage();
    await box.write(hasPinKey, hasPin);
  }

  static bool hasPin() {
    return GetStorage().read(hasPinKey) ?? false;
  }

  static Future<void> clearHasPin() async {
    final box = GetStorage();
    await box.remove(hasPinKey);
  }

  static bool isOnBoardDone() {
    return GetStorage().read(isOnBoardDoneKey) ?? false;
  }

  static Future<void> logout() async {
    final box = GetStorage();
    await box.remove(emailKey);
    await box.remove(isLoggedInKey);
    await box.remove(tokenKey);
    await LocalStorage.clearHasPin();
    await box.remove(hasPinKey);
    await box.remove(lastRouteKey); //
    await box.remove(firstLoginDoneKey);
  }

  static Future<void> saveLanguage({
    required String langSmall,
    required String langCap,
    required String languageName,
  }) async {
    final box1 = GetStorage();
    final box2 = GetStorage();
    final box3 = GetStorage();
    languageStateName = languageName;
    var locale = Locale(langSmall, langCap);
    Get.updateLocale(locale);
    await box1.write(smallLanguage, langSmall);
    await box2.write(capitalLanguage, langCap);
    await box3.write(language, languageName);
  }

  static List getLanguage() {
    String small = GetStorage().read(smallLanguage) ?? 'en';
    String capital = GetStorage().read(capitalLanguage) ?? 'EN';
    String languages = GetStorage().read(language) ?? 'English';
    return [small, capital, languages];
  }

  // ------------------------
  //  lastRoute storage
  // ------------------------
  static Future<void> saveLastRoute(String route) async {
    final box = GetStorage();
    await box.write(lastRouteKey, route);
  }

  static String? getLastRoute() {
    return GetStorage().read(lastRouteKey);
  }

  static Future<void> clearLastRoute() async {
    final box = GetStorage();
    await box.remove(lastRouteKey);
  }
  static Future<void> setMustCheckPin(bool value) async {
    final box = GetStorage();
    await box.write(mustCheckPinKey, value);
  }

  static bool mustCheckPin() {
    return GetStorage().read(mustCheckPinKey) ?? false;
  }
  static Future<void> setFirstLoginDone(bool done) async {
    final box = GetStorage();
    await box.write(firstLoginDoneKey, done);
  }

  static bool isFirstLoginDone() {
    return GetStorage().read(firstLoginDoneKey) ?? false;
  }

}
