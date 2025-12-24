import 'package:peacepay/widgets/others/custom_loading_widget.dart';

import '../../controller/before_auth/basic_settings_controller.dart';
import '../../utils/basic_widget_imports.dart';
import 'custom_cached_network_image.dart';

class AppIconWidget extends StatelessWidget {
  const AppIconWidget({super.key, this.height, this.width});

  final double? height, width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHorizontal * 3,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          reverse: true, // keeps bottom aligned
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // keyboard padding
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                var controller = Get.find<BasicSettingsController>();
                if (controller.isLoading) {
                  return const CustomLoadingWidget();
                } else if (controller.appIconLink.isEmpty) {
                  // Fallback if API failed or link is missing
                  return Icon(
                    Icons.image_not_supported,
                    size: height ?? 80,
                    color: Colors.grey,
                  );
                }
                return CustomCachedNetworkImage(
                  imageUrl: controller.appIconLink,
                  height: height ?? 80,
                  width: width ?? 100.w,
                  radius: 0,
                  isCircle: false,
                );
              }),
              verticalSpace(
                  height == null ? Dimensions.paddingSizeVertical : 0),
            ],
          ),
        ),
      ),
    );
  }
}
