import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import '../config/wp_config.dart';
import 'http_headers.dart';

class HotelService {
  static Future<List<Hotel>> fetchHotels({Map<String, dynamic>? query}) async {
    final uri = Uri.parse(WPConfig.hotelsApiUrl)
        .replace(queryParameters: _cleanParams(query));
    final headers = await buildAuthHeaders();
    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to load hotels: ${response.statusCode}');
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final hotelsList = (data['hotels'] as List?) ?? <dynamic>[];
    return hotelsList.map((e) {
      if (e is! Map<String, dynamic>) {
        throw Exception('Invalid hotel item');
      }
      final id = e['id']?.toString() ?? '';
      return Hotel.fromJson(e, id);
    }).toList();
  }

  static Future<LocationResponseModel> fetchMeta() async {
    final uri = Uri.parse(WPConfig.hotelsApiUrl);
    final response = await http.get(uri, headers: await buildAuthHeaders());
    if (response.statusCode != 200) {
      throw Exception('Failed to load meta: ${response.statusCode}');
    }
    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid meta response');
    }
    return LocationResponseModel.fromJson(decoded as Map<String, dynamic>);
  }
}

Map<String, String>? _cleanParams(Map<String, dynamic>? params) {
  if (params == null) return null;
  final cleaned = <String, String>{};
  params.forEach((k, v) {
    if (v == null) return;
    final s = v.toString();
    if (s.isEmpty) return;
    cleaned[k] = s;
  });
  return cleaned.isEmpty ? null : cleaned;
}
