import 'package:pin_code_fields/pin_code_fields.dart';

import '../../utils/basic_widget_imports.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCodeWidget extends StatelessWidget {
  const PinCodeWidget({
    super.key,
    required this.textController,   // parent-owned controller
    this.mobileController,
    this.length = 4,
  });

  final TextEditingController textController;
  final String? mobileController;
  final int length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.zero,
      child: Center(
        child: PinCodeTextField(
          appContext: context,
          controller: textController,
          autoDisposeControllers: false,   // you pass a parent-owned controller
          length: 4,
          keyboardType: TextInputType.number,
          cursorColor: theme.primaryColor,

          // ✅ SHOW NUMBERS
          obscureText: false,              // make sure this is false

          // ✅ CONTRASTING DIGIT COLOR (white over primary fill)
          textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),

          enableActiveFill: true,
          animationType: AnimationType.fade,
          animationDuration: const Duration(milliseconds: 120),

          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            fieldHeight: 45,
            fieldWidth: 40,
            borderRadius: BorderRadius.circular(5),

            // borders
            borderWidth: 1,
            activeBorderWidth: 1,
            selectedBorderWidth: 1,
            inactiveColor: theme.primaryColor.withOpacity(.6),
            selectedColor: theme.primaryColor,
            errorBorderColor: theme.primaryColor.withOpacity(.7),
            disabledColor: theme.primaryColor.withOpacity(.7),
            activeColor: theme.primaryColor, // border when active

            // fills
            activeFillColor: theme.primaryColor,      // filled box when active
            selectedFillColor: theme.primaryColor,    // filled when selected
            inactiveFillColor: theme.primaryColor.withOpacity(.3), // lighter when inactive
          ),

          onChanged: (v) {},
          onCompleted: (v) {
            if (v.length == 4) FocusManager.instance.primaryFocus?.unfocus();
          },
        )
        ,
      ),
    );
  }
}
