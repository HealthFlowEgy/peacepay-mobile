import 'package:peacepay/utils/basic_screen_imports.dart';

import '../../../backend/models/escrow/escrow_index_model.dart';
import '../../../backend/services/api_endpoint.dart';
import '../../../backend/services/escrow_api_service.dart';
import '../../../backend/services/peacelink_api_service.dart';
import '../../../backend/backend_utils/custom_snackbar.dart';
import '../../../backend/constants/peacelink_constants.dart';

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

  /// Buyer cancels order
  /// BUG FIX: Updated to use correct "Cancel Order" terminology
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

  /// Merchant cancels PeaceLink
  /// BUG FIX: Added support for merchant cancellation after DSP assignment
  Future<void> cancelPayment({required String id}) async {
    _isLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      'target': id,
    };

    await escrowCancelPaymentApi(body: inputBody).then((value) async {
      if (value != null) {
        CustomSnackBar.success("PeaceLink canceled successfully");
        await escrowIndexFetch();
      }
    }).catchError((error) {
      CustomSnackBar.error(error.toString());
    });

    _isLoading.value = false;
    update();
  }

  /// DSP cancels delivery assignment
  /// BUG FIX: Added DSP cancel delivery functionality
  Future<void> dspCancelDelivery({required String id}) async {
    _isLoading.value = true;
    update();

    try {
      final result = await PeaceLinkApiService.cancel(
        peacelinkId: int.parse(id),
        reason: 'DSP canceled delivery',
      );

      if (result['success'] == true) {
        CustomSnackBar.success("Delivery canceled successfully");
        await escrowIndexFetch();
      } else {
        CustomSnackBar.error(result['error'] ?? 'Failed to cancel delivery');
      }
    } catch (e) {
      CustomSnackBar.error(e.toString());
    }

    _isLoading.value = false;
    update();
  }

  /// DSP verifies OTP to complete delivery
  Future<void> verifyOtp({required String id, required String otp}) async {
    _isLoading.value = true;
    update();

    try {
      final result = await PeaceLinkApiService.verifyOtp(
        peacelinkId: int.parse(id),
        otp: otp,
      );

      if (result['success'] == true) {
        CustomSnackBar.success("Delivery confirmed successfully");
        await escrowIndexFetch();
      } else {
        CustomSnackBar.error(result['error'] ?? 'Invalid OTP');
      }
    } catch (e) {
      CustomSnackBar.error(e.toString());
    }

    _isLoading.value = false;
    update();
  }

  /// Open a dispute
  Future<void> openDispute({
    required String id,
    required String reason,
    String? reasonAr,
    List<String>? evidenceUrls,
  }) async {
    _isLoading.value = true;
    update();

    try {
      final result = await PeaceLinkApiService.openDispute(
        peacelinkId: int.parse(id),
        reason: reason,
        reasonAr: reasonAr,
        evidenceUrls: evidenceUrls,
      );

      if (result['success'] == true) {
        CustomSnackBar.success("Dispute opened successfully");
        await escrowIndexFetch();
      } else {
        CustomSnackBar.error(result['error'] ?? 'Failed to open dispute');
      }
    } catch (e) {
      CustomSnackBar.error(e.toString());
    }

    _isLoading.value = false;
    update();
  }
}
