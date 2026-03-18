import '../../../../core/network/api_result.dart';
import '../entities/ride_entity.dart';

abstract class RideRepository {
  Future<ApiResult<List<RideEntity>>> getAvailableRides({
    required double latitude,
    required double longitude,
  });

  Future<ApiResult<RideEntity>> acceptRide(String rideId);

  Future<ApiResult<RideEntity>> getRideDetails(String rideId);

  Future<ApiResult<List<RideEntity>>> getRideHistory();

  Future<ApiResult<bool>> startPickup(String rideId);

  Future<ApiResult<bool>> beginTrip(String rideId);

  Future<ApiResult<bool>> completeRide(
    String rideId, {
    required double dropLat,
    required double dropLng,
    required double finalDistanceKm,
    required double finalFare,
  });

  Future<ApiResult<bool>> cancelRide(String rideId, {String? reason});
}
