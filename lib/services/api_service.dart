import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  String? authToken;

  ApiService({required this.baseUrl, this.authToken});

  void setAuthToken(String? token) {
    authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.get(
        url,
        headers: _headers,
      );

      // Handle empty response
      if (response.body.isEmpty) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Empty response from server',
        );
      }

      // Check if response is HTML (404 error page)
      if (response.statusCode == 404 && response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
        throw ApiException(
          statusCode: 404,
          message: 'Endpoint not found: $endpoint\n\nYour backend returned a 404 HTML page. Please verify:\n1. The endpoint exists: $baseUrl$endpoint\n2. The route path is correct\n3. The backend server is running',
        );
      }

      // Try to parse JSON
      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        throw ApiException(
          statusCode: response.statusCode,
          message: response.statusCode == 404 
            ? 'Endpoint not found: $endpoint\n\nPlease check if your backend has this route: $baseUrl$endpoint'
            : 'Invalid JSON response: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}',
        );
      }

      // Ensure it's a Map
      if (responseData is! Map<String, dynamic>) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Response is not a valid JSON object',
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData as Map<String, dynamic>;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: responseData['error'] ?? responseData['message'] ?? 'Request failed',
          details: responseData['message'],
        );
      }
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      // Handle empty response
      if (response.body.isEmpty) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Empty response from server',
        );
      }

      // Try to parse JSON
      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Invalid JSON response: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}',
        );
      }

      // Ensure it's a Map
      if (responseData is! Map<String, dynamic>) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Response is not a valid JSON object',
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData as Map<String, dynamic>;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: responseData['error'] ?? responseData['message'] ?? 'Request failed',
          details: responseData['message'],
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: 'Unexpected error: $e',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? details;

  ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: $message${details != null ? ", details: $details" : ""})';
  }
}
