import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../data/datasources/ride_remote_datasource.dart';
import '../../data/repositories/ride_repository_impl.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/ride_repository.dart';

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepositoryImpl(
    RideRemoteDataSource(ref.read(apiClientProvider)),
  );
});

class RidesState {
  final List<RideEntity> availableRides;
  final RideEntity? selectedRide;
  final RideEntity? activeRide;
  final bool isLoading;
  final String? error;

  const RidesState({
    this.availableRides = const [],
    this.selectedRide,
    this.activeRide,
    this.isLoading = false,
    this.error,
  });

  RidesState copyWith({
    List<RideEntity>? availableRides,
    RideEntity? selectedRide,
    RideEntity? activeRide,
    bool? isLoading,
    String? error,
    bool clearSelectedRide = false,
    bool clearActiveRide = false,
  }) {
    return RidesState(
      availableRides: availableRides ?? this.availableRides,
      selectedRide: clearSelectedRide ? null : (selectedRide ?? this.selectedRide),
      activeRide: clearActiveRide ? null : (activeRide ?? this.activeRide),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RidesNotifier extends StateNotifier<RidesState> {
  final RideRepository _repository;

  RidesNotifier(this._repository) : super(const RidesState());

  Future<void> loadAvailableRides({
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.getAvailableRides(
      latitude: latitude,
      longitude: longitude,
    );

    switch (result) {
      case ApiSuccess<List<RideEntity>>():
        state = state.copyWith(
          availableRides: result.data,
          isLoading: false,
        );
      case ApiError<List<RideEntity>>():
        state = state.copyWith(isLoading: false, error: result.message);
      case ApiLoading<List<RideEntity>>():
        break;
    }
  }

  void selectRide(RideEntity ride) {
    state = state.copyWith(selectedRide: ride);
  }

  void clearSelectedRide() {
    state = state.copyWith(clearSelectedRide: true);
  }

  Future<bool> acceptRide(String rideId) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.acceptRide(rideId);

    switch (result) {
      case ApiSuccess<RideEntity>():
        state = state.copyWith(
          activeRide: result.data,
          isLoading: false,
          clearSelectedRide: true,
          availableRides: state.availableRides
              .where((r) => r.id != rideId)
              .toList(),
        );
        return true;
      case ApiError<RideEntity>():
        state = state.copyWith(isLoading: false, error: result.message);
        return false;
      case ApiLoading<RideEntity>():
        return false;
    }
  }
}

final ridesProvider = StateNotifierProvider<RidesNotifier, RidesState>((ref) {
  return RidesNotifier(ref.read(rideRepositoryProvider));
});
