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
}
