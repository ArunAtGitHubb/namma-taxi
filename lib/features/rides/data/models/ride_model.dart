import '../../domain/entities/ride_entity.dart';

class RideModel extends RideEntity {
  const RideModel({
    required super.id,
    required super.pickupLocation,
    required super.dropLocation,
    required super.pickupAddress,
    required super.dropAddress,
    required super.distanceKm,
    required super.estimatedEarnings,
    required super.estimatedMinutes,
    super.status,
    required super.createdAt,
    super.passengerName,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as String,
      pickupLocation: LatLng(
        latitude: (json['pickup_lat'] as num).toDouble(),
        longitude: (json['pickup_lng'] as num).toDouble(),
      ),
      dropLocation: LatLng(
        latitude: (json['drop_lat'] as num).toDouble(),
        longitude: (json['drop_lng'] as num).toDouble(),
      ),
      pickupAddress: json['pickup_address'] as String,
      dropAddress: json['drop_address'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      estimatedEarnings: (json['estimated_earnings'] as num).toDouble(),
      estimatedMinutes: json['estimated_minutes'] as int,
      status: RideStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RideStatus.available,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      passengerName: json['passenger_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickup_lat': pickupLocation.latitude,
      'pickup_lng': pickupLocation.longitude,
      'drop_lat': dropLocation.latitude,
      'drop_lng': dropLocation.longitude,
      'pickup_address': pickupAddress,
      'drop_address': dropAddress,
      'distance_km': distanceKm,
      'estimated_earnings': estimatedEarnings,
      'estimated_minutes': estimatedMinutes,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'passenger_name': passengerName,
    };
  }
}
