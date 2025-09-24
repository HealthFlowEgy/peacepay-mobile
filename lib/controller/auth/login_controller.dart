
import 'package:peacepay/backend/local_storage/local_storage.dart';
import 'package:peacepay/controller/auth/register_otp_controller.dart';

import '../../backend/backend_utils/logger.dart';
import '../../backend/models/auth/forgot_send_otp_model.dart';
import '../../backend/models/auth/login_model.dart';
import '../../backend/services/api_services.dart';
import '../../routes/routes.dart';
import '../../utils/basic_widget_imports.dart';
import '../../views/auth/register_otp_screen/register_otp_screen.dart';
import '../../views/web_view/web_view_screen.dart';
import '../before_auth/basic_settings_controller.dart';


final log = logger(LoginController);

class LoginController extends GetxController{

  final formKey = GlobalKey<FormState>();
  final forgotPassFormKey = GlobalKey<FormState>();
  final forgotEmailController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxString _errorMessage = "".obs;
  String get errorMessage => _errorMessage.value;


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    super.dispose();
  }





  onLoginProcess() async{
    if(formKey.currentState!.validate()){
      await signInProcess();
    }
  }
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  late LoginModel _signInModel;
  LoginModel get signInModel => _signInModel;


  Future<LoginModel?> signInProcess() async {
    _isLoading.value = true;
    update();

    try {
      final mobile = emailController.text.trim();

      // 👉 Local validation
      if (!mobile.startsWith("01")) {
        _errorMessage.value = "Mobile number must start with 01";
        return null;
      } else {
        _errorMessage.value = ""; // clear old error if any
      }

      Map<String, dynamic> inputBody = {
        'mobile': mobile,
      };

      final value = await ApiServices.signInApi(body: inputBody);

      // If API returned null, error is already shown inside signInApi
      if (value == null) return null;

      _signInModel = value;
      final user = _signInModel.data.user;

      // Save token
      LocalStorage.saveToken(token: _signInModel.data.token);

      // Handle navigation flow
      if (user.smsVerified == 0) {
        Get.put(RegisterOTPController());
        Get.to(() => RegisterOTPScreen(mobileNumber: mobile));
      } else if (!user.hasPin) {
        Get.toNamed(Routes.createPINScreen);
      } else {
        if (user.kycVerified == 0 &&
            Get.find<BasicSettingsController>().basicSettingModel.data.kycStatus == 1) {
          Get.toNamed(Routes.kycFormScreen);
        } else {
          if (user.twoFactorStatus == 1 && user.twoFactorVerified == 0) {
            Get.toNamed(Routes.faVerifyScreen);
          } else {
            _goToSavedUser(_signInModel);
          }
        }
      }

      return _signInModel;
    } catch (e) {
      log.e("🐞 Error in signInProcess: $e");
      return null;
    } finally {
      _isLoading.value = false;
      update();
    }
  }
  void onTermsAndConditionWebView(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const WebViewScreen(
              beforeAuth: true,
              appTitle: Strings.termsOfUse,
              link:
              "https://peacepay.me/terms-and-conditions",
            )));
  }
  void privacyPolicyWebView(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const WebViewScreen(
              beforeAuth: true,
              appTitle: Strings.privacyPolicy,
              link:
              "https://peacepay.me/privacy",
            )));
  }
  void _goToSavedUser(LoginModel signInModel) {
    debugPrint("Verified => Save User and Dashboard");

    LocalStorage.isLoginSuccess(isLoggedIn: true);
    LocalStorage.saveEmail(email: emailController.text);
    Get.offAllNamed(Routes.dashboardScreen);
  }
  void onForgotPassProcess() async{
    if(forgotPassFormKey.currentState!.validate()) {
      await sendOTPProcess().then((value) {
        if(value != null) {
        }
      });
    }
  }




  final _isForgotLoading = false.obs;
  bool get isForgotLoading => _isForgotLoading.value;

  late ForgetSendOtpModel? _forgotModel;
  ForgetSendOtpModel? get forgotModel => _forgotModel;

  late RxString token;

  Future<ForgetSendOtpModel?> sendOTPProcess() async {
    _isForgotLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      'credentials': forgotEmailController.text,
    };

    await ApiServices.forgotPinSendOTPApi(body: inputBody).then((value) {
      _forgotModel = value!;
      token = _forgotModel!.data.token.obs;
      Get.toNamed(Routes.forgotOTPScreen);
      update();
    }).catchError((onError) {
      log.e(onError);
    });

    _isForgotLoading.value = false;
    update();
    return _forgotModel;
  }


  goToRegisterScreen() {
    Get.toNamed(Routes.registerScreen);
  }
}