import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

/// ================================================================
/// FORGOT PASSWORD USE CASE
/// ================================================================

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  const ForgotPasswordUseCase(this._repository);

  Future<ForgotPasswordResult> call({
    required String email,
  }) async {
    try {
      await _repository.forgotPassword(email);
      return ForgotPasswordResult.success();
    } catch (e) {
      return ForgotPasswordResult.failure(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    if (e is Failure) return e;
    return UnknownFailure(e.toString());
  }
}

class ForgotPasswordResult {
  final Failure? failure;

  const ForgotPasswordResult._({this.failure});

  factory ForgotPasswordResult.success() => const ForgotPasswordResult._();
  factory ForgotPasswordResult.failure(Failure f) =>
      ForgotPasswordResult._(failure: f);

  bool get isSuccess => failure == null;
}
