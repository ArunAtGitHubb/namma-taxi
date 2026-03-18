import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/navigation_service.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../../../rides/domain/repositories/ride_repository.dart';
import '../../../rides/presentation/providers/rides_provider.dart';
import '../../domain/entities/trip_state.dart';

class TripNotifier extends StateNotifier<TripState> {
  final NavigationService _navigationService;
  final MapNotifier _mapNotifier;
  final RideRepository _rideRepository;

  TripNotifier({
    required NavigationService navigationService,
    required MapNotifier mapNotifier,
    required RideRepository rideRepository,
  })  : _navigationService = navigationService,
        _mapNotifier = mapNotifier,
        _rideRepository = rideRepository,
        super(const TripState());

  Future<void> startTrip(RideEntity ride) async {
    state = state.copyWith(ride: ride, isLoading: true);

    final driverLoc = _mapNotifier.state.currentLocation;
    if (driverLoc == null) {
      state = state.copyWith(isLoading: false, error: 'Location unavailable');
      return;
    }

    try {
      final routes = await _navigationService.getFullRoute(
        driverLat: driverLoc.latitude,
        driverLng: driverLoc.longitude,
        pickupLat: ride.pickupLocation.latitude,
        pickupLng: ride.pickupLocation.longitude,
        dropLat: ride.dropLocation.latitude,
        dropLng: ride.dropLocation.longitude,
      );

      state = state.copyWith(
        pickupRoute: routes.pickupRoute,
        tripRoute: routes.tripRoute,
        phase: TripPhase.navigatingToPickup,
        isLoading: false,
        currentStepIndex: 0,
      );

      logger.i('Trip routes loaded');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load route');
      logger.e('Trip route error', error: e);
    }
  }

  Future<void> arrivedAtPickup() async {
    final ride = state.ride;
    if (ride == null) return;

    state = state.copyWith(isLoading: true);

    final result = await _rideRepository.startPickup(ride.id);

    switch (result) {
      case ApiSuccess():
        state = state.copyWith(
          phase: TripPhase.waitingForPassenger,
          currentStepIndex: 0,
          isLoading: false,
        );
        logger.i('Arrived at pickup');
      case ApiError():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
        logger.e('Start pickup failed: ${result.message}');
      case ApiLoading():
        break;
    }
  }

  Future<void> beginTrip() async {
    final ride = state.ride;
    if (ride == null) return;

    state = state.copyWith(isLoading: true);

    final result = await _rideRepository.beginTrip(ride.id);

    switch (result) {
      case ApiSuccess():
        state = state.copyWith(
          phase: TripPhase.inTrip,
          currentStepIndex: 0,
          isLoading: false,
        );
        logger.i('Trip started');
      case ApiError():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
        logger.e('Begin trip failed: ${result.message}');
      case ApiLoading():
        break;
    }
  }

  void nextStep() {
    final route = state.activeRoute;
    if (route == null) return;

    if (state.currentStepIndex < route.steps.length - 1) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    }
  }

  Future<void> completeTrip() async {
    final ride = state.ride;
    if (ride == null) return;

    state = state.copyWith(isLoading: true);

    final tripRoute = state.tripRoute;
    final finalDistanceKm =
        tripRoute?.distanceKm ?? ride.distanceKm;
    final finalFare = ride.estimatedEarnings;

    final result = await _rideRepository.completeRide(
      ride.id,
      dropLat: ride.dropLocation.latitude,
      dropLng: ride.dropLocation.longitude,
      finalDistanceKm: finalDistanceKm,
      finalFare: finalFare,
    );

    switch (result) {
      case ApiSuccess():
        state = state.copyWith(
          phase: TripPhase.completed,
          isLoading: false,
        );
        logger.i('Trip completed');
      case ApiError():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
        logger.e('Complete trip failed: ${result.message}');
      case ApiLoading():
        break;
    }
  }

  Future<void> cancelTrip({String? reason}) async {
    final ride = state.ride;

    if (ride != null) {
      state = state.copyWith(isLoading: true);

      final result = await _rideRepository.cancelRide(ride.id, reason: reason);

      switch (result) {
        case ApiSuccess():
          logger.i('Trip cancelled');
        case ApiError():
          logger.e('Cancel trip failed: ${result.message}');
        case ApiLoading():
          break;
      }
    }

    state = const TripState();
  }

  void clearTrip() {
    state = const TripState();
  }
}

final tripProvider = StateNotifierProvider<TripNotifier, TripState>((ref) {
  return TripNotifier(
    navigationService: ref.read(navigationServiceProvider),
    mapNotifier: ref.read(mapProvider.notifier),
    rideRepository: ref.read(rideRepositoryProvider),
  );
});
