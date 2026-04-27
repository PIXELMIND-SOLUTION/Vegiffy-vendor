import 'dart:convert';
import 'package:http/http.dart' as http;

class WalletService {
  static const base = "https://api.vegiffy.in/api";

  static Future<Map<String, dynamic>> getWallet(String vendorId) async {
    final res = await http.get(Uri.parse("$base/getwallet/$vendorId"));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getAccounts(String vendorId) async {
    final res = await http.get(
      Uri.parse("$base/vendor/allaccounts/$vendorId"),
    );
    final body = jsonDecode(res.body);
    return body['data'] ?? [];
  }

  static Future<void> withdraw({
    required String vendorId,
    required double amount,
    required Map<String, dynamic> account,
  }) async {
    final res = await http.post(
      Uri.parse("$base/walletwithdraw/$vendorId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": amount,
        "accountDetails": account,
      }),
    );

    final body = jsonDecode(res.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }
}
