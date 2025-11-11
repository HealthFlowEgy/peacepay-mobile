import 'package:peacepay/utils/basic_screen_imports.dart';
import 'package:peacepay/utils/responsive_layout.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';

import '../../../backend/models/basic_settings_model.dart';
import '../../../backend/services/api_endpoint.dart';
import '../../../widgets/others/custom_cached_network_image.dart';
import '../../../controller/before_auth/basic_settings_controller.dart';
import '../../../controller/before_auth/onboard_screen_controller.dart';
import '../../../utils/svg_assets.dart';
import '../../../widgets/text_labels/title_sub_title_widget.dart';
class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final basicController = Get.find<BasicSettingsController>();

    return ResponsiveLayout(
      mobileScaffold: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GetBuilder<BasicSettingsController>(
          builder: (c) {
            // 1) If still loading, show nothing (or a loader if you want)
            if (c.isLoading) {
              return const SizedBox.shrink();
            }

            // 2) Safely access the late model after fetch
            BasicSettingModel model;
            try {
              model = c.basicSettingModel; // <- no .value here
            } catch (_) {
              // late field not set yet or API failed
              return const SizedBox.shrink();
            }

            final data = model.data;
            final screens = data.onboardScreen;
            if (screens.isEmpty) {
              return const SizedBox.shrink();
            }

            // 3) Build UI; use Obx only for the changing index
            return Stack(
              children: [
                Obx(() {
                  final maxIdx = screens.length - 1;
                  var idx = c.selectedIndex.value;
                  if (idx < 0) idx = 0;
                  if (idx > maxIdx) idx = maxIdx;

                  final imageUrl =
                      "${ApiEndpoint.mainDomain}/${data.imagePath}/${screens[idx].image}";
                  return CustomCachedNetworkImage(imageUrl: imageUrl);
                }),

                Obx(() {
                  final maxIdx = screens.length - 1;
                  var idx = c.selectedIndex.value;
                  if (idx < 0) idx = 0;
                  if (idx > maxIdx) idx = maxIdx;

                  return Positioned(
                    bottom: 150.sp,
                    width: MediaQuery.of(context).size.width,
                    child: TitleSubTitleWidget(
                      title: screens[idx].title,
                      subTitle: screens[idx].subTitle,
                    ),
                  );
                }),

                Positioned(
                  bottom: 100.sp,
                  right: 0,
                  left: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Dimensions.radius * 10),
                    onTap: () {
                      final maxIdx = screens.length - 1;
                      final idx = c.selectedIndex.value;
                      if (idx >= maxIdx) {
                        Get.find<OnboardController>().goNextBTNClicked();
                      } else {
                        c.selectedIndex.value = idx + 1;
                      }
                    },
                    child: Animate(
                      effects: const [FadeEffect(), ScaleEffect()],
                      child: SvgPicture.string(
                        SVGAssets.circleButton,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

