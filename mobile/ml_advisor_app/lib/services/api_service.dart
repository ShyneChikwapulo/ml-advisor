import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  void setToken(String token) => _authToken = token;
  void clearToken() => _authToken = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<dynamic> get(String path) async {
    final response = await http
        .get(Uri.parse('${AppConstants.baseUrl}$path'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    return _handle(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http
        .post(
          Uri.parse('${AppConstants.baseUrl}$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _handle(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http
        .put(
          Uri.parse('${AppConstants.baseUrl}$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _handle(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http
        .delete(Uri.parse('${AppConstants.baseUrl}$path'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw Exception(data['detail'] ?? 'Request failed: ${response.statusCode}');
  }
}