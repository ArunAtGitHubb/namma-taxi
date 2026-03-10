import '../../../../core/network/api_result.dart';
import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<ApiResult<({UserEntity user, AuthTokens tokens})>> signInWithGoogle(
      String idToken);

  Future<ApiResult<({UserEntity user, AuthTokens tokens})>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<ApiResult<({UserEntity user, AuthTokens tokens})>> register({
    required String email,
    required String password,
    required String name,
  });

  Future<ApiResult<void>> logout();

  Future<ApiResult<UserEntity>> getCurrentUser();

  Future<bool> isAuthenticated();
}
