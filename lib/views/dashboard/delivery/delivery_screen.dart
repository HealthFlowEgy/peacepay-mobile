import 'package:adescrow_app/controller/dashboard/btm_navs_controller/home_controller.dart';
import 'package:adescrow_app/controller/dashboard/btm_navs_controller/profile_controller.dart';
import 'package:adescrow_app/controller/dashboard/delivery/delivery_controller.dart';
import 'package:adescrow_app/controller/dashboard/profiles/update_profile_controller.dart';
import 'package:adescrow_app/utils/responsive_layout.dart';

import '../../../utils/basic_screen_imports.dart';
import '../../../widgets/others/custom_loading_widget.dart';

class DeliveryAgentScreen extends GetView<HomeController> {
  const DeliveryAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileScaffold: Scaffold(
        body: Obx(() => controller.isLoading
        ? const CustomLoadingWidget()
        :Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Delivery Agent',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Wallet Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallet Balance',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          controller.homeModel.data.userWallet[0].balance.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // OTP Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Enter OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Enter OTP release payment',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: controller.otpController,
                          decoration: InputDecoration(
                            hintText: 'Enter OTP',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            minimumSize: const Size.fromHeight(45),
                          ),
                          onPressed: () {
                            controller.releasePaymentProcess(OTP: controller.otpController.text);
                          },
                          child: const Text('Submit',style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                  ),

                   SizedBox(height: 20.h),


                ],
              ),
            ),
          ),
        ),
      )
    ));
  }
}
