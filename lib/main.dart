import 'package:peacepay/routes/routes.dart';
import 'package:peacepay/utils/theme.dart';
import 'package:peacepay/views/auth/PIN/create-ConfirmPinScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'Translation/fallback_translation.dart';
import 'backend/backend_utils/network_check/dependency_injection.dart';
import 'backend/utils/maintenance/maintenance_dialog.dart';
import 'controller/before_auth/basic_settings_controller.dart';
import 'language/english.dart';
import 'language/language_controller.dart';

Future<void> main() async {
  // Ensure Flutter engine is initialized before any async / platform calls
  WidgetsFlutterBinding.ensureInitialized();

  // ScreenUtil needs the size early (prevents first-frame layout jumps)
  await ScreenUtil.ensureScreenSize();

  // Lock the app to portrait (UX consistency; revise if you later add tablet/landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Key–value storage for lightweight persistence (language, theme, flags…)
  await GetStorage.init();

  // Register global controllers ONCE here. Avoid re-putting the same controllers elsewhere.
  Get.put(LanguageSettingController(), permanent: true);
  Get.put(SystemMaintenanceController(), permanent: true);

  // Initialize your app-wide DI / services here (single entry point)
  // InternetCheckDependencyInjection.init();

  // Read theme preference BEFORE runApp to avoid theme flicker
  final savedTheme = Themes().savedUserTheme;
  Get.put(BasicSettingsController(), permanent: true);

  runApp(MyApp(savedTheme: savedTheme));
}

/// Root widget.
/// Keeps GetMaterialApp **inside an Obx** so locale & direction are reactive.
/// NOTE: We do not use `initialBinding` to avoid accidental double `Get.put(...)`.
class MyApp extends StatelessWidget {
  final String savedTheme;
  const MyApp({super.key, required this.savedTheme});

  @override
  Widget build(BuildContext context) {
    // Resolve initial theme once (switch/case is clearer than nested ifs)
    final ThemeData initialTheme = switch (savedTheme) {
      'buyer'  => Themes.buyer,
      'seller' => Themes.seller,
      _        => Themes.delivery,
    };

    // Provide your target design size (Figma/Sketch reference frame)
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, __) {
        // Pull the language controller once.
        // Wrapping GetMaterialApp in Obx will rebuild when language changes.
        final lang = Get.find<LanguageSettingController>();

        return Obx(() => GetMaterialApp(
          title: Strings.appName,
          debugShowCheckedModeBanner: false,

          // Theme setup
          theme: initialTheme,
          // darkTheme: Themes.dark,
          // themeMode: ThemeMode.system, // Optional: if you support system dark mode

          // GetX navigator key (single navigator for the whole app)
          navigatorKey: Get.key,

          // Routing
          initialRoute: Routes.splashScreen,
          getPages: Routes.list,

          // i18n using GetX
          translations: FallbackTranslation(),      // your translations mapper
          fallbackLocale: const Locale('en'),       // safe default
          locale: lang.currentLocale,               // <-- REACTIVE (Obx above)

          // IMPORTANT:
          // - Do NOT re-put controllers in initialBinding (it causes random “white screens”)
          // - Keep single registration in `main()` only.
          // initialBinding: BindingsBuilder(() {}),

          // Builder wraps every page to:
          // 1) Lock text scale factor across the app
          // 2) Apply text direction reactively (RTL/LTR) after language loads
          builder: (context, widget) {
            // Re-init ScreenUtil using the real context
            ScreenUtil.init(context);

            // During language loading, default to LTR to avoid early crashes.
            final textDir = lang.isLoading
                ? TextDirection.ltr
                : lang.languageDirection;

            // Lock text scale factor to 1.0 to keep UI consistent
            final mq = MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            );

            return MediaQuery(
              data: mq,
              child: Directionality(
                textDirection: textDir,
                child: widget!,
              ),
            );
          },
        ));
      },
    );
  }
}