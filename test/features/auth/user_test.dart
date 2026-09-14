import 'package:flutter_test/flutter_test.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/auth/domain/entities/user.dart';

void main() {
  group('User entity premium status tests', () {
    test('isPremium is false when subscriptionStatus is none', () {
      final user = User(
        id: '1',
        name: 'Test Student',
        email: 'student@aastu.edu.et',
        subscriptionStatus: 'none',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(user.isPremium, isFalse);
    });

    test('isPremium is false when subscriptionStatus is free', () {
      final user = User(
        id: '2',
        name: 'Test Student',
        email: 'student@aastu.edu.et',
        subscriptionStatus: 'free',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(user.isPremium, isFalse);
    });

    test('isPremium is true when subscriptionStatus is premium', () {
      final user = User(
        id: '3',
        name: 'Test Student',
        email: 'student@aastu.edu.et',
        subscriptionStatus: 'premium',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(user.isPremium, isTrue);
    });

    test('isPremium is true when subscriptionStatus is active', () {
      final user = User(
        id: '4',
        name: 'Test Student',
        email: 'student@aastu.edu.et',
        subscriptionStatus: 'active',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(user.isPremium, isTrue);
    });
  });
}
