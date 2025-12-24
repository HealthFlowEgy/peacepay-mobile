// import 'dart:convert';
// // ignore: depend_on_referenced_packages
// import 'package:http/http.dart' as http;
//
// import '../backend/backend_utils/custom_snackbar.dart';
// import '../backend/services/api_endpoint.dart';
// import 'language_model.dart';
//
// class LanguageService {
//   Future<List<Language>> fetchLanguages() async {
//     final response = await http.get(Uri.parse(ApiEndpoint.languageURL));
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> languageDataList = data["data"]["languages"];
//       final List<Language> languages =
//           languageDataList.map((json) => Language.fromJson(json)).toList();
//       return languages;
//     } else {
//       CustomSnackBar.error('Failed to load language data');
//       throw Exception('Failed to load language data');
//     }
//   }
// }
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import '../backend/backend_utils/custom_snackbar.dart';
import '../backend/services/api_endpoint.dart';
import 'language_model.dart';

class LanguageService {
  Future<List<Language>> fetchLanguages({required String langCode}) async {
    try {
      final uri = Uri.parse("${ApiEndpoint.languageURL}?lang=$langCode");

      // Log the request
      print('🌐 [LanguageService] Fetching languages from: $uri');
      print('🌐 [LanguageService] Language code: $langCode');

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Accept-Language': langCode, // Optional header
      });

      print('🌐 [LanguageService] Response status: ${response.statusCode}');
      print(
          '🌐 [LanguageService] Response body length: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Log the parsed data structure
        print(
            '🌐 [LanguageService] Response has "data" key: ${data.containsKey("data")}');
        print(
            '🌐 [LanguageService] Response has "data.languages" key: ${data["data"]?.containsKey("languages")}');

        final List<dynamic> languageDataList = data["data"]["languages"];
        print(
            '🌐 [LanguageService] Found ${languageDataList.length} languages');

        final List<Language> languages =
            languageDataList.map((json) => Language.fromJson(json)).toList();

        // Log each language
        for (var lang in languages) {
          print(
              '🌐 [LanguageService] Language: ${lang.name} (${lang.code}) - ${lang.translateKeyValues.length} translations');
        }

        print(
            '✅ [LanguageService] Successfully fetched ${languages.length} languages');
        return languages;
      } else {
        print(
            '❌ [LanguageService] HTTP Error ${response.statusCode}: ${response.body}');
        CustomSnackBar.error('Failed to load language data');
        throw Exception('Failed to load language data');
      }
    } catch (e, stackTrace) {
      print('❌ [LanguageService] Error fetching languages: $e');
      print('❌ [LanguageService] Stack trace: $stackTrace');
      CustomSnackBar.error('Something went wrong: $e');
      rethrow;
    }
  }
}
