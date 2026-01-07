import 'dart:convert';
import 'package:http/http.dart' as http;
import '../local_storage/local_storage.dart';
import 'api_endpoint.dart';

/// PeaceLink API Service
/// Based on Re-Engineering Specification v2.0
/// Handles all PeaceLink-specific API calls
class PeaceLinkApiService {
  /// Get PeaceLink details with state-based data
  static Future<Map<String, dynamic>> getPeaceLinkDetails(int id) async {
    final response = await http.get(
      Uri.parse('${ApiEndpoint.mainDomain}/api/v1/user/peacelink/$id'),
      headers: _getHeaders(),
    );
    return _handleResponse(response);
  }

  /// Assign DSP to PeaceLink
  static Future<Map<String, dynamic>> assignDsp({
    required int peacelinkId,
    required String dspMobile,
    String? dspWalletNumber,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiEndpoint.mainDomain}/api/v1/user/peacelink/$peacelinkId/assign-dsp'),
      headers: _getHeaders(),
      body: jsonEncode({
        'dsp_mobile': dspMobile,
        if (dspWalletNumber != null) 'dsp_wallet_number': dspWalletNumber,
      }),
    );
    return _handleResponse(response);
  }

  /// Change DSP (reassign)
  static Future<Map<String, dynamic>> changeDsp({
    required int peacelinkId,
    required String dspMobile,
    required String reason,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiEndpoint.mainDomain}/api/v1/user/peacelink/$peacelinkId/change-dsp'),
      headers: _getHeaders(),
      body: jsonEncode({
        'dsp_mobile': dspMobile,
        'reason': reason,
      }),
    );
    return _handleResponse(response);
  }

  /// Cancel PeaceLink
  static Future<Map<String, dynamic>> cancel({
    required int peacelinkId,
    String? reason,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiEndpoint.mainDomain}/api/v1/user/peacelink/$peacelinkId/cancel'),
      headers: _getHeaders(),
      body: jsonEncode({
        if (reason != null) 'reason': reason,
      }),
    );
    return _handleResponse(response);
  }

  /// Verify OTP and complete delivery (for DSP)
  static Future<Map<String, dynamic>> verifyOtp({
    required int peacelinkId,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiEndpoint.mainDomain}/api/v1/user/peacelink/$peacelinkId/verify-otp'),
      headers: _getHeaders(),
      body: jsonEncode({
        'otp': otp,
      }),
    );
    return _handleResponse(response);
  }

  /// Open a dispute
  static Future<Map<String, dynamic>> openDispute({
    required int peacelinkId,
    required String reason,
    String? reasonAr,
    List<String>? evidenceUrls,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiEndpoint.mainDomain}/api/v1/user/peacelink/$peacelinkId/dispute'),
      headers: _getHeaders(),
      body: jsonEncode({
        'reason': reason,
        if (reasonAr != null) 'reason_ar': reasonAr,
        if (evidenceUrls != null) 'evidence_urls': evidenceUrls,
      }),
    );
    return _handleResponse(response);
  }

  /// Get headers with authentication
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${LocalStorage.getToken()}',
    };
  }

  /// Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        'data': data['data'],
        'message': data['message'] ?? 'Success',
      };
    } else {
      return {
        'success': false,
        'error': data['message'] ?? data['error'] ?? 'An error occurred',
      };
    }
  }
}
