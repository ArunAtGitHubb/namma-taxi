import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../../services/navigation_service.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../../rides/domain/entities/ride_entity.dart';
import '../../domain/entities/trip_state.dart';

class TripNotifier extends StateNotifier<TripState> {
  final NavigationService _navigationService;
  final MapNotifier _mapNotifier;

  TripNotifier({
    required NavigationService navigationService,
    required MapNotifier mapNotifier,
  })  : _navigationService = navigationService,
        _mapNotifier = mapNotifier,
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

  void arrivedAtPickup() {
    state = state.copyWith(
      phase: TripPhase.waitingForPassenger,
      currentStepIndex: 0,
    );
  }

  void beginTrip() {
    state = state.copyWith(
      phase: TripPhase.inTrip,
      currentStepIndex: 0,
    );
  }

  void nextStep() {
    final route = state.activeRoute;
    if (route == null) return;

    if (state.currentStepIndex < route.steps.length - 1) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    }
  }

  void completeTrip() {
    state = state.copyWith(phase: TripPhase.completed);
  }

  void cancelTrip() {
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
  );
});
