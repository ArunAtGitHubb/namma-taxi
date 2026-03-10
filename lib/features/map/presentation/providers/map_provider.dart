import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../services/mapbox_service.dart';
import '../../domain/entities/driver_location.dart';

class MapState {
  final DriverLocation? currentLocation;
  final bool isTracking;
  final bool isLoading;
  final String? error;

  const MapState({
    this.currentLocation,
    this.isTracking = false,
    this.isLoading = false,
    this.error,
  });

  MapState copyWith({
    DriverLocation? currentLocation,
    bool? isTracking,
    bool? isLoading,
    String? error,
  }) {
    return MapState(
      currentLocation: currentLocation ?? this.currentLocation,
      isTracking: isTracking ?? this.isTracking,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  final MapboxService _mapboxService;
  StreamSubscription<Position>? _locationSubscription;

  MapNotifier(this._mapboxService) : super(const MapState());

  Future<void> initializeLocation() async {
    state = state.copyWith(isLoading: true);

    try {
      final position = await _mapboxService.getDefaultPosition();
      state = state.copyWith(
        currentLocation: DriverLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          heading: position.heading,
          speed: position.speed,
          timestamp: position.timestamp,
        ),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void startTracking() {
    if (state.isTracking) return;

    _locationSubscription = _mapboxService.getLocationStream().listen(
      (position) {
        state = state.copyWith(
          currentLocation: DriverLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            heading: position.heading,
            speed: position.speed,
            timestamp: position.timestamp,
          ),
          isTracking: true,
        );
      },
      onError: (e) {
        state = state.copyWith(error: e.toString());
      },
    );

    state = state.copyWith(isTracking: true);
  }

  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    state = state.copyWith(isTracking: false);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier(ref.read(mapboxServiceProvider));
});
