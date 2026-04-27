// lib/constants/api_constants.dart
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.vegiffy.in/api';

  // Auth
  static const String vendorLogin = '$baseUrl/vendor/vendorlogin';
  static const String verifyVendorOtp = '$baseUrl/vendor/verify-otp';

  // Dashboard
  static const String vendorDashboard = '$baseUrl/vendor/dashboard';
  static const String vendorRestaurantOrders =
      '$baseUrl/vendor/restaurantorders';
  static const String restaurantProducts = '$baseUrl/restaurant-products';

  // Orders
  // no trailing slash -> we'll append in service
  static const String acceptOrder = '$baseUrl/acceptorder';
}
