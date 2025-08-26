
import 'package:adescrow_app/backend/local_storage/local_storage.dart';
import 'package:adescrow_app/controller/auth/register_otp_controller.dart';

import '../../backend/backend_utils/logger.dart';
import '../../backend/models/auth/forgot_send_otp_model.dart';
import '../../backend/models/auth/login_model.dart';
import '../../backend/services/api_services.dart';
import '../../routes/routes.dart';
import '../../utils/basic_widget_imports.dart';
import '../../views/auth/register_otp_screen/register_otp_screen.dart';
import '../before_auth/basic_settings_controller.dart';


final log = logger(LoginController);

class LoginController extends GetxController{
  final formKey = GlobalKey<FormState>();
  final forgotPassFormKey = GlobalKey<FormState>();


  final forgotEmailController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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


  Future<LoginModel> signInProcess() async {
    _isLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      'mobile': emailController.text,
      // 'password': passwordController.text,
    };

    await ApiServices.signInApi(body: inputBody).then((value) {
      _signInModel = value!;

      int kycVerified = _signInModel.data.user.kycVerified;
      int twoFaStatus = _signInModel.data.user.twoFactorStatus;
      int twoFaVerified = _signInModel.data.user.twoFactorVerified;
      LocalStorage.saveToken(token: _signInModel.data.token);
      if (_signInModel.data.user.smsVerified == 0) {
        Get.put(RegisterOTPController());
        Get.to(() => RegisterOTPScreen(
          mobileNumber:emailController.text
        ));
      }else if(_signInModel.data.user.hasCode == false){
        Get.toNamed(Routes.createPINScreen);
      }
      else {
        debugPrint("Phone Verified => Login Process :: ${twoFaStatus.toString()} :: ${twoFaVerified.toString()}");
        debugPrint("Phone Verified => Login Process :: ${twoFaStatus.toString()} :: ${twoFaVerified.toString()}");
        debugPrint("Phone Verified => Login Process :: ${twoFaStatus.toString()} :: ${twoFaVerified.toString()}");

        if(kycVerified == 0 && Get.find<BasicSettingsController>().basicSettingModel.data.kycStatus == 1){
          Get.toNamed(Routes.kycFormScreen);
        }
        else{
          if (twoFaStatus == 1 && twoFaVerified == 0) {
            Get.toNamed(Routes.faVerifyScreen);
          } else {
            _goToSavedUser(_signInModel);
          }
        }

        _isLoading.value = false;
        update();
      }

      update();
    }).catchError((onError) {
      log.e(onError);
    });

    _isLoading.value = false;
    update();
    return _signInModel;
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

    await ApiServices.forgotPasswordSendOTPApi(body: inputBody).then((value) {
      _forgotModel = value!;
      token = _forgotModel!.data.user.token.obs;
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