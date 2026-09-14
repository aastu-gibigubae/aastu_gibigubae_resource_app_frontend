import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aastu_gibigubae_resource_app_frontend/core/errors/app_exception.dart';
import 'package:aastu_gibigubae_resource_app_frontend/core/errors/error_mapper.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/auth/domain/entities/user.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/auth/domain/usecases/signup.dart';

class _FakeFailingAuthRepository implements AuthRepository {
  final Object errorToThrow;

  _FakeFailingAuthRepository(this.errorToThrow);

  @override
  Future<({User user, String accessToken, String refreshToken})> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String deviceFingerprint,
  }) async {
    throw errorToThrow;
  }

  @override
  Future<({User user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
    required String deviceFingerprint,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<String> refreshSession() => throw UnimplementedError();

  @override
  Future<User?> getCurrentUser() => throw UnimplementedError();
}

void main() {
  group('Auth error mapping tests', () {
    test('SignupUseCase maps DioException with ServerException to clean message',
        () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/signup'),
        type: DioExceptionType.badResponse,
        error: const ServerException(
          message: 'An account with this email already exists',
          statusCode: 400,
        ),
      );

      final repo = _FakeFailingAuthRepository(dioException);
      final useCase = SignupUseCase(repo);

      final result = await useCase(
        name: 'Test',
        email: 'test@example.com',
        password: 'Password123!',
        phone: '+251911223344',
        deviceFingerprint: 'fp',
      );

      expect(result.isSuccess, isFalse);
      expect(result.failure, isNotNull);
      // Ensure raw technical strings do NOT appear in the user-facing message
      expect(result.failure!.message,
          isNot(contains('DioException')));
      expect(result.failure!.message,
          isNot(contains('ServerException')));
      expect(result.failure!.message,
          isNot(contains('bad response')));
      expect(result.failure!.message,
          contains('An account with this email already exists'));
    });

    test('ErrorMapper cleanly handles backend reason codes', () {
      final failure = ErrorMapper.fromReasonCode(
        'EMAIL_ALREADY_EXISTS',
        'An account with this email already exists',
      );

      expect(failure.message,
          equals('An account with this email already exists'));
      expect(failure.message, isNot(contains('DioException')));
    });
  });
}
