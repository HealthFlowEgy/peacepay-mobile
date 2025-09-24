
import '../../language/language_controller.dart';
import '../../utils/basic_widget_imports.dart';




class RichTextWidget extends StatelessWidget {
  const RichTextWidget({super.key, required this.preText, required this.postText, required this.endText, required this.onPressed,required this.onPressedEnd, this.opacity, this.textAlign});

  final String preText, postText,endText;
  final VoidCallback onPressed;
  final VoidCallback onPressedEnd;
  final double? opacity;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: Get.find<LanguageSettingController>().isLoading
                            ? ""
                            : Get.find<LanguageSettingController>().getTranslation(preText),
                        style: CustomStyle.lightHeading5TextStyle.copyWith(
                          color: CustomColor.primaryLightTextColor.withOpacity(opacity ?? .7),
                        ),
                      ),
                      TextSpan(
                        text: Get.find<LanguageSettingController>().isLoading
                            ? ""
                            : Get.find<LanguageSettingController>().getTranslation(postText),
                        style: CustomStyle.lightHeading5TextStyle.copyWith(
                          color: CustomColor.primaryLightColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  textAlign: textAlign ?? TextAlign.start,
                  overflow: TextOverflow.ellipsis, // prevents overflow
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: onPressedEnd,
          child: Row(
            children: [
              Text.rich(

                TextSpan(
                  children: [
                    TextSpan(
                        text: ' & ',
                        style: CustomStyle.lightHeading5TextStyle.copyWith(
                          color: CustomColor.primaryLightColor,
                          fontWeight: FontWeight.w500,
                        )
                    ),
                    TextSpan(
                        text: Get.find<LanguageSettingController>().isLoading
                            ? ""
                            : Get.find<LanguageSettingController>()
                            .getTranslation(endText),
                        style: CustomStyle.lightHeading5TextStyle.copyWith(
                          color: CustomColor.primaryLightColor,
                          fontWeight: FontWeight.w500,
                        )
                    ),
                  ],
                ),
                textAlign: textAlign ?? TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}