import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/utils/logger.dart';

class AuthService {
  final GoogleSignIn _googleSignIn;

  AuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        logger.i('Google Sign-In successful: ${account.email}');
      }
      return account;
    } catch (e) {
      logger.e('Google Sign-In error', error: e);
      rethrow;
    }
  }

  Future<String?> getGoogleIdToken() async {
    try {
      final account = await signInWithGoogle();
      if (account == null) return null;
      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      logger.e('Error getting Google ID token', error: e);
      return null;
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      logger.i('Google Sign-Out successful');
    } catch (e) {
      logger.e('Google Sign-Out error', error: e);
    }
  }

  bool get isSignedIn => _googleSignIn.currentUser != null;
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
