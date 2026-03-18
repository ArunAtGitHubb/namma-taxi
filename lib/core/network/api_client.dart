import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import 'api_interceptor.dart';
import 'token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final tokenStorage = ref.read(tokenStorageProvider);
  dio.interceptors.addAll([
    AuthInterceptor(dio: dio, tokenStorage: tokenStorage),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ),
  ]);

  return dio;
});

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.put<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) =>
      _dio.delete<T>(path, options: options);

  /// Multipart form-data for file uploads (e.g. document upload)
  Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData data,
    Options? options,
  }) =>
      _dio.post<T>(
        path,
        data: data,
        options: options ?? Options(contentType: 'multipart/form-data'),
      );
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider));
});
