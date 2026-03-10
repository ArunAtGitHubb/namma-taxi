import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../rides/domain/entities/ride_entity.dart';

/// Manages clustered ride markers and driver marker on the Mapbox map.
/// Uses Mapbox GL native clustering via GeoJSON sources for high performance
/// with large numbers of ride markers.
class MapClusterManager {
  static const String _rideSourceId = 'ride-requests-source';
  static const String _clusterLayerId = 'clusters';
  static const String _clusterCountLayerId = 'cluster-count';
  static const String _unclusteredLayerId = 'unclustered-rides';
  static const String _driverSourceId = 'driver-source';
  static const String _driverLayerId = 'driver-layer';
  static const String _pickupRouteSourceId = 'pickup-route-source';
  static const String _pickupRouteLayerId = 'pickup-route-layer';
  static const String _tripRouteSourceId = 'trip-route-source';
  static const String _tripRouteLayerId = 'trip-route-layer';

  MapboxMap? _mapboxMap;
  bool _sourcesAdded = false;

  void attach(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
  }

  Future<void> initializeSources() async {
    if (_mapboxMap == null || _sourcesAdded) return;

    try {
      // Ride requests source with clustering
      await _mapboxMap!.style.addSource(
        GeoJsonSource(
          id: _rideSourceId,
          data: _emptyFeatureCollection(),
          cluster: true,
          clusterMaxZoom: 14,
          clusterRadius: 50,
        ),
      );

      // Cluster circle layer
      await _mapboxMap!.style.addLayer(
        CircleLayer(
          id: _clusterLayerId,
          sourceId: _rideSourceId,
          filter: ['has', 'point_count'],
          circleColor: AppColors.primary.toARGB32(),
          circleRadius: 20.0,
          circleStrokeWidth: 3.0,
          circleStrokeColor: AppColors.primaryDark.toARGB32(),
        ),
      );

      // Cluster count text layer
      await _mapboxMap!.style.addLayer(
        SymbolLayer(
          id: _clusterCountLayerId,
          sourceId: _rideSourceId,
          filter: ['has', 'point_count'],
          textField: '{point_count_abbreviated}',
          textSize: 14.0,
          textColor: AppColors.secondary.toARGB32(),
        ),
      );

      // Individual ride markers
      await _mapboxMap!.style.addLayer(
        CircleLayer(
          id: _unclusteredLayerId,
          sourceId: _rideSourceId,
          filter: [
            '!',
            ['has', 'point_count'],
          ],
          circleColor: AppColors.primary.toARGB32(),
          circleRadius: 10.0,
          circleStrokeWidth: 3.0,
          circleStrokeColor: AppColors.white.toARGB32(),
        ),
      );

      // Driver location source
      await _mapboxMap!.style.addSource(
        GeoJsonSource(
          id: _driverSourceId,
          data: _emptyFeatureCollection(),
        ),
      );

      await _mapboxMap!.style.addLayer(
        CircleLayer(
          id: _driverLayerId,
          sourceId: _driverSourceId,
          circleColor: AppColors.secondary.toARGB32(),
          circleRadius: 8.0,
          circleStrokeWidth: 4.0,
          circleStrokeColor: AppColors.primary.toARGB32(),
        ),
      );

      // Pickup route source/layer (blue)
      await _mapboxMap!.style.addSource(
        GeoJsonSource(id: _pickupRouteSourceId, data: _emptyFeatureCollection()),
      );
      await _mapboxMap!.style.addLayer(
        LineLayer(
          id: _pickupRouteLayerId,
          sourceId: _pickupRouteSourceId,
          lineColor: AppColors.info.toARGB32(),
          lineWidth: 5.0,
          lineOpacity: 0.8,
        ),
      );

      // Trip route source/layer (green)
      await _mapboxMap!.style.addSource(
        GeoJsonSource(id: _tripRouteSourceId, data: _emptyFeatureCollection()),
      );
      await _mapboxMap!.style.addLayer(
        LineLayer(
          id: _tripRouteLayerId,
          sourceId: _tripRouteSourceId,
          lineColor: AppColors.success.toARGB32(),
          lineWidth: 5.0,
          lineOpacity: 0.8,
        ),
      );

      _sourcesAdded = true;
      logger.i('Map cluster sources initialized');
    } catch (e) {
      logger.e('Failed to initialize map sources', error: e);
    }
  }

