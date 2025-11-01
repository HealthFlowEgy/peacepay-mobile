import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../backend/backend_utils/custom_snackbar.dart';
import '../../backend/backend_utils/logger.dart';
import '../../backend/local_storage/local_storage.dart';
import '../../backend/models/auth/kyc_model.dart';
import '../../backend/models/common/common_success_model.dart';
import '../../backend/services/kyc_api_service.dart';
import '../../routes/routes.dart';
import '../../utils/basic_screen_imports.dart';
import '../../views/confirm_screen.dart';
import '../../widgets/custom_dropdown_widget/custom_dropdown_widget.dart';
import '../../widgets/others/custom_upload_file_widget.dart';

final log = logger(KYCFormController);

/// Controller that handles:
/// - Fetching KYC form fields dynamically
/// - Submitting KYC form data
/// - Managing upload files
/// - Handling reapply/reset logic
class KYCFormController extends GetxController with KycApiService {
  // Global form key
  final formKey = GlobalKey<FormState>();

  // Loading states
  final _isLoading = false.obs;
  final _isSubmitLoading = false.obs;
  bool get isLoading => _isLoading.value;
  bool get isSubmitLoading => _isSubmitLoading.value;

  // Track current KYC status
  // 0 = Not verified, 1 = Pending, 2 = Approved, 3 = Rejected
  final currentKycStatus = 0.obs;

  // KYC model (data from backend)
  late KycModel _kycModel;
  KycModel get kycModel => _kycModel;
  final showForm = false.obs; //

  // Dynamic form fields
  List<TextEditingController> inputFieldControllers = [];
  RxList<Widget> inputFields = <Widget>[].obs;
  RxList<Widget> inputFileFields = <Widget>[].obs;

  // Dropdown related fields
  final selectedIDType = "".obs;
  List<IdTypeModel> idTypeList = [];

  // File tracking
  int totalFile = 0;
  List<String> listImagePath = [];
  List<String> listFieldName = [];
  RxBool hasFile = false.obs;

  // Common success response
  late CommonSuccessModel _commonSuccessModel;
  CommonSuccessModel get commonSuccessModel => _commonSuccessModel;

  /// Lifecycle
  @override
  void onInit() {
    super.onInit();
    kycInfoFetch();
  }

  /// Fetch KYC form fields and set up dynamic UI
  Future<KycModel> kycInfoFetch() async {
    _isLoading.value = true;

    // Reset all dynamic data
    inputFields.clear();
    inputFileFields.clear();
    listImagePath.clear();
    idTypeList.clear();
    listFieldName.clear();
    inputFieldControllers.clear();

    update();

    try {
      final value = await kycFieldAPi();

      if (value != null) {
        _kycModel = value;
        currentKycStatus.value = _kycModel.data.kycStatus;
        final data = _kycModel.data.inputFields;
        _buildDynamicInputFields(data);
      } else {
        CustomSnackBar.error("Failed to load KYC data");
      }
    } catch (e) {
      log.e('KYC info fetch error: $e');
      CustomSnackBar.error("Error loading KYC info");
    } finally {
      _isLoading.value = false;
      update();
    }

    return _kycModel;
  }

