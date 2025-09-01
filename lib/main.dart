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

  // 🔥 Put Language controller before runApp
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
