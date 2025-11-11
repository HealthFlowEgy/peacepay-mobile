import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../../../backend/backend_utils/custom_snackbar.dart';
import '../../../backend/backend_utils/logger.dart';
import '../../../backend/local_storage/local_storage.dart';
import '../../../backend/services/api_services.dart';
import '../../../routes/routes.dart';

final log = logger(ProfileController);

class ProfileController extends GetxController {
  // --- Form + state ---
  final forgotPassFormKey = GlobalKey<FormState>();
  late final TextEditingController subjectCtrl;
  late final TextEditingController descCtrl;

  // Use ONE loading flag
  final RxBool isLoading = false.obs;

  // Attachments (images only as you set)
  final RxList<PlatformFile> attachments = <PlatformFile>[].obs;
  static const int _maxTotalBytes = 10 * 1024 * 1024; // 10 MB

  @override
  void onInit() {
    // init controllers ONCE here (don't init at declaration)
    subjectCtrl = TextEditingController();
    descCtrl = TextEditingController();
    super.onInit();
  }



  // ---------------- Attachments ----------------
  Future<void> pickAttachments() async {
    // Opens the system image picker (Photos/Gallery). No other files.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,     // 👈 images only
      allowMultiple: true,
      withData: true,           // size available across platforms
    );
    if (result == null) return;

    final current = List<PlatformFile>.from(attachments);
    for (final f in result.files) {
      final nextTotal = current.fold<int>(0, (s, e) => s + e.size) + f.size;
      if (nextTotal > _maxTotalBytes) {
        Get.snackbar('Too Large', 'Total attachments exceed 10 MB',
            snackPosition: SnackPosition.BOTTOM);
        break;
      }
      current.add(f);
    }
    attachments.assignAll(current);
  }


  void removeAttachment(PlatformFile f) => attachments.remove(f);

  // ---------------- Auth/Profile misc ----------------
  Future<void> deleteProfileProcess() async {
    isLoading.value = true;
    update();
    try {
      final value = await ApiServices.deleteApi();
      if (value != null) {
        LocalStorage.logout();
        LocalStorage.clearHasPin();
        Get.offAllNamed(Routes.loginScreen);
      }
    } catch (e) {
      log.e(e);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ---------------- Support Ticket ----------------
  Future<void> supportTicketProcess({
    required String subject,
    required String description,
    List<PlatformFile> attachments = const [],
  }) async {
    isLoading.value = true;
    update();

    try {
      // Body fields
      final body = <String, String>{
        'subject': subject.trim(),
        'desc': description.trim(),
      };

      // Files (write temp file if bytes-only)
      final List<String> pathList = [];
      final List<String> fieldList = [];

      for (final f in attachments) {
        String? p = f.path;
        if ((p == null || p.isEmpty) && f.bytes != null) {
          final tempPath =
              '${Directory.systemTemp.path}/ticket_${DateTime.now().microsecondsSinceEpoch}_${f.name}';
          await File(tempPath).writeAsBytes(f.bytes!, flush: true);
          p = tempPath;
        }
        if (p != null && p.isNotEmpty) {
          pathList.add(p);
          fieldList.add('attachment'); // or 'attachments[]' per backend
        }
      }

      final res = await ApiServices.supportTicketProcessApi(
        body: body,
        pathList: pathList,
        fieldList: fieldList,
      );

      if (res != null) {
        // clear UI state (optional)
        subjectCtrl.clear();
        descCtrl.clear();
        this.attachments.clear();
        Get.offAllNamed(Routes.dashboardScreen);
        CustomSnackBar.success(res.message!.success.toString().replaceAll("[", '').replaceAll("]", ''));
      }
    } catch (e) {
      log.e(e);
      CustomSnackBar.error('Something went wrong!');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ---------------- Navigation shortcuts ----------------
  void routeUpdateProfile() => Get.toNamed(Routes.updateProfileScreen);
  void routeUpdateKYC() => Get.toNamed(Routes.kycFormScreen);
  void routeFASecurity() => Get.toNamed(Routes.faSecurityScreen);
  void routeChangePassword() => Get.toNamed(Routes.changePasswordScreen);

  Future<void> logOutProcess() async {
    isLoading.value = true;
    update();
    try {
      final value = await ApiServices.logOutApi();
      if (value != null) {
        LocalStorage.logout();
        Get.offAllNamed(Routes.loginScreen);
      }
    } catch (e) {
      log.e(e);
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
