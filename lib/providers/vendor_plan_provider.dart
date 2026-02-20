import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VendorPlanProvider extends ChangeNotifier {
  bool _hasActivePlan = false;
  bool _isChecking = true;

  bool get hasActivePlan => _hasActivePlan;
  bool get isChecking => _isChecking;

  Future<void> checkVendorPlan(String vendorId) async {
    _isChecking = true;
    notifyListeners();

    try {
      final res = await http.get(
        Uri.parse('https://api.vegiffyy.com/api/vendor/myplan/$vendorId'),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 &&
          data['success'] == true &&
          data['data'] != null &&
          data['data']['status'] == 'completed') {
        _hasActivePlan = true;
      } else {
        _hasActivePlan = false;
      }
    } catch (_) {
      _hasActivePlan = false;
    }

    _isChecking = false;
    notifyListeners();
  }
}