import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<WalletEntity>> getBalance() async {
    try {
      final wallet = await _remoteDataSource.getBalance();
      return ApiSuccess(wallet);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<List<WalletTransaction>>> getTransactions() async {
    try {
      final transactions = await _remoteDataSource.getTransactions();
      return ApiSuccess(transactions);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<WalletEntity>> purchaseCredits(String planId) async {
    try {
      final wallet = await _remoteDataSource.purchaseCredits(planId);
      return ApiSuccess(wallet);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<WalletEntity>> deductCredit() async {
    try {
      // Handled server-side during ride acceptance
      final wallet = await _remoteDataSource.getBalance();
      return ApiSuccess(wallet);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }
}
