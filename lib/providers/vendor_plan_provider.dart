import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VendorPlanProvider extends ChangeNotifier {
  bool _hasActivePlan = false;
  bool _isChecking = true;
  String? _errorMessage;
  Map<String, dynamic>? _planData;

  bool get hasActivePlan => _hasActivePlan;
  bool get isChecking => _isChecking;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get planData => _planData;

  Future<void> checkVendorPlan(String vendorId) async {
    _isChecking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Checking plan for vendor: $vendorId');

      final res = await http
          .get(
        Uri.parse('https://api.vegiffy.in/api/vendor/myplan/$vendorId'),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('Response status code: ${res.statusCode}');
      print('Response body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // Check if plan exists and is completed
        final bool hasValidPlan = data['success'] == true &&
            data['data'] != null &&
            data['data']['status'] == 'completed';

        _hasActivePlan = hasValidPlan;
        _planData = data['data'];

        print('Has active plan: $_hasActivePlan');
        print('Plan data: $_planData');
      } else {
        _hasActivePlan = false;
        _errorMessage = 'Failed to load plan data';
        print('Error: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      _hasActivePlan = false;
      _errorMessage = e.toString();
      print('Exception in checkVendorPlan: $e');
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  // Helper method to reset state (useful for logout)
  void reset() {
    _hasActivePlan = false;
    _isChecking = true;
    _errorMessage = null;
    _planData = null;
    notifyListeners();
  }
}
