import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<({UserModel user, String accessToken, String refreshToken})>
      signInWithGoogle(String idToken) async {
    final response = await _apiClient.post(
      ApiEndpoints.googleAuth,
      data: {'id_token': idToken},
    );

    final data = response.data as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }

  Future<({UserModel user, String accessToken, String refreshToken})>
      signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }

  Future<({UserModel user, String accessToken, String refreshToken})> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password, 'name': name},
    );

    final data = response.data as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }

  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.driverProfile);
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
