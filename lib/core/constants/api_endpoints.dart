abstract final class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleAuth = '/auth/google';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Driver
  static const String driverProfile = '/driver/profile';
  static const String driverLocation = '/driver/location';
  static const String driverStatus = '/driver/status';

  // Rides
  static const String availableRides = '/rides/available';
  static const String acceptRide = '/rides/accept';
  static const String rideDetails = '/rides/{id}';
  static const String rideHistory = '/rides/history';

  // Wallet
  static const String walletBalance = '/wallet/balance';
  static const String walletTransactions = '/wallet/transactions';
  static const String purchaseCredits = '/wallet/purchase';

  // Payments
  static const String createPaymentIntent = '/payments/intent';
  static const String confirmPayment = '/payments/confirm';

  // Earnings
  static const String driverEarnings = '/driver/earnings';
  static const String driverEarningsHistory = '/driver/earnings/history';

  // Notifications
  static const String notifications = '/notifications';
  static const String registerFcmToken = '/notifications/fcm';
}
