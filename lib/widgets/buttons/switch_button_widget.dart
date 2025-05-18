import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/dashboard/profiles/update_profile_controller.dart';
import '../../language/language_controller.dart';
import '../../utils/basic_widget_imports.dart';
import '../../utils/theme.dart';

class SwitchButtonWidget extends StatefulWidget {
  const SwitchButtonWidget({
    super.key,
    this.onTap,
    this.isScaffold = false,
  });

  final Function(String)? onTap; // returns 'buyer', 'seller' or 'delivery'
  final bool isScaffold;

  @override
  State<SwitchButtonWidget> createState() => _SwitchButtonWidgetState();
}

class _SwitchButtonWidgetState extends State<SwitchButtonWidget> {
  // Track selected theme, default to 'buyer' or read from controller if needed
  String selectedTheme = Get.find<UpdateProfileController>().typeIsBuyer.value ? 'buyer' : 'seller';

  // You can add delivery default if needed

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _btn(context, 'Buyer', 'buyer'),
        _btn(context, 'Seller', 'seller'),
        _btn(context, 'Delivery', 'delivery'),
      ],
    );
  }

  Widget _btn(BuildContext context, String label, String themeKey) {
    final bool isSelected = selectedTheme == themeKey;
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius),
      onTap: () {
        setState(() {
          selectedTheme = themeKey;

          // Update your controller if needed:
          if (themeKey == 'buyer') {
            Get.find<UpdateProfileController>().typeIsBuyer.value = true;
          } else if (themeKey == 'seller') {
            Get.find<UpdateProfileController>().typeIsBuyer.value = false;
          }
          // You can add delivery related controller updates here if you want

          // Switch theme globally
          Themes().changeUserTheme(themeKey);

          // Call optional callback with selected theme key
          widget.onTap?.call(themeKey);
        });
      },
      child: Container(
        alignment: Alignment.center,
        height: Dimensions.buttonHeight * 0.9,
        width: Dimensions.widthSize * 6,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : widget.isScaffold
              ? Theme.of(context).scaffoldBackgroundColor
              : CustomColor.whiteColor,
          borderRadius: BorderRadius.circular(Dimensions.radius),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
        ),
        child: TitleHeading3Widget(
          text: label,
          fontSize: Dimensions.headingTextSize3 * 0.85,
          color: isSelected ? CustomColor.whiteColor : null,
          opacity: isSelected ? 1 : 0.6,
        ),
      ),
    );
  }
}