  /// Update ride request markers with efficient batching.
  Future<void> updateRideMarkers(List<RideEntity> rides) async {
    if (_mapboxMap == null || !_sourcesAdded) return;

    final features = rides.map((ride) {
      return {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [
            ride.pickupLocation.longitude,
            ride.pickupLocation.latitude,
          ],
        },
        'properties': {
          'ride_id': ride.id,
          'fare': ride.estimatedEarnings,
          'distance': ride.distanceKm,
          'pickup': ride.pickupAddress,
          'drop': ride.dropAddress,
        },
      };
    }).toList();

    final geojson = jsonEncode({
      'type': 'FeatureCollection',
      'features': features,
    });

    try {
      final source = await _mapboxMap!.style.getSource(_rideSourceId);
      (source as GeoJsonSource).updateGeoJSON(geojson);
    } catch (e) {
      logger.e('Failed to update ride markers', error: e);
    }
  }

  /// Update driver location marker
  Future<void> updateDriverMarker(double lat, double lng, double? heading) async {
    if (_mapboxMap == null || !_sourcesAdded) return;

    final geojson = jsonEncode({
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [lng, lat],
          },
          'properties': {
            'heading': heading ?? 0,
          },
        },
      ],
    });

    try {
      final source = await _mapboxMap!.style.getSource(_driverSourceId);
      (source as GeoJsonSource).updateGeoJSON(geojson);
    } catch (e) {
      logger.e('Failed to update driver marker', error: e);
    }
  }

  /// Show pickup route (driver → pickup) as blue line
  Future<void> showPickupRoute(List<List<double>> coordinates) async {
    await _showRoute(_pickupRouteSourceId, coordinates);
  }

  /// Show trip route (pickup → drop) as green line
  Future<void> showTripRoute(List<List<double>> coordinates) async {
    await _showRoute(_tripRouteSourceId, coordinates);
  }

  Future<void> _showRoute(String sourceId, List<List<double>> coordinates) async {
    if (_mapboxMap == null || !_sourcesAdded) return;

    final geojson = jsonEncode({
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {
            'type': 'LineString',
            'coordinates': coordinates,
          },
          'properties': {},
        },
      ],
    });

    try {
      final source = await _mapboxMap!.style.getSource(sourceId);
      (source as GeoJsonSource).updateGeoJSON(geojson);
    } catch (e) {
      logger.e('Failed to show route', error: e);
    }
  }

  /// Clear all route lines
  Future<void> clearRoutes() async {
    final emptyGeoJson = _emptyFeatureCollection();
    try {
      final pickupSource =
          await _mapboxMap!.style.getSource(_pickupRouteSourceId);
      (pickupSource as GeoJsonSource).updateGeoJSON(emptyGeoJson);

      final tripSource = await _mapboxMap!.style.getSource(_tripRouteSourceId);
      (tripSource as GeoJsonSource).updateGeoJSON(emptyGeoJson);
    } catch (e) {
      logger.e('Failed to clear routes', error: e);
    }
  }

  /// Fit map to show both pickup and drop locations
  Future<void> fitBounds({
    required double southWestLat,
    required double southWestLng,
    required double northEastLat,
    required double northEastLng,
    double padding = 80,
  }) async {
    if (_mapboxMap == null) return;

    final centerLat = (southWestLat + northEastLat) / 2;
    final centerLng = (southWestLng + northEastLng) / 2;

    final latDiff = (northEastLat - southWestLat).abs();
    final lngDiff = (northEastLng - southWestLng).abs();
    final maxDiff = math.max(latDiff, lngDiff);
    final zoom = (14 - (maxDiff * 10)).clamp(8.0, 16.0);

    await _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(centerLng, centerLat)),
        zoom: zoom,
        padding: MbxEdgeInsets(
          top: padding,
          left: padding,
          bottom: padding + 200,
          right: padding,
        ),
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  String _emptyFeatureCollection() {
    return jsonEncode({'type': 'FeatureCollection', 'features': []});
  }
}

extension ColorToARGB32 on Color {
  int toARGB32() => (a * 255).toInt() << 24 | (r * 255).toInt() << 16 | (g * 255).toInt() << 8 | (b * 255).toInt();
}
