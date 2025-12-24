import '../../controller/dashboard/profiles/update_profile_controller.dart';
import '../../utils/basic_widget_imports.dart';
import '../../utils/theme.dart';

class SwitchButtonWidget extends StatefulWidget {
  const SwitchButtonWidget({
    super.key,
    this.onTap,
    this.isScaffold = false,
  });

  final Function(String)? onTap; // returns 'buyer', 'seller', or 'delivery'
  final bool isScaffold;

  @override
  State<SwitchButtonWidget> createState() => _SwitchButtonWidgetState();
}

class _SwitchButtonWidgetState extends State<SwitchButtonWidget> {
  late String selectedTheme;

  @override
  void initState() {
    super.initState();
    selectedTheme = Get.find<UpdateProfileController>().selectedUserType.value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _btn(context, Strings.buyer, 'buyer'),
        _btn(context, Strings.seller, 'seller'),
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
          // Update controller state
          Get.find<UpdateProfileController>().selectedUserType.value = themeKey;
          // Switch theme globally
          Themes().changeUserTheme(themeKey);
          // Optional callback
          widget.onTap?.call(themeKey);
          Get.find<UpdateProfileController>().setUserType(themeKey);
        });
      },
      child: Container(
        alignment: Alignment.center,
        height: Dimensions.buttonHeight * 0.95,
        width: Dimensions.widthSize * 7,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : widget.isScaffold
                  ? Theme.of(context).scaffoldBackgroundColor
                  : CustomColor.whiteColor,
          borderRadius: BorderRadius.circular(Dimensions.radius),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
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
