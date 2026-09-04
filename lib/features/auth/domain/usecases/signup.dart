import '../../../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// ================================================================
/// SIGNUP USE CASE
/// ================================================================

class SignupUseCase {
  final AuthRepository _repository;

  const SignupUseCase(this._repository);

  Future<SignupResult> call({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String deviceFingerprint,
  }) async {
    try {
      final result = await _repository.signup(
        name: name,
        email: email,
        password: password,
        phone: phone,
        deviceFingerprint: deviceFingerprint,
      );
      return SignupResult.success(result.user);
    } catch (e) {
      return SignupResult.failure(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    if (e is Failure) return e;
    return UnknownFailure(e.toString());
  }
}

class SignupResult {
  final User? user;
  final Failure? failure;

  const SignupResult._({this.user, this.failure});

  factory SignupResult.success(User user) => SignupResult._(user: user);
  factory SignupResult.failure(Failure f) => SignupResult._(failure: f);

  bool get isSuccess => user != null;
}