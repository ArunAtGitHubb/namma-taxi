import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/logger.dart';

enum NotificationType {
  rideRequest,
  creditAlert,
  paymentConfirmation,
  general,
}

class NotificationPayload {
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;

  const NotificationPayload({
    required this.title,
    required this.body,
    required this.type,
    this.data,
  });
}

/// Architecture-ready notification service.
/// Implement push notification logic (FCM/APNs) when backend is available.
class NotificationService {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    // TODO: Initialize Firebase Messaging / local notifications
    _isInitialized = true;
    logger.i('NotificationService initialized');
  }

  Future<String?> getFcmToken() async {
    // TODO: Return FCM token from Firebase Messaging
    return null;
  }

  Future<void> registerFcmToken(String token) async {
    // TODO: Send FCM token to backend
    logger.i('FCM token registered: $token');
  }

  void onNotificationReceived(NotificationPayload payload) {
    logger.i('Notification received: ${payload.title}');

    switch (payload.type) {
      case NotificationType.rideRequest:
        _handleRideRequest(payload);
      case NotificationType.creditAlert:
        _handleCreditAlert(payload);
      case NotificationType.paymentConfirmation:
        _handlePaymentConfirmation(payload);
      case NotificationType.general:
        _handleGeneral(payload);
    }
  }

  void _handleRideRequest(NotificationPayload payload) {
    // TODO: Show ride request notification / navigate to dashboard
  }

  void _handleCreditAlert(NotificationPayload payload) {
    // TODO: Show credit alert / navigate to wallet
  }

  void _handlePaymentConfirmation(NotificationPayload payload) {
    // TODO: Show payment confirmation
  }

  void _handleGeneral(NotificationPayload payload) {
    // TODO: Show generic notification
  }

  Future<void> dispose() async {
    _isInitialized = false;
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
