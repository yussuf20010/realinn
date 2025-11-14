import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/wp_config.dart';
import '../models/service_provider.dart';
import '../models/service_provider_category.dart';
import '../models/pagination.dart';
import '../models/providers_by_category_response.dart';
import 'http_headers.dart';

class ServiceProviderService {
  static Future<List<ServiceProviderCategory>> fetchCategories() async {
    try {
      final uri = Uri.parse(WPConfig.serviceProvidersApiUrl);

      print('🟢 FETCH CATEGORIES REQUEST:');
      print('URL: $uri');
      print('Headers: ${WPConfig.defaultHeaders}');

      final headers = await buildAuthHeaders(
        extra: {'X-API-Key': WPConfig.siteApiKey},
      );
      final response = await http.get(uri, headers: headers);

      print('🟢 FETCH CATEGORIES RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body (Raw): ${response.body}');
      print('---');

      if (response.statusCode != 200) {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('application/json')) {
        throw Exception(
            'Unexpected content-type: $contentType. Body starts with: ${response.body.substring(0, response.body.length > 120 ? 120 : response.body.length)}');
      }
      final Map<String, dynamic> data = json.decode(response.body);
      print('Parsed Data: $data');
      final List categories = (data['categories'] as List?) ?? <dynamic>[];
      final result = categories
          .map((c) =>
              ServiceProviderCategory.fromJson(c as Map<String, dynamic>))
          .toList();

      print('🟢 CATEGORIES PARSED: ${result.length} categories');
      return result;
    } catch (e) {
      print('🔴 FETCH CATEGORIES ERROR: ${e.toString()}');
      rethrow;
    }
  }

  static Future<List<ServiceProvider>> fetchProviders(
      {Map<String, dynamic>? query}) async {
    try {
      final cleanedParams = _cleanParams(query);
      final uri = Uri.parse(WPConfig.serviceProvidersApiUrl)
          .replace(queryParameters: cleanedParams);

      print('🟢 FETCH PROVIDERS REQUEST:');
      print('URL: $uri');
      print('Query Parameters: $cleanedParams');
      print('Headers: ${WPConfig.defaultHeaders}');

      final headers = await buildAuthHeaders(
        extra: {'X-API-Key': WPConfig.siteApiKey},
      );
      final response = await http.get(uri, headers: headers);

      print('🟢 FETCH PROVIDERS RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body (Raw): ${response.body}');
      print('---');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load providers: ${response.statusCode}. Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      }

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('application/json')) {
        throw Exception(
            'Unexpected content-type: $contentType. Body starts with: ${response.body.substring(0, response.body.length > 120 ? 120 : response.body.length)}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      print('Parsed Data: $data');
      final List providers = (data['providers'] as List?) ?? <dynamic>[];
      final result = providers
          .map((p) => ServiceProvider.fromApi(p as Map<String, dynamic>))
          .toList();

      print('🟢 PROVIDERS PARSED: ${result.length} providers');
      return result;
    } catch (e) {
      print('🔴 FETCH PROVIDERS ERROR: ${e.toString()}');
      rethrow;
    }
  }

