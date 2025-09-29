import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../utils/basic_screen_imports.dart';
import 'custom_snackbar.dart';
import 'logger.dart';
import '../local_storage/local_storage.dart';

import '../models/common/error_message_model.dart';
import '../utils/maintenance/maintenance_dialog.dart';
import '../utils/maintenance/maintenance_model.dart';

final log = logger(ApiMethod);

Map<String, String> basicHeaderInfo() {
  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
  };
}

Future<Map<String, String>> bearerHeaderInfo() async {
  String accessToken = LocalStorage.getToken()!;

  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer $accessToken",
  };
}
Future<Map<String, String>> bearerHeaderInfoForPutMethod() async {
  String accessToken = LocalStorage.getToken()!;

  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer $accessToken",
  };
}
class ApiMethod {
  ApiMethod({required this.isBasic});

  bool isBasic;

  // Get method
  Future<Map<String, dynamic>?> get(
    String url, {
    int code = 200,
    int duration = 15,
    bool showResult = false,
        bool stream = false,

  }) async {
    if(!stream) {
      log.i(
          '|📍📍📍|----------------- [[ GET ]] method details start -----------------|📍📍📍|');
      log.i(url);
      log.i(
          '|📍📍📍|----------------- [[ GET ]] method details ended -----------------|📍📍📍|');
    }

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      log.i(
          '|📒📒📒|-----------------[[ GET ]] method response start -----------------|📒📒📒|');

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ GET ]] method response end -----------------|📒📒📒|');

      bool isMaintenance = response.statusCode == 503;
      // Check Unauthorized
      if (response.statusCode == 401) {
        LocalStorage.logout();
      }
      // Check Server Error
      if (response.statusCode == 500) {
        CustomSnackBar.error('Server error');
      }

      _maintenanceCheck(isMaintenance, response.body);

      if (response.statusCode == code) {
        return jsonDecode(response.body);
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        log.e(
            'unknown error hitted in status code${jsonDecode(response.body)}');

        ErrorResponse res = ErrorResponse.fromJson(jsonDecode(response.body));
        if (isMaintenance) {
        } else {
          if (!stream) {
            CustomSnackBar.error(res.message!.error!.join(''));
          }
        }

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');
      if (!stream) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }
      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');
      if (!stream) {
        CustomSnackBar.error('Something Went Wrong! Try again');
      }
      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }
// PUT Method

  Future<Map<String, dynamic>?> put(
      String url,
      Map<String, dynamic> body, {
        int code = 200,
        int duration = 30,
        bool showResult = false,
      }) async {
    try {
      log.i('|📍📍📍|-----------------[[ PUT ]] method details start -----------------|📍📍📍|');
      log.i(url);
      log.i(body);
      log.i('|📍📍📍|-----------------[[ PUT ]] method details end -------------------|📍📍📍|');

      final response = await http
          .put(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfoForPutMethod(),
      )
          .timeout(Duration(seconds: duration));

      log.i('|📒📒📒|-----------------[[ PUT ]] method response start ------------------|📒📒📒|');
      if (showResult) log.i(response.body);
      log.i(response.statusCode);
      log.i('|📒📒📒|-----------------[[ PUT ]] method response end --------------------|📒📒📒|');

      final isMaintenance = response.statusCode == 503;
      _maintenanceCheck(isMaintenance, response.body);

      if (response.statusCode == 401) {
        LocalStorage.logout();
        return null;
      }

      if (response.statusCode == 500) {
        CustomSnackBar.error('Server error');
        return null;
      }

      if (response.statusCode == code) {
        if (response.body.isEmpty) return <String, dynamic>{};
        final decoded = _safeJsonDecode(response.body);
        return decoded ?? <String, dynamic>{};
      }

      final message = _extractErrorMessage(
        status: response.statusCode,
        body: response.body,
        contentType: response.headers['content-type'],
      );

      log.e('🐞 Error ${response.statusCode}: $message');

      if (!isMaintenance) {
        CustomSnackBar.error(message);
      }

      return null;
    } on SocketException {
      log.e('🐞🐞🐞 SocketException 🐞🐞🐞');
      CustomSnackBar.error('Check your Internet Connection and try again!');
      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 TimeoutException 🐞🐞🐞');
      log.e('Time out exception $url');
      CustomSnackBar.error('Something Went Wrong! Try again');
      return null;
    } on http.ClientException catch (err, stacktrace) {
      log.e('🐞🐞🐞 ClientException 🐞🐞🐞');
      log.e(err.toString());
      log.e(stacktrace.toString());
      CustomSnackBar.error('Network client error');
      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error 🐞🐞🐞');
      log.e('Unlisted error received');
      log.e('$e');
      CustomSnackBar.error('Unexpected error');
      return null;
    }
  }

