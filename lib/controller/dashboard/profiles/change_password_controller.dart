import 'package:peacepay/backend/models/common/common_success_model.dart';
import 'package:peacepay/controller/dashboard/profiles/update_profile_controller.dart';

import '../../../backend/backend_utils/logger.dart';
import '../../../backend/local_storage/local_storage.dart';
import '../../../backend/models/auth/createPinModel.dart';
import '../../../backend/models/auth/forgot_send_otp_model.dart';
import '../../../backend/services/api_services.dart';
import '../../../routes/routes.dart';
import '../../../utils/basic_screen_imports.dart';

final log = logger(ChangePasswordController);

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  late CommonSuccessModel _successModel;
  CommonSuccessModel get successModel => _successModel;

  onChangePasswordProcess(BuildContext context) {
    if (formKey.currentState!.validate()) {
      updatePinProcess();
    }
  }


  late CreatePinModel _createPinModel;
  CreatePinModel get registrationModel => _createPinModel;
  Future<CreatePinModel> updatePinProcess() async {
    _isLoading.value = true;
    update();
    Map<String, dynamic> inputBody = {
      'pin_code': newPasswordController.text,
      'current_pin_code': oldPasswordController.text,
      'pin_code_confirmation': confirmPasswordController.text,
    };
    await ApiServices.createPINApi(body: inputBody).then((value)async {
      _createPinModel = value!;
      Get.offAllNamed(Routes.dashboardScreen);
      update();
    }).catchError((onError) {
      log.e(onError);
    });

    _isLoading.value = false;
    update();
    return _createPinModel;
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
      'credentials': Get.find<UpdateProfileController>()
          .profileModel
          .data
          .user.mobile,
    };

    await ApiServices.forgotPinSendOTPApi(body: inputBody).then((value) {
      _forgotModel = value!;
      token = _forgotModel!.data.token.obs;
      Get.toNamed(Routes.forgotOTPScreen, arguments: 'IntoProfileScreen');
      update();
    }).catchError((onError) {
      log.e(onError);
    });

    _isForgotLoading.value = false;
    update();
    return _forgotModel;
  }
  void onForgotPassProcess() async{
    await sendOTPProcess().then((value) {
      if(value != null) {
      }
    });

  }
}
