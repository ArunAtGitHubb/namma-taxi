import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/utils/logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  logger.i('Background notification: ${message.messageId}');
}

enum InAppNotificationType { rideRequest, paymentSuccess, lowCredits, rideCancelled, general }

class InAppNotification {
  final String title;
  final String body;
  final InAppNotificationType type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  InAppNotification({
    required this.title,
    required this.body,
    required this.type,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class FirebaseNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiClient _apiClient;

  final _foregroundController = StreamController<InAppNotification>.broadcast();
  Stream<InAppNotification> get foregroundNotifications => _foregroundController.stream;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  FirebaseNotificationService(this._apiClient);

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      logger.i('FCM permission granted');
    } else {
      logger.w('FCM permission denied');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    await _registerToken();
    _messaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _apiClient.post(
          ApiEndpoints.registerFcmToken,
          data: {'fcm_token': token},
        );
        logger.i('FCM token registered');
      }
    } catch (e) {
      logger.e('FCM token registration failed', error: e);
    }
  }

  void _onTokenRefresh(String token) async {
    try {
      await _apiClient.post(
        ApiEndpoints.registerFcmToken,
        data: {'fcm_token': token},
      );
      logger.i('FCM token refreshed');
    } catch (e) {
      logger.e('FCM token refresh failed', error: e);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = _parseNotification(message);
    _foregroundController.add(notification);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;

    logger.i('Notification tap: $type');
    // Navigation logic handled by the listening widget via foregroundNotifications
  }

  InAppNotification _parseNotification(RemoteMessage message) {
    final data = message.data;
    final typeStr = data['type'] as String? ?? 'general';

    final type = switch (typeStr) {
      'ride_request' => InAppNotificationType.rideRequest,
      'payment_success' => InAppNotificationType.paymentSuccess,
      'low_credits' => InAppNotificationType.lowCredits,
      'ride_cancelled' => InAppNotificationType.rideCancelled,
      _ => InAppNotificationType.general,
    };

    return InAppNotification(
      title: message.notification?.title ?? 'Namma Taxi',
      body: message.notification?.body ?? '',
      type: type,
      data: data,
    );
  }

  Future<String?> getToken() => _messaging.getToken();

  void dispose() {
    _foregroundSub?.cancel();
    _openedAppSub?.cancel();
    _foregroundController.close();
  }
}

final firebaseNotificationServiceProvider = Provider<FirebaseNotificationService>((ref) {
  final service = FirebaseNotificationService(ref.read(apiClientProvider));
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider that exposes the foreground notification stream for UI consumption
final inAppNotificationStreamProvider = StreamProvider<InAppNotification>((ref) {
  return ref.read(firebaseNotificationServiceProvider).foregroundNotifications;
});
