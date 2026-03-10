import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthInterceptor({required this.dio, required this.tokenStorage});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await tokenStorage.getRefreshToken();
        if (refreshToken == null) {
          return handler.next(err);
        }

        final response = await dio.post(
          ApiEndpoints.refreshToken,
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken = response.data['access_token'] as String;
        final newRefreshToken = response.data['refresh_token'] as String;

        await tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // Retry the original request with the new token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await dio.fetch(options);
        return handler.resolve(retryResponse);
      } catch (_) {
        await tokenStorage.clearTokens();
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}
