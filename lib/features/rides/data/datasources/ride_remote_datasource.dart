import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/ride_model.dart';

class RideRemoteDataSource {
  final ApiClient _apiClient;

  RideRemoteDataSource(this._apiClient);

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
