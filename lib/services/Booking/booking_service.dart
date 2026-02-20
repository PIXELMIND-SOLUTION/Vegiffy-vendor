// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:vegiffyy_vendor/models/Booking/booking_model.dart';

// class BookingService {
//   static const baseUrl = "https://api.vegiffyy.com/api";

//   static Future<List<BookingModel>> fetchBookings(String vendorId) async {
//     final res = await http.get(
//       Uri.parse("$baseUrl/vendor/restaurantorders/$vendorId"),
//     );

//     final data = jsonDecode(res.body);
//     if (!data['success']) throw Exception("Failed to fetch orders");

//     return (data['data'] as List)
//         .map((e) => BookingModel.fromJson(e))
//         .toList();
//   }

//   static Future<void> updateStatus(
//       String orderId, String vendorId, Map body) async {
//     final res = await http.put(
//       Uri.parse("$baseUrl/acceptorder/$orderId/$vendorId"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(body),
//     );

//     if (res.statusCode != 200) {
//       throw Exception("Failed to update status");
//     }
//   }

//   static Future<void> deleteOrder(String id) async {
//     final res = await http.delete(
//       Uri.parse("$baseUrl/vendor/deleteorder/$id"),
//     );
//     if (res.statusCode != 200) {
//       throw Exception("Delete failed");
//     }
//   }
// }

















import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vegiffyy_vendor/models/Booking/booking_model.dart';

class BookingService {
  static const baseUrl = "https://api.vegiffyy.com/api";

  /// ==========================
  /// FETCH ALL BOOKINGS
  /// ==========================
  static Future<List<BookingModel>> fetchBookings(String vendorId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/vendor/restaurantorders/$vendorId"),
    );

    final data = jsonDecode(res.body);
    if (!data['success']) {
      throw Exception("Failed to fetch orders");
    }

    return (data['data'] as List)
        .map((e) => BookingModel.fromJson(e))
        .toList();
  }

  /// ==========================
  /// FETCH PENDING BOOKINGS
  /// ==========================
  static Future<List<BookingModel>> fetchPendingBookings(
      String vendorId) async {
    final bookings = await fetchBookings(vendorId);

    print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk${bookings[0].status}");

    return bookings
        .where(
          (order) =>
              order.status != null &&
              order.status.toLowerCase() == "pending",
        )
        .toList();
  }

  /// ==========================
  /// FETCH COMPLETED BOOKINGS
  /// ==========================
  static Future<List<BookingModel>> fetchCompletedBookings(
      String vendorId) async {
    final bookings = await fetchBookings(vendorId);

    return bookings
        .where(
          (order) =>
              order.status != null &&
              order.status!.toLowerCase() == "delivered",
        )
        .toList();
  }

  /// ==========================
  /// UPDATE ORDER STATUS
  /// ==========================
  static Future<void> updateStatus(
      String orderId, String vendorId, Map body) async {
    final res = await http.put(
      Uri.parse("$baseUrl/acceptorder/$orderId/$vendorId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update status");
    }
  }

  /// ==========================
  /// DELETE ORDER
  /// ==========================
  static Future<void> deleteOrder(String id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/vendor/deleteorder/$id"),
    );

    if (res.statusCode != 200) {
      throw Exception("Delete failed");
    }
  }
}
