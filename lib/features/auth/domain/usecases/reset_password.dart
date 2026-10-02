import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

/// ================================================================
/// RESET PASSWORD RESULT
/// ================================================================

class ResetPasswordResult {
  final Failure? failure;

  const ResetPasswordResult._({this.failure});

  factory ResetPasswordResult.success() => const ResetPasswordResult._();
  factory ResetPasswordResult.failure(Failure f) =>
      ResetPasswordResult._(failure: f);

  bool get isSuccess => failure == null;
}

/// ================================================================
/// RESET PASSWORD USE CASE
///
/// Calls [AuthRepository.resetPassword] and maps any thrown
/// exception into a [ResetPasswordResult.failure] so callers can
/// check `.isSuccess` and `.failure?.message` without try/catch.
/// ================================================================

class ResetPasswordUseCase {
  final AuthRepository _repository;

  const ResetPasswordUseCase(this._repository);

  Future<ResetPasswordResult> call({
    String? token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _repository.resetPassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return ResetPasswordResult.success();
    } catch (e) {
      return ResetPasswordResult.failure(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    if (e is Failure) return e;
    return UnknownFailure(e.toString());
  }
}
