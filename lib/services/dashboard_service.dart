// lib/services/dashboard_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vegiffyy_vendor/constants/api_constants.dart';
import 'package:vegiffyy_vendor/models/dashboard_models.dart';
import 'package:vegiffyy_vendor/services/toast_service.dart';

class DashboardService {
  final http.Client _client;

  DashboardService({http.Client? client}) : _client = client ?? http.Client();

  /// GET: /vendor/dashboard/{vendorId}
  Future<DashboardResponse> fetchDashboard(String vendorId) async {
    final uri = Uri.parse('${ApiConstants.vendorDashboard}/$vendorId');
    // Example: http://31.97.206.144:5051/api/vendor/dashboard/692d62ec...

    final res = await _client.get(uri);
    // debug
    // print('Dashboard URL: $uri');
    // print('Dashboard body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to load dashboard (${res.statusCode})');
    }

    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    if (jsonBody['success'] != true) {
      throw Exception(jsonBody['message']?.toString() ?? 'Dashboard error');
    }

    return DashboardResponse.fromJson(jsonBody);
  }

  /// GET: /vendor/restaurantorders/{vendorId}
  Future<List<OrderModel>> fetchRestaurantOrders(String vendorId) async {
    final uri = Uri.parse('${ApiConstants.vendorRestaurantOrders}/$vendorId');
    // Example: http://31.97.206.144:5051/api/vendor/restaurantorders/692d...

    final res = await _client.get(uri);
    print('Orders URL: $uri');
    print('Orders body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to load restaurant orders (${res.statusCode})');
    }

    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    if (jsonBody['success'] != true) {
      throw Exception(jsonBody['message']?.toString() ?? 'Orders error');
    }

    final list = (jsonBody['data'] as List?) ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => OrderModel.fromJson(e))
        .toList();
  }

  /// GET: /restaurant-products/{vendorId}
  Future<List<RestaurantProduct>> fetchRestaurantProducts(
      String vendorId) async {
    final uri = Uri.parse('${ApiConstants.restaurantProducts}/$vendorId');
    // Example: http://31.97.206.144:5051/api/restaurant-products/692d...

    final res = await _client.get(uri);
    print('Products URL: $uri');
    print('Products body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to load restaurant products (${res.statusCode})');
    }

    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    final bool success = jsonBody['success'] == true;
    final String message =
        jsonBody['message'] ?? (success ? '' : 'Failed to update order');

    if (!success) {
      ToastService.showSuccess(message);
    }

    if (jsonBody['success'] != true) {
      throw Exception(jsonBody['message']?.toString() ?? 'Products error');
    }

    final list = (jsonBody['recommendedProducts'] as List?) ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => RestaurantProduct.fromJson(e))
        .toList();
  }

  /// PUT: /acceptorder/{orderId}/{vendorId}  with body { orderStatus: "Accepted"/"Rejected" }
  Future<bool> updateOrderStatus({
    required String orderId,
    required String vendorId,
    required String status,
  }) async {
    final uri = Uri.parse('${ApiConstants.acceptOrder}/$orderId/$vendorId');
    // Example: http://31.97.206.144:5051/api/acceptorder/ORDERID/VENDORID

    debugPrint('📞 ACCEPT ORDER CALLED - $uri');

    debugPrint('📞 ACCEPT ORDER CALLED - $status');

    final res = await _client.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'orderStatus': status}),
    );

    debugPrint('📞 RESSSSS - ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to update order (${res.statusCode})');
    }

    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    return jsonBody['success'] == true;
  }

  Future<bool> acceptOrder(String orderId, String vendorId) {
    return updateOrderStatus(
      orderId: orderId,
      vendorId: vendorId,
      status: 'Accepted',
    );
  }

  Future<bool> rejectOrder(String orderId, String vendorId) {
    return updateOrderStatus(
      orderId: orderId,
      vendorId: vendorId,
      status: 'Rejected',
    );
  }
}
