import 'dart:core';
import 'package:peacepay/utils/basic_screen_imports.dart';
import 'package:peacepay/widgets/others/custom_loading_widget.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../routes/routes.dart';
import '../dashboard/my_wallets_screens/add_money_screen/add_money_confirm_screen.dart';

class WebViewScreen extends StatefulWidget {
  final String link, appTitle;
  final Function? onFinished;
  final bool beforeAuth;

  const WebViewScreen({
    super.key,
    required this.link,
    required this.appTitle,
    this.onFinished,
    this.beforeAuth = false,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoading = false;
  late InAppWebViewController webController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          widget.beforeAuth
              ? Get.offNamed(Routes.loginScreen)
              : Get.offAllNamed(Routes.dashboardScreen);
          return false;
        },
        child: Scaffold(
          appBar: PrimaryAppBar(
            title: widget.appTitle,
            onTap: () {
              widget.beforeAuth
                  ? Get.offNamed(Routes.loginScreen)
                  : Get.offAllNamed(Routes.dashboardScreen);
            },
          ),
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.link)),
                onWebViewCreated: (controller) {
                  webController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() => isLoading = true);
                  if (widget.onFinished != null) {
                    widget.onFinished!(url);
                  }
                },
                onLoadStop: (controller, url) async {
                  setState(() => isLoading = false);

                  if (url != null) {
                    final currentUrl = url.toString();
                    if (currentUrl.startsWith(
                            "http://stg.peacepay.me/payment/process") ||
                        currentUrl.contains("/payment/process")) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddMoneyConfirmScreen(
                                    message: Strings.addMoneyConfirmationMSG,
                                    // onApproval: true,
                                    onOkayTap: () =>
                                        Get.offAllNamed(Routes.dashboardScreen),
                                  )));
                      return;
                    }
                  }
                },
              ),
              Visibility(
                visible: isLoading,
                child: const CustomLoadingWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
