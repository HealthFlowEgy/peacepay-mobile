import 'package:get_storage/get_storage.dart';

import '../../utils/basic_screen_imports.dart';
import 'language_model.dart';
import 'language_service.dart';

final languageSettingsController = Get.find<LanguageSettingController>();

class LanguageSettingController extends GetxController {
  // Reactive state
  final RxString selectedLanguage = ''.obs; // user selection (persisted)
  final RxString defLangKey = ''.obs; // default from backend
  final RxList<Language> languages = <Language>[].obs;

  final RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;
  RxBool get isLoadingRx => _isLoading;
  static const String selectedLanguageKey = 'selectedLanguage';

  // ----------------------------------------------------------------------------
  // Lifecycle
  // ----------------------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    // Ensure GetStorage is ready (do this once in app bootstrap ideally)
    try {
      await GetStorage.init();
    } catch (_) {}
    await fetchLanguages(); // sets selectedLanguage + defLangKey safely
  }

  // ----------------------------------------------------------------------------
  // Fetch & initialization
  // ----------------------------------------------------------------------------
  Future<void> fetchLanguages() async {
    print('🔄 [LanguageController] Starting fetchLanguages...');
    _isLoading.value = true;

    try {
      final deviceLang = Get.deviceLocale?.languageCode ?? 'en';
      print('📱 [LanguageController] Device language: $deviceLang');

      final languageService = LanguageService();

      // Network fetch (add timeout to avoid hangs)
      print('⏳ [LanguageController] Fetching languages with 15s timeout...');
      final fetched = await languageService
          .fetchLanguages(langCode: deviceLang)
          .timeout(const Duration(seconds: 15));

      print(
          '📦 [LanguageController] Received ${fetched.length ?? 0} languages');
      languages.assignAll(fetched ?? <Language>[]);
      print(
          '📦 [LanguageController] Languages list now has ${languages.length} items');

      // Determine backend default (status == true), else first, else 'en'
      final defaultFromBackend = _safePickDefaultLanguageCode(languages);
      defLangKey.value = defaultFromBackend;
      print(
          '🎯 [LanguageController] Default language from backend: $defaultFromBackend');

      // Read persisted selection; fall back to default/backend/device/en
      final box = GetStorage();
      final savedLang = box.read(selectedLanguageKey) as String?;
      print(
          '💾 [LanguageController] Saved language preference: ${savedLang ?? "none"}');

      final resolved = _resolveSelectedCode(
        saved: savedLang,
        backendDefault: defLangKey.value,
        device: deviceLang,
        have: languages,
      );
      selectedLanguage.value = resolved;
      box.write(selectedLanguageKey, resolved);

      print('✅ [LanguageController] Selected language: $resolved');
      print('✅ [LanguageController] Language initialization complete!');
    } catch (e, stackTrace) {
      print('❌ [LanguageController] Error fetching language data: $e');
      print('❌ [LanguageController] Stack trace: $stackTrace');

      // Fail-safe: empty list → use device or 'en'
      if (languages.isEmpty) {
        print(
            '⚠️ [LanguageController] Languages list is empty, using fallback');
        final deviceLang = Get.deviceLocale?.languageCode ?? 'en';
        defLangKey.value = deviceLang;
        selectedLanguage.value = deviceLang;
        GetStorage().write(selectedLanguageKey, selectedLanguage.value);
        print('⚠️ [LanguageController] Fallback language set to: $deviceLang');
      } else {
        print(
            '⚠️ [LanguageController] Error occurred but languages list has ${languages.length} items');
      }
    } finally {
      _isLoading.value = false;
      print(
          '🏁 [LanguageController] fetchLanguages completed. isLoading = false');
    }
  }

  // ----------------------------------------------------------------------------
  // Public API
  // ----------------------------------------------------------------------------
  void changeLanguage(String newLanguage) {
    // only accept codes that exist (or allow any and fallback in getters)
    selectedLanguage.value = newLanguage;
    GetStorage().write(selectedLanguageKey, newLanguage);
    // If you use GetX localization system, also:
    // Get.updateLocale(Locale(newLanguage));
    update(); // notify classic GetBuilders, not required for Obx
  }

  /// Safe translation lookup with multi-level fallback
  String getTranslation(String key) {
    if (key.isEmpty) return '';

    // 0) nothing loaded → return key
    if (languages.isEmpty) {
      if (key == 'Something Went Wrong! Try again') {
        return 'Something Went Wrong! Try again';
      }
      print('⚠️ [Translation] No languages loaded, returning key: $key');
      return key;
    }

    if (key == 'Something Went Wrong! Try again') {
      return 'Something Went Wrong! Try again';
    }

    // 1) try selected language
    final langSel = _findByCode(languages, selectedLanguage.value);
    final vSel = langSel?.translateKeyValues[key];
    if (_isNonEmpty(vSel)) return vSel!;

    // 2) try backend default
    final langDef = _findByCode(languages, defLangKey.value);
    final vDef = langDef?.translateKeyValues[key];
    if (_isNonEmpty(vDef)) return vDef!;

    // 3) try 'en' if present
    final langEn = _findByCode(languages, 'en');
    final vEn = langEn?.translateKeyValues[key];
    if (_isNonEmpty(vEn)) return vEn!;

    // 4) last resort: first language that has the key
    for (final l in languages) {
      final vv = l.translateKeyValues[key];
      if (_isNonEmpty(vv)) return vv!;
    }

    return key;
  }

  /// Locale for GetMaterialApp.locale
  Locale get currentLocale {
    final code = selectedLanguage.value.isNotEmpty
        ? selectedLanguage.value
        : (defLangKey.value.isNotEmpty
            ? defLangKey.value
            : (Get.deviceLocale?.languageCode ?? 'en'));

    return Locale(code);
  }

  /// UI text direction (no side effects; no updates here)
  TextDirection get languageDirection {
    final sel = _findByCode(languages, selectedLanguage.value) ??
        _findByCode(languages, defLangKey.value) ??
        _findByCode(languages, 'en');

    final dir = sel?.dir ?? 'ltr';
    return dir.toLowerCase() == 'rtl' ? TextDirection.rtl : TextDirection.ltr;
  }

  // ----------------------------------------------------------------------------
  // Helpers (pure, no side effects)
  // ----------------------------------------------------------------------------
  Language? _findByCode(List<Language> list, String code) {
    if (code.isEmpty || list.isEmpty) return null;
    try {
      return list.firstWhere((l) => l.code == code);
    } catch (_) {
      return null;
    }
  }

  String _safePickDefaultLanguageCode(List<Language> list) {
    if (list.isEmpty) return 'en';
    // prefer status==true
    final withStatus = list.where((l) => l.status == true).toList();
    if (withStatus.isNotEmpty) return withStatus.first.code;

    // else prefer 'en' if present
    final en = _findByCode(list, 'en');
    if (en != null) return en.code;

    // else first item
    return list.first.code;
  }

  String _resolveSelectedCode({
    required String? saved,
    required String backendDefault,
    required String device,
    required List<Language> have,
  }) {
    String pick = (saved ?? '').trim();
    bool exists(String c) => _findByCode(have, c) != null;

    if (exists(pick)) return pick;
    if (exists(backendDefault)) return backendDefault;
    if (exists(device)) return device;
    if (exists('en')) return 'en';
    return have.isNotEmpty ? have.first.code : 'en';
  }

  bool _isNonEmpty(String? v) => v != null && v.trim().isNotEmpty;
}
