import '../../../../core/network/api_result.dart';
import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<ApiResult<({UserEntity user, AuthTokens tokens})>> execute(
      String idToken) {
    return _repository.signInWithGoogle(idToken);
  }
}
