import 'package:equatable/equatable.dart';

class DriverLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final DateTime timestamp;

  const DriverLocation({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, heading, speed, timestamp];
}
