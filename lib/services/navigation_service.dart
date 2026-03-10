import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/logger.dart';
import 'mapbox_service.dart';

class RouteInfo {
  final List<List<double>> coordinates;
  final double distanceMeters;
  final double durationSeconds;
  final String geometry;
  final List<RouteStep> steps;

  RouteInfo({
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.geometry,
    required this.steps,
  });

  double get distanceKm => distanceMeters / 1000;
  int get durationMinutes => (durationSeconds / 60).ceil();

  String get formattedDistance {
    if (distanceKm >= 1) return '${distanceKm.toStringAsFixed(1)} km';
    return '${distanceMeters.toStringAsFixed(0)} m';
  }

  String get formattedDuration {
    if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      return '${hours}h ${mins}m';
    }
    return '$durationMinutes min';
  }
}

class RouteStep {
  final String instruction;
  final String maneuverType;
  final double distanceMeters;
  final double durationSeconds;
  final List<double>? location;

  RouteStep({
    required this.instruction,
    required this.maneuverType,
    required this.distanceMeters,
    required this.durationSeconds,
    this.location,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>;
    final locationList = maneuver['location'] as List?;

    return RouteStep(
      instruction: maneuver['instruction'] as String? ?? '',
      maneuverType: maneuver['type'] as String? ?? '',
      distanceMeters: (json['distance'] as num).toDouble(),
      durationSeconds: (json['duration'] as num).toDouble(),
      location: locationList?.map((e) => (e as num).toDouble()).toList(),
    );
  }
}

class NavigationService {
  static const String _directionsBase =
      'https://api.mapbox.com/directions/v5/mapbox/driving';

  final Dio _dio = Dio();

  Future<RouteInfo?> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final url = '$_directionsBase/$originLng,$originLat;$destLng,$destLat';

      final response = await _dio.get(
        url,
        queryParameters: {
          'access_token': MapboxService.accessToken,
          'geometries': 'geojson',
          'overview': 'full',
          'steps': 'true',
          'alternatives': 'false',
          'language': 'en',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final routes = data['routes'] as List;

      if (routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coords = (geometry['coordinates'] as List)
          .map((c) => [(c as List)[0] as double, c[1] as double])
          .toList();

      final legs = route['legs'] as List;
      final steps = <RouteStep>[];
      for (final leg in legs) {
        final legSteps = (leg as Map<String, dynamic>)['steps'] as List;
        steps.addAll(
          legSteps.map((s) => RouteStep.fromJson(s as Map<String, dynamic>)),
        );
      }

      return RouteInfo(
        coordinates: coords,
        distanceMeters: (route['distance'] as num).toDouble(),
        durationSeconds: (route['duration'] as num).toDouble(),
        geometry: jsonEncode(geometry),
        steps: steps,
      );
    } catch (e) {
      logger.e('Route fetch failed', error: e);
      return null;
    }
  }

  /// Get both pickup route (driver → pickup) and trip route (pickup → drop)
  Future<({RouteInfo? pickupRoute, RouteInfo? tripRoute})> getFullRoute({
    required double driverLat,
    required double driverLng,
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
  }) async {
    final results = await Future.wait([
      getRoute(
        originLat: driverLat,
        originLng: driverLng,
        destLat: pickupLat,
        destLng: pickupLng,
      ),
      getRoute(
        originLat: pickupLat,
        originLng: pickupLng,
        destLat: dropLat,
        destLng: dropLng,
      ),
    ]);

    return (pickupRoute: results[0], tripRoute: results[1]);
  }

  /// Encode coordinates to GeoJSON LineString for Mapbox layer
  Map<String, dynamic> toGeoJsonLineString(List<List<double>> coordinates) {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'LineString',
        'coordinates': coordinates,
      },
      'properties': {},
    };
  }

  void dispose() {
    _dio.close();
  }
}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  final service = NavigationService();
  ref.onDispose(() => service.dispose());
  return service;
});
