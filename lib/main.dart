import 'package:peacepay/routes/routes.dart';
import 'package:peacepay/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'Translation/fallback_translation.dart';
import 'backend/utils/maintenance/maintenance_dialog.dart';
import 'controller/before_auth/basic_settings_controller.dart';
import 'language/english.dart';
import 'language/language_controller.dart';
import 'widgets/others/global_error_screen.dart';

/// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  // Ensure Flutter engine is initialized before any async / platform calls
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permissions (iOS)
  await _requestNotificationPermissions();

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

  // Set global error widget
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return GlobalErrorScreen(errorDetails: details);
  };

  runApp(MyApp(savedTheme: savedTheme));
}

/// Request notification permissions for iOS
Future<void> _requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Get FCM token for this device
  String? token = await messaging.getToken();
  print('FCM Token: $token');

  // Listen for token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('FCM Token refreshed: $newToken');
    // TODO: Send token to your backend server
  });
}

/// Root widget.
/// Keeps GetMaterialApp **inside an Obx** so locale & direction are reactive.
/// NOTE: We do not use `initialBinding` to avoid accidental double `Get.put(...)`.
class MyApp extends StatefulWidget {
  final String savedTheme;
  const MyApp({super.key, required this.savedTheme});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showInAppNotification(message);
      }
    });

    // Handle when app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked! ${message.data}');
      _handleNotificationNavigation(message);
    });

    // Check if app was opened from a terminated state via notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state via notification');
        _handleNotificationNavigation(message);
      }
    });
  }

  void _showInAppNotification(RemoteMessage message) {
    if (Get.context != null) {
      Get.snackbar(
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? '',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.blue.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
    }
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'peacelink_created':
      case 'peacelink_approved':
      case 'peacelink_delivered':
      case 'peacelink_released':
        final escrowId = data['escrow_id'];
        if (escrowId != null) {
          // Navigate to escrow details
        }
        break;
      case 'dispute_opened':
      case 'dispute_resolved':
        // Navigate to dispute screen
        break;
      case 'cashout_completed':
      case 'cashout_failed':
        // Navigate to transactions
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve initial theme once (switch/case is clearer than nested ifs)
    final ThemeData initialTheme = switch (widget.savedTheme) {
      'buyer' => Themes.buyer,
      'seller' => Themes.seller,
      _ => Themes.delivery,
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
              translations: FallbackTranslation(), // your translations mapper
              fallbackLocale: const Locale('en'), // safe default
              locale: lang.currentLocale, // <-- REACTIVE (Obx above)

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
                final textDir =
                    lang.isLoading ? TextDirection.ltr : lang.languageDirection;

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
