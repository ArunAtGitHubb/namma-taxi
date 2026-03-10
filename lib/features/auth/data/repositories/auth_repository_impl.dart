import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  @override
  Future<ApiResult<({UserEntity user, AuthTokens tokens})>> signInWithGoogle(
      String idToken) async {
    try {
      final result = await _remoteDataSource.signInWithGoogle(idToken);
      final tokens = AuthTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return ApiSuccess((user: result.user as UserEntity, tokens: tokens));
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<({UserEntity user, AuthTokens tokens})>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      final tokens = AuthTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return ApiSuccess((user: result.user as UserEntity, tokens: tokens));
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<({UserEntity user, AuthTokens tokens})>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      final tokens = AuthTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return ApiSuccess((user: result.user as UserEntity, tokens: tokens));
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _tokenStorage.clearTokens();
      return const ApiSuccess(null);
    } on DioException catch (e) {
      await _tokenStorage.clearTokens();
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      await _tokenStorage.clearTokens();
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<ApiResult<UserEntity>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return ApiSuccess(user);
    } on DioException catch (e) {
      return ApiError(message: ApiException.fromDioError(e).message);
    } catch (e) {
      return ApiError(message: e.toString());
    }
  }

  @override
  Future<bool> isAuthenticated() => _tokenStorage.hasTokens();
}
