import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/basic_widget_imports.dart';
import 'backend_utils/custom_snackbar.dart';

mixin DownloadFile {
  /// Only request CAMERA when you actually open the camera.
  /// No storage/photos permission requests (policy-safe).
  Future<bool> ensureCameraPermissionIfNeeded() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// App-scoped base directory for saving files (policy-safe, no permission).
  Future<Directory> _appScopedDownloadDir() async {
    if (Platform.isIOS) {
      // iOS: Documents directory is fine (visible via Files > On My iPhone > YourApp)
      return await getApplicationDocumentsDirectory();
    }
    // Android: use app-specific external dir (Android/data/<pkg>/files)
    // This doesn't require storage permissions and is policy-compliant.
    final dir = await getExternalStorageDirectory();
    // Fallback to temp if null (rare)
    return dir ?? await getTemporaryDirectory();
  }

  /// OPTIONAL: If you want a user-visible "Save As..." dialog to Downloads
  /// use SAF via file_saver. No storage permission needed.
  /// Uncomment dependency & code if you want this flow.
  // Future<void> _saveWithSystemPicker({
  //   required Uint8List bytes,
  //   required String name,
  //   String mimeType = 'application/octet-stream',
  // }) async {
  //   await FileSaver.instance.saveFile(
  //     name: name,
  //     bytes: bytes,
  //     mimeType: mimeType,
  //   );
  // }

  /// Download a file from URL and save to app-scoped directory (no permissions).
  Future<void> downloadFile({
    required String url,
    required String name,
    String? mimeType, // optional, for SAF if you switch
    bool useSystemPicker = false, // set true if you integrate file_saver
  }) async {
    try {
      final resp = await http.get(Uri.parse(url));
      debugPrint("Download URL: $url");
      debugPrint("HTTP ${resp.statusCode}");

      if (resp.statusCode != 200) {
        CustomSnackBar.error('Failed to download the file.');
        return;
      }

      final bytes = resp.bodyBytes;

      // If you want a system "Save As..." dialog (SAF), flip useSystemPicker=true and
      // uncomment the file_saver import & method above.
      // if (useSystemPicker) {
      //   await _saveWithSystemPicker(
      //     bytes: bytes,
      //     name: name,
      //     mimeType: mimeType ?? 'application/octet-stream',
      //   );
      //   CustomSnackBar.success('File saved via system picker.');
      //   return;
      // }

      final baseDir = await _appScopedDownloadDir();
      // Create a subfolder for clarity
      final downloadsDir = Directory('${baseDir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final file = File('${downloadsDir.path}/$name');
      await file.writeAsBytes(bytes);
      CustomSnackBar.success('File downloaded: ${file.path}');
      debugPrint('Saved to: ${file.path}');
    } catch (e, s) {
      debugPrint('Download error: $e\n$s');
      CustomSnackBar.error('Failed to download the file.');
    }
  }

  /// Save provided bytes (e.g., PDF) to app-scoped directory (no permissions).
  Future<void> downloadFile2({
    required Uint8List pdfData,
    required String name,
    String? mimeType, // for SAF if you switch
    bool useSystemPicker = false, // set true if integrating file_saver
  }) async {
    try {
      // if (useSystemPicker) {
      //   await _saveWithSystemPicker(
      //     bytes: pdfData,
      //     name: name,
      //     mimeType: mimeType ?? 'application/pdf',
      //   );
      //   CustomSnackBar.success('File saved via system picker.');
      //   return;
      // }

      final baseDir = await _appScopedDownloadDir();
      final downloadsDir = Directory('${baseDir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final file = File('${downloadsDir.path}/$name');
      await file.writeAsBytes(pdfData);
      CustomSnackBar.success('File downloaded: ${file.path}');
      debugPrint('Saved to: ${file.path}');
    } catch (e, s) {
      debugPrint('Save error: $e\n$s');
      CustomSnackBar.error('Failed to download the file.');
    }
  }

  /// (Optional) Quick SDK check helper if you need version-specific logic.
  Future<int> androidSdkInt() async {
    if (!Platform.isAndroid) return -1;
    final info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt;
  }
}