// ============== Helpers ==============

  Map<String, dynamic>? _safeJsonDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      return (decoded is Map<String, dynamic>) ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage({
    required int status,
    required String body,
    String? contentType,
  }) {
    String fallbackStatus() => 'Request failed ($status)';

    final trimmed = body.trim();
    if (trimmed.isEmpty) return fallbackStatus();

    final isJson = (contentType ?? '').toLowerCase().contains('application/json');

    if (!isJson) {
      return trimmed;
    }

    final map = _safeJsonDecode(trimmed);
    if (map == null) return trimmed;

    final msg = map['message'];
    if (msg is String && msg.trim().isNotEmpty) {
      return msg.trim();
    }

    if (msg is Map) {
      final parts = <String>[];
      msg.forEach((_, v) {
        if (v is String && v.trim().isNotEmpty) {
          parts.add(v.trim());
        } else if (v is List) {
          parts.addAll(
            v.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty),
          );
        }
      });
      if (parts.isNotEmpty) return parts.join('\n');
    }

    final errors = map['errors'];
    if (errors is Map) {
      final parts = <String>[];
      errors.forEach((_, v) {
        if (v is String && v.trim().isNotEmpty) {
          parts.add(v.trim());
        } else if (v is List) {
          parts.addAll(
            v.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty),
          );
        }
      });
      if (parts.isNotEmpty) return parts.join('\n');
    }

    for (final key in const ['error', 'detail', 'title', 'error_description']) {
      final val = map[key];
      if (val is String && val.trim().isNotEmpty) {
        return val.trim();
      }
    }

    return trimmed.isNotEmpty ? trimmed : fallbackStatus();
  }
  String? _extractInfoTextFromErrorBody(dynamic raw) {
    try {
      if (raw is Map &&
          raw['message'] is List &&
          (raw['message'] as List).isNotEmpty) {
        final msg0 = (raw['message'] as List).first;
        if (msg0 is Map && msg0['data'] is Map) {
          final data = msg0['data'] as Map;
          final infoText = data['info_text'];
          if (infoText is String && infoText.trim().isNotEmpty) {
            return infoText;
          }
        }
      }
    } catch (_) {
      // ignore parse errors and let normal handling continue
    }
    return null;
  }
  // Post Method
  Future<Map<String, dynamic>?> post(
      String url,
      Map<String, dynamic> body, {
        int code = 201,
        int duration = 30,
        bool showResult = false,
      }) async {
    try {
      log.i('|📍📍📍|-----------------[[ POST ]] method details start -----------------|📍📍📍|');
      log.i(url);
      log.i(body);
      log.i('|📍📍📍|-----------------[[ POST ]] method details end ------------|📍📍📍|');

      final response = await http
          .post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
      )
          .timeout(Duration(seconds: duration));

      log.i('|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|');
      if (showResult) {
        log.i(response.body.toString());
      }
      log.i(response.statusCode);
      log.i('|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|');

      // Check Unauthorized
      if (response.statusCode == 401) {
        LocalStorage.logout();
      }

      // Success path (exact code expected)
      if (response.statusCode == code) {
        return jsonDecode(response.body);
      }

      //  Non-success path (e.g., 400, 422, 500…)
      log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

      Map<String, dynamic>? parsed;
      try {
        parsed = jsonDecode(response.body) as Map<String, dynamic>?;
      } catch (_) {
        parsed = null;
      }

      // Try to show info_text if the backend sent it
      final infoText = _extractInfoTextFromErrorBody(parsed);
      if (infoText != null) {
        CustomSnackBar.error(infoText);
        return null;
      }

      // 👇 Handle Laravel-style validation error like:
      // {"message":{"error":["The mobile format is invalid."]}}
      if (parsed?['message']?['error'] != null) {
        final errors = parsed?['message']?['error'] as List?;
        if (errors != null && errors.isNotEmpty) {
          CustomSnackBar.error(errors.first.toString());
          return null;
        }
      }

      // Fallback to your existing ErrorResponse mapping
      try {
        if (parsed != null) {
          ErrorResponse res = ErrorResponse.fromJson(parsed);
          // You can enable this if you want to show error from ErrorResponse
          // CustomSnackBar.error(res.message!.error!.join('\n'));
        } else {
          // CustomSnackBar.error('Request failed (${response.statusCode}).');
        }
      } catch (_) {
        // Last resort generic message
        // CustomSnackBar.error('Request failed (${response.statusCode}).');
      }

      return null;
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');
      CustomSnackBar.error('Check your Internet Connection and try again!');
      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');
      log.e('Time out exception$url');
      CustomSnackBar.error('Something Went Wrong! Try again');
      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');
      log.e('client exception hitted');
      log.e(err.toString());
      log.e(stackrace.toString());
      return null;
    } catch (e) {
      log.e('$e🐞🐞🐞 Other Error Alert 🐞🐞🐞');
      log.e('❌❌❌ unlisted error received');
      log.e("❌❌❌ $e");
      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> multipart(
      String url, Map<String, String> body, String filepath, String filedName,
      {int code = 200, bool showResult = false}) async {
    try {
      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|');

      log.i(url);

      log.i(body);
      log.i(filepath);

      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      )
        ..fields.addAll(body)
        ..headers.addAll(
          isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
        )
        ..files.add(await http.MultipartFile.fromPath(filedName, filepath));
      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|');

      log.i(jsonData.body.toString());

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|');
      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        return jsonDecode(jsonData.body) as Map<String, dynamic>;
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        log.e(
            'unknown error hitted in status code ${jsonDecode(jsonData.body)}');

        ErrorResponse res = ErrorResponse.fromJson(jsonDecode(jsonData.body));

        if (!isMaintenance) CustomSnackBar.error(res.message!.error!.toString());

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  // multipart multi file Method
  Future<Map<String, dynamic>?> multipartMultiFile(
    String url,
    Map<String, String> body, {
    int code = 200,
    bool showResult = false,
    required List<String> pathList,
    required List<String> fieldList,
  }) async {
    try {
      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|');

      log.i(url);

      if (showResult) {
        log.i(body);
        log.i(pathList);
        log.i(fieldList);
      }

      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      )
        ..fields.addAll(body)
        ..headers.addAll(
          isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
        );

      for (int i = 0; i < fieldList.length; i++) {
        request.files
            .add(await http.MultipartFile.fromPath(fieldList[i], pathList[i]));
      }

      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|');

      log.i(jsonData.body.toString());

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|');
      bool isMaintenance = response.statusCode == 503;
      // Check Server Error
      if (response.statusCode == 500) {
        CustomSnackBar.error('Server error');
      }
      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        return jsonDecode(jsonData.body) as Map<String, dynamic>;
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        log.e(
            'unknown error hitted in status code ${jsonDecode(jsonData.body)}');

        ErrorResponse res = ErrorResponse.fromJson(jsonDecode(jsonData.body));

        if (!isMaintenance) CustomSnackBar.error(res.message!.error.toString());

        // CustomSnackBar.error(
        //     jsonDecode(response.body)['message']['error'].toString());
        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }

  void _maintenanceCheck(bool isMaintenance, var jsonData) {
    if (isMaintenance) {
      Get.find<SystemMaintenanceController>().maintenanceStatus.value = true;
      MaintenanceModel maintenanceModel =
          MaintenanceModel.fromJson(jsonDecode(jsonData));
      MaintenanceDialog().show(maintenanceModel: maintenanceModel);
    } else {
      Get.find<SystemMaintenanceController>().maintenanceStatus.value = false;
    }
  }



  // Post Method for conversation
  Future<Map<String, dynamic>?> multipart2(
      String url, Map<String, String> body, String filepath, String filedName,
      {int code = 200, bool showResult = false}) async {
    try {
      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|');

      log.i(url);

      log.i(body);
      log.i(filepath);

      log.i(
          '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      )
        ..fields.addAll(body)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.getToken()!}'
        })
        ..files.add(await http.MultipartFile.fromPath(filedName, filepath));
      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|');

      log.i(jsonData.body.toString());

      log.i(response.statusCode);

      log.i(
          '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|');

      if (response.statusCode == code) {
        return jsonDecode(jsonData.body) as Map<String, dynamic>;
      } else {
        log.e('🐞🐞🐞 Error Alert On Status Code 🐞🐞🐞');

        log.e(
            'unknown error hitted in status code ${jsonDecode(jsonData.body)}');

        debugPrint("---------------");
        debugPrint(jsonDecode(jsonData.body)["message"]["error"]["files.0"].first);
        //
        CustomSnackBar.error(jsonDecode(jsonData.body)["message"]["error"]["files.0"].first);

        return null;
      }
    } on SocketException {
      log.e('🐞🐞🐞 Error Alert on Socket Exception 🐞🐞🐞');

      CustomSnackBar.error('Check your Internet Connection and try again!');

      return null;
    } on TimeoutException {
      log.e('🐞🐞🐞 Error Alert Timeout Exception🐞🐞🐞');

      log.e('Time out exception$url');

      CustomSnackBar.error('Something Went Wrong! Try again');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('🐞🐞🐞 Error Alert Client Exception🐞🐞🐞');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('🐞🐞🐞 Other Error Alert 🐞🐞🐞');

      log.e('❌❌❌ unlisted error received');

      log.e("❌❌❌ $e");

      return null;
    }
  }
}

