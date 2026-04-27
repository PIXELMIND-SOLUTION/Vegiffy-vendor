import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProductService {
  static const baseUrl = "https://api.vegiffy.in/api";

  /// GET PRODUCTS
  static Future<Map<String, dynamic>> getProducts(String vendorId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/restaurant-products/$vendorId"),
    );
    return jsonDecode(res.body);
  }

  /// CREATE PRODUCT
  static Future<void> createProduct({
    required String vendorId,
    required List<Map<String, dynamic>> recommended,
    required List<File> images,
  }) async {
    final req = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/restaurant-products"),
    );

    req.fields['restaurantId'] = vendorId;
    req.fields['recommended'] = jsonEncode(recommended);

    for (final img in images) {
      req.files.add(
        await http.MultipartFile.fromPath("recommendedImages", img.path),
      );
    }

    final res = await req.send();
    final body = jsonDecode(await res.stream.bytesToString());
    if (!body['success']) throw Exception(body['message']);
  }

  /// UPDATE PRODUCT / STATUS
  static Future<void> updateProduct({
    required String productId,
    required String recommendedId,
    required Map<String, dynamic> recommendedData,
    File? image,
    List<String>? type,
  }) async {
    final req = http.MultipartRequest(
      "PUT",
      Uri.parse("$baseUrl/restaurant-product/$productId/$recommendedId"),
    );

    req.fields['recommended'] = jsonEncode(recommendedData);

    if (type != null) {
      req.fields['type'] = jsonEncode(type);
    }

    if (image != null) {
      req.files.add(
        await http.MultipartFile.fromPath("recommendedImage", image.path),
      );
    }

    final res = await req.send();
    final body = jsonDecode(await res.stream.bytesToString());
    if (!body['success']) throw Exception(body['message']);
  }

  /// DELETE PRODUCT
  static Future<void> deleteProduct(
      String productId, String recommendedId) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/restaurant-product/$productId/$recommendedId"),
    );
    final body = jsonDecode(res.body);
    if (!body['success']) throw Exception(body['message']);
  }
}