  static Future<ProvidersByCategoryResponse> fetchProvidersByCategoryPaged(
      {required int categoryId, int page = 1, int perPage = 12}) async {
    try {
      final uri = Uri.parse(
        WPConfig.serviceProvidersByCategoryApiUrl(categoryId),
      ).replace(queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      });
      final headers = await buildAuthHeaders(
        extra: {
          'X-API-Key': WPConfig.siteApiKey,
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      print('🟢 FETCH PROVIDERS BY CATEGORY REQUEST:');
      print('URL: $uri');
      print('Category ID: $categoryId');
      print('Headers: ${WPConfig.defaultHeaders}');

      final response = await http.get(uri, headers: headers);

      print('🟢 FETCH PROVIDERS BY CATEGORY RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body (Raw): ${response.body}');
      print('---');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load providers: ${response.statusCode}. Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      }

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('application/json')) {
        throw Exception(
            'Unexpected content-type: $contentType. Body starts with: ${response.body.substring(0, response.body.length > 120 ? 120 : response.body.length)}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      print('Parsed Data: $data');

      // New shape: providers -> { data: [...], pagination: {...} }
      final providersWrapper = data['providers'] as Map<String, dynamic>?;
      final List providersList = (providersWrapper != null
              ? providersWrapper['data'] as List?
              : null) ??
          <dynamic>[];
      final result = providersList
          .map((p) => ServiceProvider.fromApi(p as Map<String, dynamic>))
          .toList();

      PaginationInfo? pagination;
      final paginationJson = providersWrapper != null
          ? providersWrapper['pagination'] as Map<String, dynamic>?
          : null;
      if (paginationJson != null) {
        pagination = PaginationInfo.fromJson(paginationJson);
      }

      print(
          '🟢 PROVIDERS PARSED: ${result.length} providers, page: ${pagination?.currentPage}/${pagination?.lastPage}');
      return ProvidersByCategoryResponse(
          providers: result, pagination: pagination);
    } catch (e) {
      print('🔴 FETCH PROVIDERS BY CATEGORY ERROR: ${e.toString()}');
      rethrow;
    }
  }

  static Future<ServiceProvider> fetchProviderByCategoryAndId(
      {required int categoryId, required int id}) async {
    // Deprecated in favor of service-based endpoint; delegate to new method
    return fetchProviderDetailsByServiceId(id);
  }

  static Future<ServiceProvider> fetchProviderById(int id) async {
    // Deprecated in favor of service-based endpoint; delegate to new method
    return fetchProviderDetailsByServiceId(id);
  }

  // Fetch a service by ID: GET /api/service-providers/service/{id}
  static Future<Map<String, dynamic>> fetchServiceById(int id) async {
    try {
      final uri = Uri.parse(WPConfig.serviceByIdApiUrl(id));
      final headers = await buildAuthHeaders(
        extra: {
          'X-API-Key': WPConfig.siteApiKey,
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      print('🟢 FETCH SERVICE BY ID REQUEST:');
      print('URL: $uri');
      print('Headers: $headers');

      final response = await http.get(uri, headers: headers);

      print('🟢 FETCH SERVICE BY ID RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body (Raw): ${response.body}');
      print('---');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load service: ${response.statusCode}. Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      }

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('application/json')) {
        throw Exception(
            'Unexpected content-type: $contentType. Body starts with: ${response.body.substring(0, response.body.length > 120 ? 120 : response.body.length)}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } catch (e) {
      print('🔴 FETCH SERVICE BY ID ERROR: ${e.toString()}');
      rethrow;
    }
  }

  // Helper: fetch provider details using the service-based endpoint
  static Future<ServiceProvider> fetchProviderDetailsByServiceId(int id) async {
    final data = await fetchServiceById(id);
    // Attempt to locate provider object in different possible shapes
    final Map<String, dynamic> providerJson =
        (data['provider'] as Map<String, dynamic>?) ??
            (data['data'] as Map<String, dynamic>?) ??
            (data as Map<String, dynamic>);
    final result = ServiceProvider.fromApi(providerJson);
    print('🟢 PROVIDER PARSED (service/id): ${result.name} (ID: ${result.id})');
    return result;
  }

  // Get service provider details: GET /api/service-providers/{id}
  static Future<ServiceProvider> fetchProviderDetails(int id) async {
    try {
      final uri = Uri.parse(WPConfig.serviceProviderDetailsApiUrl(id));
      final headers = await buildAuthHeaders(
        extra: {'X-API-Key': WPConfig.siteApiKey},
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to load provider: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final providerJson = (data['provider'] as Map<String, dynamic>?) ??
          (data['data'] as Map<String, dynamic>?) ??
          (data as Map<String, dynamic>);
      return ServiceProvider.fromApi(providerJson);
    } catch (e) {
      print('🔴 FETCH PROVIDER DETAILS ERROR: ${e.toString()}');
      rethrow;
    }
  }

  // Get services: GET /api/service-providers/{id}/services
  static Future<List<Map<String, dynamic>>> fetchProviderServices(int id) async {
    try {
      final uri = Uri.parse(WPConfig.serviceProviderServicesApiUrl(id));
      final headers = await buildAuthHeaders(
        extra: {'X-API-Key': WPConfig.siteApiKey},
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to load services: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        return List<Map<String, dynamic>>.from(
            (data['services'] as List? ?? data['data'] as List? ?? []));
      } else if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('🔴 FETCH PROVIDER SERVICES ERROR: ${e.toString()}');
      rethrow;
    }
  }

  // Get reviews: GET /api/service-providers/{id}/reviews
  static Future<List<Map<String, dynamic>>> fetchProviderReviews(int id) async {
    try {
      final uri = Uri.parse(WPConfig.serviceProviderReviewsApiUrl(id));
      final headers = await buildAuthHeaders(
        extra: {'X-API-Key': WPConfig.siteApiKey},
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        return List<Map<String, dynamic>>.from(
            (data['reviews'] as List? ?? data['data'] as List? ?? []));
      } else if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('🔴 FETCH PROVIDER REVIEWS ERROR: ${e.toString()}');
      rethrow;
    }
  }

  // Check availability: POST /api/service-providers/{id}/check-availability
  static Future<Map<String, dynamic>> checkAvailability({
    required int id,
    required String date,
    required String time,
  }) async {
    try {
      final uri = Uri.parse(WPConfig.serviceProviderCheckAvailabilityApiUrl(id));
      final headers = await buildAuthHeaders(
        extra: {'X-API-Key': WPConfig.siteApiKey},
      );

      final body = json.encode({
        'date': date,
        'time': time,
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        final errorMsg = errorData['error']?.toString() ??
            errorData['message']?.toString() ??
            'Failed to check availability';
        throw Exception(errorMsg);
      }

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      print('🔴 CHECK AVAILABILITY ERROR: ${e.toString()}');
      rethrow;
    }
  }
}

Map<String, String>? _cleanParams(Map<String, dynamic>? params) {
  if (params == null) return null;
  final cleaned = <String, String>{};
  params.forEach((key, value) {
    if (value == null) return;
    if (value is String && value.isEmpty) return;
    cleaned[key] = value.toString();
  });
  return cleaned.isEmpty ? null : cleaned;
}
