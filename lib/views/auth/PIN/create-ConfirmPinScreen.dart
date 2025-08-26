import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../controller/auth/pin_Controller.dart';

class CreateAndConfirmPinScreen extends StatelessWidget {
  final PinController controller = Get.put(PinController());

   CreateAndConfirmPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pinTextController = TextEditingController(text: controller.pin.value);
    final confirmPinTextController =
    TextEditingController(text: controller.confirmPin.value);

    return Scaffold(
      appBar: AppBar(title: Text('Create PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Enter PIN", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Obx(() => PinCodeTextField(
              appContext: context,
              length: 6,
              obscureText: controller.isPinObscured.value,
              obscuringCharacter: '●',
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(4),
                fieldHeight: 40,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.grey.shade200,
                inactiveColor: Colors.grey,
                activeColor: Colors.blue,
                selectedColor: Colors.blue,
              ),
              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              keyboardType: TextInputType.number,
              onChanged: controller.setPin,
              controller: pinTextController,
            )),
            SizedBox(height: 15.h),
            Obx(() => IconButton(
              icon: Icon(controller.isPinObscured.value
                  ? Icons.visibility_off
                  : Icons.visibility),
              onPressed: controller.togglePinVisibility,
            )),
            SizedBox(height: 24),
            Text("Confirm PIN", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Obx(() => PinCodeTextField(
              appContext: context,
              length: 6,
              obscureText: controller.isConfirmPinObscured.value,
              obscuringCharacter: '●',
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(4),
                fieldHeight: 40,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.grey.shade200,
                inactiveColor: Colors.grey,
                activeColor: Colors.blue,
                selectedColor: Colors.blue,
              ),
              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              keyboardType: TextInputType.number,
              onChanged: controller.setConfirmPin,
              controller: confirmPinTextController,
            )),

            SizedBox(height: 24),
            Row(
              children: [
                Obx(() => IconButton(
                  icon: Icon(controller.isConfirmPinObscured.value
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: controller.toggleConfirmPinVisibility,
                )),
              ],
            ),
            Obx(() => controller.error.value == null
                ? SizedBox.shrink()
                : Text(
              controller.error.value!,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            )),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed:()async{
                controller.createPinProcess();
              },
              child: Text('Set PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
