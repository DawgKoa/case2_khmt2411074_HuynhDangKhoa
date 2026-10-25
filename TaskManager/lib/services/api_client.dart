import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String get _baseUrl => AppConstants.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Yêu cầu thất bại với mã lỗi ${response.statusCode}';

    throw ApiException(message, response.statusCode);
  }

  ApiException _formatError(dynamic e) {
    if (e is ApiException) return e;
    final errorStr = e.toString();
    if (errorStr.contains('Connection refused') ||
        errorStr.contains('SocketException') ||
        errorStr.contains('Failed host lookup')) {
      return ApiException(
        'Không thể kết nối đến máy chủ backend (Port 5000). Vui lòng đảm bảo server Node.js đang chạy.',
      );
    }
    return ApiException('Không thể kết nối đến máy chủ: $e');
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final headers = await _getHeaders();
      Uri uri = Uri.parse('$_baseUrl$endpoint');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw _formatError(e);
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _formatError(e);
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _formatError(e);
    }
  }

  Future<dynamic> patch(String endpoint, [Map<String, dynamic>? data]) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.patch(
        uri,
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _formatError(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.delete(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw _formatError(e);
    }
  }
}
