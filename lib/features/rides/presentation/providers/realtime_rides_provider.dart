import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/websocket_service.dart';
import '../../domain/entities/ride_entity.dart';
import 'rides_provider.dart';

/// Bridges WebSocket ride events to the rides state.
/// Handles timeouts, expiry, and ride lifecycle from real-time events.
class RealtimeRidesState {
  final List<RideEntity> pendingRequests;
  final bool isListening;

  const RealtimeRidesState({
    this.pendingRequests = const [],
    this.isListening = false,
  });

  RealtimeRidesState copyWith({
    List<RideEntity>? pendingRequests,
    bool? isListening,
  }) {
    return RealtimeRidesState(
      pendingRequests: pendingRequests ?? this.pendingRequests,
      isListening: isListening ?? this.isListening,
    );
  }
}

class RealtimeRidesNotifier extends StateNotifier<RealtimeRidesState> {
  final WebSocketService _wsService;
  final RidesNotifier _ridesNotifier;

  StreamSubscription<RideRequestEvent>? _requestSub;
  StreamSubscription<String>? _expiredSub;
  StreamSubscription<String>? _cancelledSub;
  final Map<String, Timer> _expiryTimers = {};

  RealtimeRidesNotifier({
    required WebSocketService wsService,
    required RidesNotifier ridesNotifier,
  })  : _wsService = wsService,
        _ridesNotifier = ridesNotifier,
        super(const RealtimeRidesState());

  void startListening() {
    if (state.isListening) return;

    _requestSub = _wsService.rideRequests.listen(_onRideRequest);
    _expiredSub = _wsService.rideExpired.listen(_onRideExpired);
    _cancelledSub = _wsService.rideCancelled.listen(_onRideCancelled);

    state = state.copyWith(isListening: true);
  }

  void stopListening() {
    _requestSub?.cancel();
    _expiredSub?.cancel();
    _cancelledSub?.cancel();
    _expiryTimers.forEach((_, timer) => timer.cancel());
    _expiryTimers.clear();
    state = const RealtimeRidesState();
  }

  void _onRideRequest(RideRequestEvent event) {
    final ride = RideEntity(
      id: event.rideId,
      pickupLocation: LatLng(
        latitude: event.pickupLat,
        longitude: event.pickupLng,
      ),
      dropLocation: LatLng(
        latitude: event.dropLat,
        longitude: event.dropLng,
      ),
      pickupAddress: event.pickupAddress,
      dropAddress: event.dropAddress,
      distanceKm: event.distanceKm,
      estimatedEarnings: event.fare,
      estimatedMinutes: event.estimatedMinutes,
      status: RideStatus.available,
      createdAt: DateTime.now(),
    );

    final updated = [...state.pendingRequests, ride];
    state = state.copyWith(pendingRequests: updated);

    // Auto-expire after timeout
    final timer = Timer(event.remainingTime, () {
      _removeRequest(event.rideId);
    });
    _expiryTimers[event.rideId] = timer;
  }

  void _onRideExpired(String rideId) {
    _removeRequest(rideId);
  }

  void _onRideCancelled(String rideId) {
    _removeRequest(rideId);
  }

  void _removeRequest(String rideId) {
    _expiryTimers[rideId]?.cancel();
    _expiryTimers.remove(rideId);

    final updated =
        state.pendingRequests.where((r) => r.id != rideId).toList();
    state = state.copyWith(pendingRequests: updated);
  }

  Future<bool> acceptRide(String rideId) async {
    _wsService.sendRideAccepted(rideId);
    _removeRequest(rideId);

    return _ridesNotifier.acceptRide(rideId);
  }

  void rejectRide(String rideId) {
    _wsService.sendRideRejected(rideId);
    _removeRequest(rideId);
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

final realtimeRidesProvider =
    StateNotifierProvider<RealtimeRidesNotifier, RealtimeRidesState>((ref) {
  return RealtimeRidesNotifier(
    wsService: ref.read(webSocketServiceProvider),
    ridesNotifier: ref.read(ridesProvider.notifier),
  );
});
