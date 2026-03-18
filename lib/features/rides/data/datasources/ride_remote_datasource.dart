import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/ride_model.dart';

class RideRemoteDataSource {
  final ApiClient _apiClient;

  RideRemoteDataSource(this._apiClient);

  Future<void> startPickup(String rideId) async {
    final path = ApiEndpoints.rideStartPickup.replaceAll('{id}', rideId);
    await _apiClient.post(path, data: {});
  }

  Future<void> beginTrip(String rideId) async {
    final path = ApiEndpoints.rideBegin.replaceAll('{id}', rideId);
    await _apiClient.post(path, data: {});
  }

  Future<void> completeRide(
    String rideId, {
    required double dropLat,
    required double dropLng,
    required double finalDistanceKm,
    required double finalFare,
  }) async {
    final path = ApiEndpoints.rideComplete.replaceAll('{id}', rideId);
    await _apiClient.post(path, data: {
      'drop_lat': dropLat,
      'drop_lng': dropLng,
      'final_distance_km': finalDistanceKm,
      'final_fare': finalFare,
    });
  }

  Future<void> cancelRide(String rideId, {String? reason}) async {
    final path = ApiEndpoints.rideCancel.replaceAll('{id}', rideId);
    await _apiClient.post(path, data: {
      'reason': reason ?? 'Driver cancelled',
      'cancelled_by': 'driver',
    });
  }

  Future<List<RideModel>> getAvailableRides({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.availableRides,
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
      },
    );

    final list = response.data['rides'] as List;
    return list
        .map((e) => RideModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RideModel> acceptRide(String rideId) async {
    final response = await _apiClient.post(
      ApiEndpoints.acceptRide,
      data: {'ride_id': rideId},
    );
    return RideModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RideModel> getRideDetails(String rideId) async {
    final path = ApiEndpoints.rideDetails.replaceAll('{id}', rideId);
    final response = await _apiClient.get(path);
    return RideModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<RideModel>> getRideHistory() async {
    final response = await _apiClient.get(ApiEndpoints.rideHistory);
    final list = response.data['rides'] as List;
    return list
        .map((e) => RideModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
