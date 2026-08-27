import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// ================================================================
/// LOGIN USE CASE
/// ================================================================

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<LoginResult> call({
    required String email,
    required String password,
    required String deviceFingerprint,
  }) async {
    try {
      final result = await _repository.login(
        email: email,
        password: password,
        deviceFingerprint: deviceFingerprint,
      );
      return LoginResult.success(result.user);
    } catch (e) {
      return LoginResult.failure(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    if (e is Failure) return e;
    return UnknownFailure(e.toString());
  }
}

class LoginResult {
  final User? user;
  final Failure? failure;

  const LoginResult._({this.user, this.failure});

  factory LoginResult.success(User user) => LoginResult._(user: user);
  factory LoginResult.failure(Failure f) => LoginResult._(failure: f);

  bool get isSuccess => user != null;
}
