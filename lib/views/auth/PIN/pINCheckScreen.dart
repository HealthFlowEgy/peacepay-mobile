import 'package:peacepay/utils/basic_screen_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../controller/auth/checkPinCode.dart';
import '../../../routes/routes.dart';


class CheckPinScreen extends StatelessWidget {
  final CheckPinController controller = Get.put(CheckPinController());
  final int? index;
  CheckPinScreen({super.key,required this.index,});

  @override
  Widget build(BuildContext context) {
    final pinTextController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Enter your PIN", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Obx(() => PinCodeTextField(
              appContext: context,
              length: 6,
              obscureText: controller.isPinObscured.value,
              obscuringCharacter: '●',
              animationType: AnimationType.fade,
              controller: pinTextController,
              onChanged: controller.setPin,
              keyboardType: TextInputType.number,
              pinTheme: _buildPinTheme(),
              animationDuration: const Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
            )),
            SizedBox(height: 15.h),
            Obx(() => IconButton(
              icon: Icon(controller.isPinObscured.value
                  ? Icons.visibility_off
                  : Icons.visibility),
              onPressed: controller.togglePinVisibility,
            )),
            Obx(() => controller.error.value == null
                ? SizedBox.shrink()
                : Text(
              controller.error.value!,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            )),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () async {
                await controller.checkPinProcess(screenIndex:index!);
              },
              child: Text('Verify PIN',style: TextStyle(
                fontSize: 16.sp
              ),),
            ),
          ],
        ),
      ),
    );
  }
  PinTheme _buildPinTheme() {
    return PinTheme(
      shape: PinCodeFieldShape.box,
      borderRadius: BorderRadius.circular(6.r),
      fieldHeight: 50.h,
      fieldWidth: 45.w,
      activeFillColor: Colors.white,
      inactiveFillColor: Colors.white,
      selectedFillColor: Colors.grey.shade100,
      inactiveColor: Colors.grey,
      activeColor: Colors.blue,
      selectedColor: Colors.blue,
    );
  }
}
