import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/driver_api_service.dart';
import '../../../../services/websocket_service.dart';
import '../../../map/presentation/providers/map_provider.dart';

class DriverStatusState {
  final bool isOnline;
  final bool isToggling;
  final DateTime? onlineSince;

  const DriverStatusState({
    this.isOnline = false,
    this.isToggling = false,
    this.onlineSince,
  });

  DriverStatusState copyWith({
    bool? isOnline,
    bool? isToggling,
    DateTime? onlineSince,
    bool clearOnlineSince = false,
  }) {
    return DriverStatusState(
      isOnline: isOnline ?? this.isOnline,
      isToggling: isToggling ?? this.isToggling,
      onlineSince: clearOnlineSince ? null : (onlineSince ?? this.onlineSince),
    );
  }

  String get onlineDuration {
    if (onlineSince == null) return '0m';
    final diff = DateTime.now().difference(onlineSince!);
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes}m';
  }
}

class DriverStatusNotifier extends StateNotifier<DriverStatusState> {
  final ApiClient _apiClient;
  final WebSocketService _wsService;
  final MapNotifier _mapNotifier;
  final DriverApiService _driverApiService;
  Timer? _locationPushTimer;

  DriverStatusNotifier({
    required ApiClient apiClient,
    required WebSocketService wsService,
    required MapNotifier mapNotifier,
    required DriverApiService driverApiService,
  })  : _apiClient = apiClient,
        _wsService = wsService,
        _mapNotifier = mapNotifier,
        _driverApiService = driverApiService,
        super(const DriverStatusState());

  Future<void> goOnline() async {
    if (state.isOnline || state.isToggling) return;
    state = state.copyWith(isToggling: true);

    try {
      await _apiClient.post(
        ApiEndpoints.driverStatus,
        data: {'status': 'online'},
      );

      await _wsService.connect();
      _wsService.sendDriverStatus(true);
      _mapNotifier.startTracking();
      _startLocationPushTimer();

      state = state.copyWith(
        isOnline: true,
        isToggling: false,
        onlineSince: DateTime.now(),
      );
      logger.i('Driver is now online');
    } catch (e) {
      state = state.copyWith(isToggling: false);
      logger.e('Failed to go online', error: e);
    }
  }

  Future<void> goOffline() async {
    if (!state.isOnline || state.isToggling) return;
    state = state.copyWith(isToggling: true);

    try {
      _wsService.sendDriverStatus(false);
      _wsService.disconnect();
      _mapNotifier.stopTracking();
      _locationPushTimer?.cancel();

      await _apiClient.post(
        ApiEndpoints.driverStatus,
        data: {'status': 'offline'},
      );

      state = state.copyWith(
        isOnline: false,
        isToggling: false,
        clearOnlineSince: true,
      );
      logger.i('Driver is now offline');
    } catch (e) {
      state = state.copyWith(isToggling: false);
      logger.e('Failed to go offline', error: e);
    }
  }

  Future<void> toggle() async {
    if (state.isOnline) {
      await goOffline();
    } else {
      await goOnline();
    }
  }

  void _startLocationPushTimer() {
    _locationPushTimer?.cancel();
    _locationPushTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final loc = _mapNotifier.state.currentLocation;
      if (loc != null) {
        if (_wsService.status == WebSocketStatus.connected) {
          _wsService.sendLocationUpdate(
            loc.latitude,
            loc.longitude,
            loc.heading,
          );
        } else {
          _driverApiService.updateLocation(
            latitude: loc.latitude,
            longitude: loc.longitude,
            heading: loc.heading,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _locationPushTimer?.cancel();
    super.dispose();
  }
}

final driverStatusProvider =
    StateNotifierProvider<DriverStatusNotifier, DriverStatusState>((ref) {
  return DriverStatusNotifier(
    apiClient: ref.read(apiClientProvider),
    wsService: ref.read(webSocketServiceProvider),
    mapNotifier: ref.read(mapProvider.notifier),
    driverApiService: ref.read(driverApiServiceProvider),
  );
});
