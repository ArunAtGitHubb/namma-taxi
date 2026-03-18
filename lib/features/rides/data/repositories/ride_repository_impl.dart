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

  @override
  Future<ApiResult<bool>> startPickup(String rideId) async {
    try {
      await _remoteDataSource.startPickup(rideId);
      return const ApiSuccess(true);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<bool>> beginTrip(String rideId) async {
    try {
      await _remoteDataSource.beginTrip(rideId);
      return const ApiSuccess(true);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<bool>> completeRide(
    String rideId, {
    required double dropLat,
    required double dropLng,
    required double finalDistanceKm,
    required double finalFare,
  }) async {
    try {
      await _remoteDataSource.completeRide(
        rideId,
        dropLat: dropLat,
        dropLng: dropLng,
        finalDistanceKm: finalDistanceKm,
        finalFare: finalFare,
      );
      return const ApiSuccess(true);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<bool>> cancelRide(String rideId, {String? reason}) async {
    try {
      await _remoteDataSource.cancelRide(rideId, reason: reason);
      return const ApiSuccess(true);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }
}
