import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  String? _token;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> sendOtp(String phone, {String countryCode = '+91'}) async {
    final res = await http.post(
      Uri.parse('${apiBaseUrl}/api/auth/send-otp'),
      headers: _headers,
      body: jsonEncode({'phone': phone, 'countryCode': countryCode}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp, {String countryCode = '+91'}) async {
    final res = await http.post(
      Uri.parse('${apiBaseUrl}/api/auth/verify-otp'),
      headers: _headers,
      body: jsonEncode({'phone': phone, 'countryCode': countryCode, 'otp': otp}),
    );
    final data = _decode(res);
    if (data['token'] != null) {
      await saveToken(data['token'] as String);
    }
    return data;
  }

  Future<List<dynamic>> getTransports() async {
    final res = await http.get(
      Uri.parse('${apiBaseUrl}/api/catalog/transports'),
      headers: _headers,
    );
    final data = _decode(res);
    return data is List ? data : (data['data'] as List?) ?? [];
  }

  Future<List<dynamic>> getRecentLocations() async {
    final res = await http.get(
      Uri.parse('${apiBaseUrl}/api/catalog/recent-locations'),
      headers: _headers,
    );
    final data = _decode(res);
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('${apiBaseUrl}/api/bookings'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    final body = res.body.isEmpty ? {} : jsonDecode(res.body);
    if (res.statusCode >= 400) {
      String msg = 'Request failed';
      if (body is Map) {
        if (body['error'] != null) {
          msg = body['error'].toString();
        } else if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
          msg = (body['errors'] as List)
              .map((e) => (e as Map)['msg']?.toString())
              .whereType<String>()
              .join('. ');
        } else if (body['message'] != null) {
          msg = body['message'].toString();
        }
      }
      throw ApiException(msg, res.statusCode);
    }
    return body;
  }
}

class ApiException implements Exception {
  ApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
