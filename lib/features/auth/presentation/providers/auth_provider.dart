import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/sentry_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(ref.read(apiClientProvider)),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

// Auth state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthNotifier({
    required AuthRepository repository,
    required AuthService authService,
    required TokenStorage tokenStorage,
  })  : _repository = repository,
        _authService = authService,
        _tokenStorage = tokenStorage,
        super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    final isAuth = await _repository.isAuthenticated();

    if (isAuth) {
      final result = await _repository.getCurrentUser();
      if (result is ApiSuccess<UserEntity>) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.data,
        );
        await SentryService.setUser(
          id: result.data.id,
          email: result.data.email,
          name: result.data.name,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    final idToken = await _authService.getGoogleIdToken();
    if (idToken == null) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Google Sign-In was cancelled.',
      );
      return;
    }

    final result = await _repository.signInWithGoogle(idToken);

    switch (result) {
      case ApiSuccess():
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.data.user,
        );
        await SentryService.setUser(
          id: result.data.user.id,
          email: result.data.user.email,
          name: result.data.user.name,
        );
      case ApiError():
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.message,
        );
      case ApiLoading():
        break;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );

    switch (result) {
      case ApiSuccess():
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.data.user,
        );
      case ApiError():
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.message,
        );
      case ApiLoading():
        break;
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _repository.register(
      email: email,
      password: password,
      name: name,
    );

    switch (result) {
      case ApiSuccess():
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.data.user,
        );
      case ApiError():
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.message,
        );
      case ApiLoading():
        break;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    await _authService.signOutGoogle();
    await _tokenStorage.clearTokens();
    await SentryService.clearUser();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    repository: ref.read(authRepositoryProvider),
    authService: ref.read(authServiceProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});
