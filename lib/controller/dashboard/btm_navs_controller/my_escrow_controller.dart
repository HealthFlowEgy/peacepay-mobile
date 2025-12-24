import 'package:peacepay/utils/basic_screen_imports.dart';

import '../../../backend/models/escrow/escrow_index_model.dart';
import '../../../backend/services/api_endpoint.dart';
import '../../../backend/services/escrow_api_service.dart';
import '../../../backend/backend_utils/custom_snackbar.dart';

class MyEscrowController extends GetxController with EscrowApiService {
  RxInt openTileIndex = (-1).obs;

  @override
  void onInit() {
    escrowIndexFetch();
    super.onInit();
  }

  late EscrowDatum escrowData;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // fetch info
  late EscrowIndexModel _escrowIndexModel;
  EscrowIndexModel get escrowIndexModel => _escrowIndexModel;

  Future<EscrowIndexModel> escrowIndexFetch() async {
    _isLoading.value = true;
    update();

    await escrowIndexAPi().then((value) {
      _escrowIndexModel = value!;

      update();
    }).catchError((onError) {
      log.e(onError);
    });

    _isLoading.value = false;
    update();

    return _escrowIndexModel;
  }

  Future<void> updateDeliveryNumber(
      {required String id, required String number}) async {
    _isLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      'mobile': number,
    };

    await escrowDeliveryUpdateApi(
            body: inputBody, url: "${ApiEndpoint.updateDeliveryURL}/$id")
        .then((value) async {
      if (value != null) {
        await escrowIndexFetch();
      }
    });

    _isLoading.value = false;
    update();
  }

  Future<void> cancelDeliveryNumber({required String id}) async {
    _isLoading.value = true;
    update();

    await escrowDeliveryCancelApi(url: "${ApiEndpoint.cancelDeliveryURL}/$id")
        .then((value) async {
      if (value != null) {
        await escrowIndexFetch();
      }
    });

    _isLoading.value = false;
    update();
  }

  Future<void> returnPayment({required String id}) async {
    _isLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      'target': id,
    };

    await escrowReturnPaymentApi(body: inputBody).then((value) async {
      if (value != null) {
        CustomSnackBar.success(Strings.cancelOrderSuccess);
        await escrowIndexFetch();
      }
    });

    _isLoading.value = false;
    update();
  }
}
