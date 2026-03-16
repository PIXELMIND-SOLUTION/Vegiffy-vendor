import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/auth_models.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

Future<VendorLoginResponse> loginVendor({
  required String email,
  required String password,
}) async {
  final uri = Uri.parse(ApiConstants.vendorLogin);
  final response = await _client.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  print("kkkkkkkkkkkkkkkkkkkkkkkkk${response.body}");

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final data = jsonDecode(response.body);
    return VendorLoginResponse.fromJson(data);
  } else {
    // Try to get error message and contact details from response body
    String errorMessage = 'Login failed (code: ${response.statusCode})';
    
    try {
      final errorData = jsonDecode(response.body);
      if (errorData['message'] != null) {
        errorMessage = errorData['message'];
        // Append contact details if they exist
        if (errorData['contactEmail'] != null || errorData['whatsapp'] != null) {
          errorMessage += '\n\nContact Support:';
          if (errorData['contactEmail'] != null) {
            errorMessage += '\n📧 ${errorData['contactEmail']}';
          }
          if (errorData['whatsapp'] != null) {
            errorMessage += '\n📱 ${errorData['whatsapp']}';
          }
        }
      }
    } catch (e) {
      // If response body is not valid JSON, use default message
    }
    
    throw Exception(errorMessage);
  }
}

  Future<VerifyOtpResponse> verifyOtp({
    required String vendorId,
    required String otp,
  }) async {
    final uri = Uri.parse(ApiConstants.verifyVendorOtp);
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'vendorId': vendorId, 'otp': otp}),
    );
print("sdkhfdsfjskdjfdsl;jfdsl;fds;f;k${response.body}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return VerifyOtpResponse.fromJson(data);
    } else {
      throw Exception('OTP verification failed (code: ${response.statusCode})');
    }
  }
}
