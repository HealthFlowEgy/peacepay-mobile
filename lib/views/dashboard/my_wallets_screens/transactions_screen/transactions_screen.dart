import 'package:peacepay/backend/backend_utils/no_data_widget.dart';
import 'package:peacepay/utils/basic_screen_imports.dart';
import 'package:peacepay/utils/responsive_layout.dart';
import 'package:peacepay/widgets/others/custom_loading_widget.dart';

import '../../../../controller/dashboard/btm_navs_controller/home_controller.dart';
import '../../../../controller/dashboard/my_wallets/transactions_controller.dart';
import '../../../../routes/routes.dart';
import '../../../../widgets/appbar/back_button.dart';
import '../../../../widgets/list_tile/transaction_tile_widget.dart';

class TransactionsScreen extends GetView<TransactionsController> {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveLayout(
        mobileScaffold: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: TitleHeading2Widget(
                text: Strings.transactions,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
              leading:  BackButtonWidget(
                onTap: (){
                  Get.offAllNamed(Routes.dashboardScreen,);
                },
              ) ,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
            ),
            body: Obx(() => controller.isLoading
                ? const CustomLoadingWidget()
                : _body(context))),
      ),
    );
  }

  _body(BuildContext context) {
    return controller.historyList.isEmpty
        ? const Column(children: [NoDataWidget()])
        : Stack(
            children: [
              ListView.separated(
                  controller: controller.scrollController,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    right: Dimensions.paddingSizeHorizontal * .85,
                    left: Dimensions.paddingSizeHorizontal * .85,
                    bottom: Dimensions.paddingSizeVertical * .85,
                  ),
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Obx(() => TransactionTileWidget(

                      onTap: () {
                            if (controller.openTileIndex.value != index) {
                              controller.openTileIndex.value = index;
                            } else {
                              controller.openTileIndex.value = -1;
                            }
                          },
                          expansion: controller.openTileIndex.value == index,
                          inDashboard: false,
                          transaction: controller.historyList[index],
                        ));
                  },
                  separatorBuilder: (context, i) =>
                      verticalSpace(Dimensions.marginSizeVertical * .3),
                  itemCount: controller.historyList.length),
              Obx(() => controller.isMoreLoading
                  ? const CustomLoadingWidget()
                  : const SizedBox()),
            ],
          );
  }
}
