import 'package:get_storage/get_storage.dart';

import '../../utils/basic_screen_imports.dart';
import 'language_model.dart';
import 'language_service.dart';

 final languageSettingsController = Get.find<LanguageSettingController>();
class LanguageSettingController extends GetxController {
  RxString selectedLanguage = "".obs; // Selected language is English
  RxString defLangKey = "".obs; // Default language is English

  @override
  void onInit() {
    fetchLanguages().then((value) => getDefaultKey());
    super.onInit();
  }

  List<Language> languages = [];
  var isLoadingValue = false.obs;

  bool get isLoading => isLoadingValue.value;
  static const String selectedLanguageKey = 'selectedLanguage';

  // Future<void> fetchLanguages() async {
  //   isLoadingValue.value = true;
  //   try {
  //     final languageService = LanguageService();
  //     languages = await languageService.fetchLanguages();
  //     isLoadingValue.value = false;
  //     debugPrint('>> Fetch Language');
  //   } catch (e) {
  //     debugPrint('Error fetching language data: $e');
  //   }
  // }
  Future<void> fetchLanguages() async {
    isLoadingValue.value = true;
    try {
      final deviceLang = Get.deviceLocale?.languageCode ?? 'en';
      final languageService = LanguageService();

      languages = await languageService.fetchLanguages(langCode: deviceLang);
      debugPrint('>> Fetched $deviceLang Languages');

      // 👇 Set device language as selected if available
      final box = GetStorage();
      final savedLang = box.read(selectedLanguageKey);

      if (savedLang != null && savedLang.isNotEmpty) {
        selectedLanguage.value = savedLang; // use cached selection
      } else {
        // Check if device language exists in list
        final deviceLangExists = languages.any((lang) => lang.code == deviceLang);
        selectedLanguage.value = deviceLangExists ? deviceLang : 'en';
        box.write(selectedLanguageKey, selectedLanguage.value);
      }

      getDefaultKey(); // fallback + sync with defaults
    } catch (e) {
      debugPrint('Error fetching language data: $e');
    } finally {
      isLoadingValue.value = false;
    }
  }


  // >> get default language key
  String getDefaultKey() {
    isLoadingValue.value = true;

    if (languages.isEmpty) {
      // fallback to system
      final systemLang = Get.deviceLocale?.languageCode ?? 'en';
      defLangKey.value = systemLang;
      selectedLanguage.value = systemLang;
      isLoadingValue.value = false;
      return systemLang;
    }

    final selectedLang = languages.firstWhere(
          (lang) => lang.status == true,
      orElse: () => languages.first,
    );

    defLangKey.value = selectedLang.code;

    final box = GetStorage();
    selectedLanguage.value = box.read(selectedLanguageKey) ?? defLangKey.value;
    isLoadingValue.value = false;
    return defLangKey.value;
  }

  /*
  String getDefaultKey() {
    isLoadingValue.value = true;
    final selectedLang = languages.firstWhere(
      (lang) => lang.status == true,
      orElse: () => languages.firstWhere(
        (lang) => lang.status == false,
      ), // Fallback to language default code, when status true.
    );
    defLangKey.value = selectedLang.code;

    // Load selected language from cache
    final box = GetStorage();
    selectedLanguage.value = box.read(selectedLanguageKey) ?? defLangKey.value;
    isLoadingValue.value = false;
    return selectedLang.code;
  }*/

  void changeLanguage(String newLanguage) {
    selectedLanguage.value = newLanguage;
    final box = GetStorage();
    box.write(selectedLanguageKey, newLanguage);
    // LocalStorages.saveRtl(type: languageDirection == 'rtl' ? true : false);
    update();
  }

  String getTranslation(String key) {
    final selectedLang = languages.firstWhere(
      (lang) => lang.code == selectedLanguage.value,
      orElse: () => languages.firstWhere(
        (lang) => lang.code == defLangKey.value,
      ),
    );

    final defaultLanguage = languages.firstWhere(
      (lang) => lang.code == 'en',
      orElse: () => languages.firstWhere(
        (lang) => lang.code == 'en',
      ),
    );

    String value;
    if (selectedLang.translateKeyValues[key] == '' ||
        selectedLang.translateKeyValues[key] == null) {
      value = defaultLanguage.translateKeyValues[key] ?? key;
    } else {
      value = selectedLang.translateKeyValues[key] ?? key;
    }

    return value;
  }
  Locale get currentLocale {
    final code = selectedLanguage.value.isNotEmpty
        ? selectedLanguage.value
        : defLangKey.value.isNotEmpty
        ? defLangKey.value
        : Get.deviceLocale?.languageCode ?? 'en';

    return Locale(code);
  }

  /// Get text direction [ when selected language null return default direction ]
  TextDirection get languageDirection {
    isLoadingValue.value = true;
    try {
      final selectedLang = languages.firstWhere(
        (lang) => lang.code == selectedLanguage.value,
        orElse: () => languages.firstWhere(
          (lang) => lang.code == defLangKey.value,
        ),
      );
      isLoadingValue.value = false;
      // LocalStorages.saveRtl(type: selectedLang.dir == 'rtl' ? true : false);
      update();
      return selectedLang.dir == 'rtl' ? TextDirection.rtl : TextDirection.ltr;
    } catch (e) {
      return TextDirection.ltr; // Fallback to left-to-right (LTR)
    }
  }
}
