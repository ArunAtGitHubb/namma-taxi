abstract final class AppConstants {
  static const String appName = 'Namma Taxi';
  static const String appTagline = 'Drive. Earn. Grow.';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.nammataxi.com/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Map defaults (Bangalore center)
  static const double defaultLatitude = 12.9716;
  static const double defaultLongitude = 77.5946;
  static const double defaultZoom = 14.0;

  // Credits
  static const int creditsPerRide = 1;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
}
