import 'package:peacepay/utils/basic_screen_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../backend/local_storage/local_storage.dart';
import '../../../controller/auth/pin_Controller.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';



class CreateAndConfirmPinScreen extends StatelessWidget {
  final PinController controller = Get.put(PinController());

  CreateAndConfirmPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pinTextController = TextEditingController(text: controller.pin.value);
    final confirmPinTextController =
    TextEditingController(text: controller.confirmPin.value);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Security PIN'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Secure Your Account',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please create a 6-digit PIN to protect access to your wallet.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 24.h),

            // Enter PIN Section
            Text("Enter PIN", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 10.h),
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
            Align(
              alignment: Alignment.centerRight,
              child: Obx(() => IconButton(
                icon: Icon(
                  controller.isPinObscured.value ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: controller.togglePinVisibility,
              )),
            ),

            SizedBox(height: 24.h),

            // Confirm PIN Section
            Text("Confirm PIN", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 10.h),
            Obx(() => PinCodeTextField(
              appContext: context,
              length: 6,
              obscureText: controller.isConfirmPinObscured.value,
              obscuringCharacter: '●',
              animationType: AnimationType.fade,
              controller: confirmPinTextController,
              onChanged: controller.setConfirmPin,
              keyboardType: TextInputType.number,
              pinTheme: _buildPinTheme(),
              animationDuration: const Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
            )),
            Align(
              alignment: Alignment.centerRight,
              child: Obx(() => IconButton(
                icon: Icon(
                  controller.isConfirmPinObscured.value ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: controller.toggleConfirmPinVisibility,
              )),
            ),

            SizedBox(height: 16.h),

            // Error Message
            Obx(() => controller.error.value == null
                ? const SizedBox.shrink()
                : Text(
              controller.error.value!,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            )),

            SizedBox(height: 24.h),

            // Submit Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading
                    ? null
                    : () async {
                  await controller.createPinProcess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: controller.isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text('Set PIN', style: TextStyle(fontSize: 16.sp),),

              ),
            )),
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
