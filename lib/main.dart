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
import 'language/english.dart';
import 'language/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await GetStorage.init();
  //   Language controller before runApp
  Get.put(LanguageSettingController(), permanent: true);
  Get.put(SystemMaintenanceController(), permanent: true);

  InternetCheckDependencyInjection.init();

  final savedTheme = Themes().savedUserTheme;
  runApp(MyApp(savedTheme: savedTheme));
}

// This widget is the root of your application.
class MyApp extends StatelessWidget {
  final String savedTheme;
  const MyApp({super.key, required this.savedTheme});


  @override
  Widget build(BuildContext context) {
    ThemeData initialTheme;
    if (savedTheme == 'buyer') {
      initialTheme = Themes.buyer;
    } else if (savedTheme == 'seller') {
      initialTheme = Themes.seller;
    } else {
      initialTheme = Themes.delivery;
    }
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, child) => GetMaterialApp(

        title: Strings.appName,
        debugShowCheckedModeBanner: false,
        theme: initialTheme,
        // darkTheme: Themes.dark,
        // themeMode:  themes.themeMode,
        navigatorKey: Get.key,
        initialRoute: Routes.splashScreen,
        getPages: Routes.list,
        // translations: LocalString(),
        locale: languageSettingsController.currentLocale,/// Advice from Eng: A.Adel
        // locale: const Locale('en'),
        translations: FallbackTranslation(),
        fallbackLocale: const Locale('en'),
        initialBinding: BindingsBuilder(
              () {
                Get.put(SystemMaintenanceController(), permanent: true);
            Get.put(LanguageSettingController(),permanent: true);
          },
        ),
        builder: (context, widget) {
          ScreenUtil.init(context);
          return Obx(() => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: Directionality(
              textDirection: Get.find<LanguageSettingController>().isLoading
                  ? TextDirection.ltr
                  // : TextDirection.ltr,
                  : Get.find<LanguageSettingController>().languageDirection,
              child: widget!,
            ),
          ));
        },
      ),
    );
  }
}
/*
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  // Lock to portrait (optional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await GetStorage.init();

  // Network monitors, etc.
  InternetCheckDependencyInjection.init();

  // Read saved theme before runApp
  final savedTheme = Themes().savedUserTheme;

  runApp(MyApp(savedTheme: savedTheme));
}

class MyApp extends StatelessWidget {
  final String savedTheme;
  const MyApp({super.key, required this.savedTheme});

  ThemeData _resolveInitialTheme() {
    if (savedTheme == 'buyer') return Themes.buyer;
    if (savedTheme == 'seller') return Themes.seller;
    return Themes.delivery;
  }

  Locale _initialLocaleSafely() {
    // In case initialBinding hasn't registered the controller yet,
    // fall back to English to avoid a crash.
    try {
      return Get.find<LanguageSettingController>().currentLocale;
    } catch (_) {
      return const Locale('en');
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialTheme = _resolveInitialTheme();

    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, __) => GetMaterialApp(
        title: Strings.appName,
        debugShowCheckedModeBanner: false,
        theme: initialTheme,
        navigatorKey: Get.key,
        initialRoute: Routes.splashScreen,
        getPages: Routes.list,

        // Locale & i18n
        locale: _initialLocaleSafely(),
        translations: FallbackTranslation(), // TODO: ensure this exists
        fallbackLocale: const Locale('en'),

        // Prefer binding here (remove duplicate Get.put in main)
        initialBinding: BindingsBuilder(() {
          Get.put(SystemMaintenanceController(), permanent: true);
          Get.put(LanguageSettingController(), permanent: true);
        }),

        // Global wrapper → auto-lock + input hooks + preserves your Obx/RTL/MediaQuery
        builder: (context, widget) {
          ScreenUtil.init(context);

          final content = Obx(() => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: Directionality(
              textDirection: Get.find<LanguageSettingController>().isLoading
                  ? TextDirection.ltr
                  : Get.find<LanguageSettingController>().languageDirection,
              child: widget ?? const SizedBox.shrink(),
            ),
          ));

          return AppActivityWrapper(child: content);
        },
      ),
    );
  }
}

/// Wraps the whole app to:
/// - Start/arm inactivity timer globally
/// - Listen for lock events and push the LockScreen once
/// - Reset timer on any pointer/keyboard activity
class AppActivityWrapper extends StatefulWidget {
  final Widget child;
  const AppActivityWrapper({super.key, required this.child});

  @override
  State<AppActivityWrapper> createState() => _AppActivityWrapperState();
}

class _AppActivityWrapperState extends State<AppActivityWrapper> {
  late final InactivityService _inactivity =
  InactivityService()..timeout = const Duration(minutes: 50); // GLOBAL TIMEOUT
  StreamSubscription<void>? _sub;
  bool _lockOpen = false;

  @override
  void initState() {
    super.initState();
    _inactivity.start();

    _sub = _inactivity.onLock.listen((_) async {
      if (!_inactivity.isLocked || _lockOpen) return;
      _lockOpen = true;

      // Push biometrics-only lock overlay; returns to same screen on success
      await Get.to(
            () => const LockScreen(),
        fullscreenDialog: true,
        preventDuplicates: true,
      );

      // When LockScreen pops (after successful auth), allow future locks again
      _lockOpen = false;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Capture inputs globally to reset inactivity timer
    return Listener(
      onPointerDown: (_) => _inactivity.reset(),
      onPointerMove: (_) => _inactivity.reset(),
      onPointerSignal: (_) => _inactivity.reset(),
      child: Focus(
        autofocus: true,
        onKeyEvent: (_, __) {
          _inactivity.reset();
          return KeyEventResult.ignored;
        },
        child: widget.child,
      ),
    );
  }
}
* */
