import 'package:equatable/equatable.dart';

class RideEntity extends Equatable {
  final String id;
  final LatLng pickupLocation;
  final LatLng dropLocation;
  final String pickupAddress;
  final String dropAddress;
  final double distanceKm;
  final double estimatedEarnings;
  final int estimatedMinutes;
  final RideStatus status;
  final DateTime createdAt;
  final String? passengerName;

  const RideEntity({
    required this.id,
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupAddress,
    required this.dropAddress,
    required this.distanceKm,
    required this.estimatedEarnings,
    required this.estimatedMinutes,
    this.status = RideStatus.available,
    required this.createdAt,
    this.passengerName,
  });

  @override
  List<Object?> get props => [id, pickupLocation, dropLocation, status];
}

class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

enum RideStatus {
  available,
  accepted,
  pickingUp,
  inProgress,
  completed,
  cancelled,
}
