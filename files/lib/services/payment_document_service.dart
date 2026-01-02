import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import '../models/payment_document.dart';
import '../config/wp_config.dart';
import 'http_headers.dart';

class PaymentDocumentService {
  // Upload payment document
  static Future<PaymentDocument> uploadDocument({
    required File documentFile,
    String? notes,
    int? paymentPlanId,
  }) async {
    final uri = Uri.parse(WPConfig.paymentDocumentsUploadApiUrl);
    
    // Create multipart request
    var request = http.MultipartRequest('POST', uri);
    
    // Add headers
    final headers = await buildAuthHeaders();
    request.headers.addAll(headers);
    
    // Add file
    final fileStream = documentFile.openRead();
    final fileLength = await documentFile.length();
    final fileName = documentFile.path.split('/').last;
    final fileExtension = fileName.split('.').last.toLowerCase();
    
    // Determine content type
    MediaType contentType;
    if (fileExtension == 'pdf') {
      contentType = MediaType('application', 'pdf');
    } else if (['jpg', 'jpeg'].contains(fileExtension)) {
      contentType = MediaType('image', 'jpeg');
    } else if (fileExtension == 'png') {
      contentType = MediaType('image', 'png');
    } else {
      contentType = MediaType('application', 'octet-stream');
    }
    
    final multipartFile = http.MultipartFile(
      'document',
      fileStream,
      fileLength,
      filename: fileName,
      contentType: contentType,
    );
    
    request.files.add(multipartFile);
    
    // Add other fields
    if (notes != null && notes.isNotEmpty) {
      request.fields['notes'] = notes;
    }
    if (paymentPlanId != null) {
      request.fields['payment_plan_id'] = paymentPlanId.toString();
    }
    
    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorBody = json.decode(response.body);
      throw Exception(
        errorBody['message'] as String? ?? 
        'Failed to upload document: ${response.statusCode}'
      );
    }
    
    final data = json.decode(response.body) as Map<String, dynamic>;
    return PaymentDocument.fromJson(data);
  }

  // Get all payment documents
  static Future<List<PaymentDocument>> getDocuments({
    int? paymentPlanId,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (paymentPlanId != null) {
      queryParams['payment_plan_id'] = paymentPlanId.toString();
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    
    final uri = Uri.parse(WPConfig.paymentDocumentsApiUrl)
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    
    final headers = await buildAuthHeaders();
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to load payment documents: ${response.statusCode}');
    }
    
    final data = json.decode(response.body) as Map<String, dynamic>;
    final documentsList = (data['data'] as List?) ?? 
                         (data['documents'] as List?) ?? 
                         (data is List ? data : <dynamic>[]);
    
    if (data is List) {
      return data.map((e) => PaymentDocument.fromJson(e as Map<String, dynamic>)).toList();
    }
    
    return documentsList.map((e) {
      if (e is! Map<String, dynamic>) {
        throw Exception('Invalid payment document item');
      }
      return PaymentDocument.fromJson(e);
    }).toList();
  }

  // Get single payment document
  static Future<PaymentDocument> getDocument(int id) async {
    final uri = Uri.parse(WPConfig.paymentDocumentApiUrl(id));
    final headers = await buildAuthHeaders();
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to load payment document: ${response.statusCode}');
    }
    
    final data = json.decode(response.body) as Map<String, dynamic>;
    return PaymentDocument.fromJson(data);
  }
}

