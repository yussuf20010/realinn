import '../config/wp_config.dart';
import 'token_storage_service.dart';

Future<Map<String, String>> buildAuthHeaders(
    {Map<String, String>? extra}) async {
  final headers = <String, String>{...WPConfig.defaultHeaders};

  final token = await TokenStorageService.getToken();
  if (token != null && token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }

  final cookies = await TokenStorageService.getCookies();
  if (cookies != null && cookies.isNotEmpty) {
    headers['Cookie'] = cookies;
  }

  if (extra != null && extra.isNotEmpty) {
    headers.addAll(extra);
  }

  return headers;
}
