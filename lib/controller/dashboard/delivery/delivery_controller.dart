
import '../../../backend/backend_utils/api_method.dart';
import '../../../backend/backend_utils/custom_snackbar.dart';
import '../../../backend/local_storage/local_storage.dart';
import '../../../backend/models/dashboard/home_model.dart';
import '../../../backend/services/api_endpoint.dart';
import '../../../backend/services/api_services.dart';
import '../../../backend/services/delivery_api_service.dart';
import 'package:adescrow_app/backend/models/common/common_success_model.dart';
import 'package:adescrow_app/utils/basic_screen_imports.dart';

import '../../../language/language_controller.dart';

class DeliveryController extends GetxController with DeliveryApiService {

  final formKey = GlobalKey<FormState>();
  final formManualKey = GlobalKey<FormState>();

  final otpController = TextEditingController();
  @override
  void dispose() {
    otpController.dispose();

    super.dispose();
  }
  @override
  void onInit() {
    super.onInit();
    homeDataFetch();
  }
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  late HomeModel _homeModel;
  HomeModel get homeModel => _homeModel;
  Future<HomeModel> homeDataFetch() async{
    _isLoading.value = true;
    update();

    await ApiServices.dashboardAPi().then((value) {
      _homeModel = value!;

      LocalStorage.saveUserId(id: _homeModel.data.userId);
      update();
    }).catchError((onError) {
      // log.e(onError);
    });
    _isLoading.value = false;
    update();

    return _homeModel;
  }
  late CommonSuccessModel? _successModel;
  CommonSuccessModel? get successModel => _successModel;

  Future<CommonSuccessModel?> releasePaymentProcess() async {
    _isLoading.value = true;
    update();
    Map<String, dynamic> inputBody = {
      'pin_code': otpController.text
    };

    await releasePaymentApi(body: inputBody).then((value) async {
      _successModel = value;

      _isLoading.value = false;
      update();
    }).catchError((onError) {
      print(onError);
    });

    _isLoading.value = false;
    update();
    return _successModel;
  }
}