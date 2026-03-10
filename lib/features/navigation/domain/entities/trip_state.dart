import 'package:equatable/equatable.dart';

import '../../../../services/navigation_service.dart';
import '../../../rides/domain/entities/ride_entity.dart';

enum TripPhase { navigatingToPickup, waitingForPassenger, inTrip, completed }

class TripState extends Equatable {
  final RideEntity? ride;
  final TripPhase phase;
  final RouteInfo? pickupRoute;
  final RouteInfo? tripRoute;
  final int currentStepIndex;
  final bool isLoading;
  final String? error;

  const TripState({
    this.ride,
    this.phase = TripPhase.navigatingToPickup,
    this.pickupRoute,
    this.tripRoute,
    this.currentStepIndex = 0,
    this.isLoading = false,
    this.error,
  });

  RouteInfo? get activeRoute {
    switch (phase) {
      case TripPhase.navigatingToPickup:
        return pickupRoute;
      case TripPhase.inTrip:
        return tripRoute;
      default:
        return null;
    }
  }

  RouteStep? get currentStep {
    final route = activeRoute;
    if (route == null || currentStepIndex >= route.steps.length) return null;
    return route.steps[currentStepIndex];
  }

  bool get hasTrip => ride != null;

  TripState copyWith({
    RideEntity? ride,
    TripPhase? phase,
    RouteInfo? pickupRoute,
    RouteInfo? tripRoute,
    int? currentStepIndex,
    bool? isLoading,
    String? error,
    bool clearRide = false,
  }) {
    return TripState(
      ride: clearRide ? null : (ride ?? this.ride),
      phase: phase ?? this.phase,
      pickupRoute: pickupRoute ?? this.pickupRoute,
      tripRoute: tripRoute ?? this.tripRoute,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [ride, phase, currentStepIndex, isLoading];
}
