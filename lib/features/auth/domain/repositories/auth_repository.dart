import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

/// ================================================================
/// AUTH REPOSITORY (interface)
///
/// The domain layer depends on this abstraction.
/// AuthRepositoryImpl in the data layer provides the implementation.
/// ================================================================

abstract class AuthRepository {
  /// Log in with email, password, and device fingerprint.
  /// Returns [User] on success, [Failure] on error.
  Future<({User user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
    required String deviceFingerprint,
  });

  /// Register a new account.
  Future<({User user, String accessToken, String refreshToken})> signup({
    required String name,
    required String email,
    required String password,
    required String? phone,
    required String deviceFingerprint,
  });

  /// Invalidate the session on the backend and clear local tokens.
  Future<void> logout();

  /// Silently refresh the access token using the stored refresh token.
  /// Returns the new access token.
  Future<String> refreshSession();

  /// Returns the currently stored [User], or null if not logged in.
  Future<User?> getCurrentUser();
}
