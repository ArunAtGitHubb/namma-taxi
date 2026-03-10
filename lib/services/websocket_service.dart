import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/network/token_storage.dart';
import '../core/utils/logger.dart';

enum WebSocketStatus { disconnected, connecting, connected, reconnecting }

class RideRequestEvent {
  final String rideId;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final String pickupAddress;
  final String dropAddress;
  final double fare;
  final double distanceKm;
  final int estimatedMinutes;
  final String rideType;
  final DateTime expiresAt;

  RideRequestEvent({
    required this.rideId,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.pickupAddress,
    required this.dropAddress,
    required this.fare,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.rideType,
    required this.expiresAt,
  });

  factory RideRequestEvent.fromJson(Map<String, dynamic> json) {
    return RideRequestEvent(
      rideId: json['ride_id'] as String,
      pickupLat: (json['pickup_lat'] as num).toDouble(),
      pickupLng: (json['pickup_lng'] as num).toDouble(),
      dropLat: (json['drop_lat'] as num).toDouble(),
      dropLng: (json['drop_lng'] as num).toDouble(),
      pickupAddress: json['pickup_address'] as String,
      dropAddress: json['drop_address'] as String,
      fare: (json['fare'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      estimatedMinutes: json['estimated_minutes'] as int,
      rideType: json['ride_type'] as String? ?? 'standard',
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remainingTime => expiresAt.difference(DateTime.now());
}

class WebSocketService {
  static const String _wsBaseUrl = 'wss://api.nammataxi.com/ws/driver';
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _pingInterval = Duration(seconds: 30);
  static const int _maxReconnectAttempts = 10;

  final TokenStorage _tokenStorage;

  WebSocketChannel? _channel;
  WebSocketStatus _status = WebSocketStatus.disconnected;
  int _reconnectAttempts = 0;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  final _statusController = StreamController<WebSocketStatus>.broadcast();
  final _rideRequestController = StreamController<RideRequestEvent>.broadcast();
  final _rideExpiredController = StreamController<String>.broadcast();
  final _rideCancelledController = StreamController<String>.broadcast();

  Stream<WebSocketStatus> get statusStream => _statusController.stream;
  Stream<RideRequestEvent> get rideRequests => _rideRequestController.stream;
  Stream<String> get rideExpired => _rideExpiredController.stream;
  Stream<String> get rideCancelled => _rideCancelledController.stream;
  WebSocketStatus get status => _status;

  WebSocketService(this._tokenStorage);

  Future<void> connect() async {
    if (_status == WebSocketStatus.connected ||
        _status == WebSocketStatus.connecting) {
      return;
    }

    _setStatus(WebSocketStatus.connecting);

    try {
      final token = await _tokenStorage.getAccessToken();
      final uri = Uri.parse('$_wsBaseUrl?token=$token');

      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _setStatus(WebSocketStatus.connected);
      _reconnectAttempts = 0;
      _startPingTimer();

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      logger.i('WebSocket connected');
    } catch (e) {
      logger.e('WebSocket connection failed', error: e);
      _setStatus(WebSocketStatus.disconnected);
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _reconnectAttempts = 0;
    _setStatus(WebSocketStatus.disconnected);
    logger.i('WebSocket disconnected');
  }

  void sendLocationUpdate(double lat, double lng, double? heading) {
    _send({
      'type': 'location_update',
      'lat': lat,
      'lng': lng,
      'heading': heading,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void sendRideAccepted(String rideId) {
    _send({'type': 'ride_accepted', 'ride_id': rideId});
  }

  void sendRideRejected(String rideId) {
    _send({'type': 'ride_rejected', 'ride_id': rideId});
  }

  void sendDriverStatus(bool isOnline) {
    _send({'type': 'driver_status', 'is_online': isOnline});
  }

  void _send(Map<String, dynamic> data) {
      if (_status != WebSocketStatus.connected) {
      return;
    }
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (e) {
      logger.e('WebSocket send error', error: e);
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String;

      switch (type) {
        case 'ride_request':
          final event = RideRequestEvent.fromJson(data['data'] as Map<String, dynamic>);
          if (!event.isExpired) {
            _rideRequestController.add(event);
          }
        case 'ride_expired':
          _rideExpiredController.add(data['ride_id'] as String);
        case 'ride_cancelled':
          _rideCancelledController.add(data['ride_id'] as String);
        case 'pong':
          break;
        default:
          logger.w('Unknown WebSocket message type: $type');
      }
    } catch (e) {
      logger.e('WebSocket message parse error', error: e);
    }
  }

  void _onError(dynamic error) {
    logger.e('WebSocket error', error: error);
    _scheduleReconnect();
  }

  void _onDone() {
    logger.w('WebSocket connection closed');
    _setStatus(WebSocketStatus.disconnected);
    _pingTimer?.cancel();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      logger.e('Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    final delay = _reconnectDelay * (_reconnectAttempts + 1);
    _reconnectAttempts++;
    _setStatus(WebSocketStatus.reconnecting);

    _reconnectTimer = Timer(delay, () {
      logger.i('Reconnecting (attempt $_reconnectAttempts)...');
      connect();
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      _send({'type': 'ping'});
    });
  }

  void _setStatus(WebSocketStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _rideRequestController.close();
    _rideExpiredController.close();
    _rideCancelledController.close();
  }
}

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final service = WebSocketService(tokenStorage);
  ref.onDispose(() => service.dispose());
  return service;
});
