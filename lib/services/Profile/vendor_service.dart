import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:vegiffyy_vendor/models/Profile/vendor_model.dart';

class VendorService {
  static const base = "https://api.vegiffy.in/api";

  Future<VendorModel> fetchProfile(String vendorId) async {
    print("lllllllllllllllllllllllllllllllllllll$vendorId");

    final res = await http.get(Uri.parse("$base/profile/$vendorId"));
    final body = jsonDecode(res.body);
    print("lllllllllllllllllllllllllllllllllllll${res.body}");
    return VendorModel.fromJson(body['data']);
  }

  Future<void> updateProfile(
    String vendorId,
    Map<String, String> fields,
    File? imageFile,
  ) async {
    final uri = Uri.parse("$base/restaurant/$vendorId");

    final request = http.MultipartRequest('PUT', uri);

    /// text fields
    request.fields.addAll(fields);

    /// image file
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // 🔥 MUST MATCH BACKEND FIELD
          imageFile.path,
        ),
      );
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("Image update failed: $resBody");
    }
  }

  Future<void> uploadDocuments(
    String vendorId,
    Map<String, String> docs,
  ) async {
    final uri = Uri.parse("$base/documents/$vendorId");
    final request = http.MultipartRequest('PUT', uri);

    for (final entry in docs.entries) {
      request.files.add(
        await http.MultipartFile.fromPath(
          entry.key,
          entry.value,
        ),
      );
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception("Document upload failed");
    }
  }
}