  /// Dynamically build text, dropdown, and file inputs from backend schema
  void _buildDynamicInputFields(List<InputField> data) {
    totalFile = 0;
    for (var field in data) {
      final controller = TextEditingController();
      inputFieldControllers.add(controller);

      // Dropdown (select)
      if (field.type.contains('select')) {
        hasFile.value = true;
        idTypeList = field.validation.options
            .map((e) => IdTypeModel(e, e))
            .toList();
        selectedIDType.value = idTypeList.first.title;
        controller.text = selectedIDType.value;

        inputFields.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => CustomDropDown<IdTypeModel>(
                items: idTypeList,
                title: field.label,
                hint: selectedIDType.value.isEmpty
                    ? Strings.selectIDType
                    : selectedIDType.value,
                onChanged: (value) {
                  selectedIDType.value = value!.title;
                },
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeHorizontal * 0.25,
                ),
                titleTextColor:
                CustomColor.primaryLightTextColor.withOpacity(.2),
                borderEnable: true,
                dropDownFieldColor: Colors.transparent,
                dropDownIconColor:
                CustomColor.primaryLightTextColor.withOpacity(.2),
              )),
              verticalSpace(Dimensions.marginBetweenInputBox * .8),
            ],
          ),
        );
      }

      // File Upload
      else if (field.type.contains('file')) {
        totalFile++;
        hasFile.value = true;

        inputFileFields.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: CustomUploadFileWidget(
                  labelText: field.label,
                  hint: field.validation.mimes.join(","),
                  onTap: (File value) {
                    updateImageData(field.name, value.path);
                  },
                ),
              ),
            ],
          ),
        );
      }

      // Text Field
      else if (field.type.contains('text')) {
        inputFields.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryTextInputWidget(
                controller: controller,
                labelText: field.label,
              ),
              verticalSpace(Dimensions.marginBetweenInputBox * .8),
            ],
          ),
        );
      }
    }
  }

  /// Update file list for API submission
  void updateImageData(String fieldName, String imagePath) {
    final index = listFieldName.indexOf(fieldName);
    if (index >= 0) {
      listImagePath[index] = imagePath;
    } else {
      listFieldName.add(fieldName);
      listImagePath.add(imagePath);
    }
    update();
  }

  /// Reset dynamic fields (used for reapplying KYC)
  void clearKycFields() {
    formKey.currentState?.reset();
    inputFields.clear();
    inputFileFields.clear();
    inputFieldControllers.clear();
    listFieldName.clear();
    listImagePath.clear();
  }

  /// Submit the KYC form
  Future<CommonSuccessModel> kycSubmitApiProcess() async {
    _isSubmitLoading.value = true;
    Map<String, String> inputBody = {};

    try {
      final data = kycModel.data.inputFields;

      // Add text inputs
      for (int i = 0; i < data.length; i++) {
        if (data[i].type != 'file') {
          inputBody[data[i].name] = inputFieldControllers[i].text;
        }
      }

      // Send request
      final value = await kycSubmitProcessApi(
        body: inputBody,
        fieldList: listFieldName,
        pathList: listImagePath,
      );

      if (value != null) {
        _commonSuccessModel = value;
        inputFields.clear();
        listFieldName.clear();
        listImagePath.clear();
        inputFieldControllers.clear();
      }
    } catch (e) {
      log.e('KYC submit error: $e');
      CustomSnackBar.error('KYC submission failed');
    } finally {
      _isSubmitLoading.value = false;
      update();
    }

    return _commonSuccessModel;
  }

  /// Validate form and handle navigation after successful submission
  void onSubmitProcess(BuildContext context) {
    if (!formKey.currentState!.validate()) return;

    if (totalFile != listFieldName.length) {
      CustomSnackBar.error("Select all required files");
      return;
    }

    kycSubmitApiProcess().then((value) {
      Navigator.push(
        Get.context!,
        MaterialPageRoute(
          builder: (context) => ConfirmScreen(
            message: Strings.kycFormConfirmationMSG,
            onApproval: true,
            onOkayTap: () {
              LocalStorage.isLoginSuccess(isLoggedIn: true);
              Get.offAllNamed(Routes.dashboardScreen);
            },
          ),
        ),
      );
    });
  }
}

class IdTypeModel implements DropdownModel {
  final String mId;
  final String name;

  IdTypeModel(this.mId, this.name);

  @override
  // TODO: implement code
  String get mcode => throw UnimplementedError();

  @override
  // TODO: implement img
  String get img => throw UnimplementedError();

  @override
  // TODO: implement title
  String get title => name;

  @override
  // TODO: implement currencyCode
  String get currencyCode => throw UnimplementedError();

  @override
  // TODO: implement currencySymbol
  String get currencySymbol => throw UnimplementedError();


  @override
  // TODO: implement type
  String get type => throw UnimplementedError();

  @override
  // TODO: implement fCharge
  double get fCharge => throw UnimplementedError();

  @override
  // TODO: implement max
  double get max => throw UnimplementedError();

  @override
  // TODO: implement min
  double get min => throw UnimplementedError();

  @override
  // TODO: implement pCharge
  double get pCharge => throw UnimplementedError();

  @override
  // TODO: implement rate
  double get rate => throw UnimplementedError();

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();
}
