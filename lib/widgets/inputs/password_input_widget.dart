import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../utils/custom_style.dart';
import '../../utils/dimensions.dart';
import '../../utils/size.dart';
import '../../utils/svg_assets.dart';
import '../text_labels/title_heading4_widget.dart';
class PinInputWidget extends StatefulWidget {
  const PinInputWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.readOnly = false,
    this.focusedBorderWidth = 1.2,
    this.enabledBorderWidth = 1,
    this.color = Colors.transparent,
    this.validator, // 👈 add validator
  });

  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final Color color;
  final double focusedBorderWidth;
  final double enabledBorderWidth;
  final String? Function(String?)? validator; // 👈 add validator callback

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 48,
      textStyle: CustomStyle.lightHeading4TextStyle
          .copyWith(color: Theme.of(context).primaryColor),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.5),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: widget.enabledBorderWidth,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.5),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: widget.focusedBorderWidth,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleHeading4Widget(
          text: widget.hintText.tr,
          fontWeight: FontWeight.w600,
        ),
        verticalSpace(Dimensions.marginBetweenInputBox * .5),
        Row(
          children: [
            Expanded(
              child: Pinput(
                controller: widget.controller,
                length: 6,
                obscureText: isObscured,
                obscuringCharacter: '•',
                readOnly: widget.readOnly,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                keyboardType: TextInputType.number,
                validator: widget.validator, // 👈 use validator
              ),
            ),
            IconButton(
              icon: Opacity(
                opacity: .6,
                child: SvgPicture.string(
                  isObscured ? SVGAssets.eyeSlash : SVGAssets.eye,
                ),
              ),
              onPressed: () => setState(() {
                isObscured = !isObscured;
              }),
            ),
          ],
        ),
      ],
    );
  }
}
