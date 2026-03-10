import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/ride_repository.dart';
import '../datasources/ride_remote_datasource.dart';

class RideRepositoryImpl implements RideRepository {
  final RideRemoteDataSource _remoteDataSource;

  RideRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<RideEntity>>> getAvailableRides({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final rides = await _remoteDataSource.getAvailableRides(
        latitude: latitude,
        longitude: longitude,
      );
      return ApiSuccess(rides);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<RideEntity>> acceptRide(String rideId) async {
    try {
      final ride = await _remoteDataSource.acceptRide(rideId);
      return ApiSuccess(ride);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<RideEntity>> getRideDetails(String rideId) async {
    try {
      final ride = await _remoteDataSource.getRideDetails(rideId);
      return ApiSuccess(ride);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<List<RideEntity>>> getRideHistory() async {
    try {
      final rides = await _remoteDataSource.getRideHistory();
      return ApiSuccess(rides);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }
}
