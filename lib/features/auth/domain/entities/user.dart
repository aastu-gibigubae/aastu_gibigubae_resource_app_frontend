/// ================================================================
/// USER ENTITY
///
/// Pure domain object — no JSON or framework dependencies.
/// ================================================================

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String subscriptionStatus; // free | premium | expired
  final DateTime? subscriptionExpiresAt;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.subscriptionStatus = 'free',
    this.subscriptionExpiresAt,
    required this.createdAt,
  });

  bool get isPremium => subscriptionStatus == 'premium';

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? subscriptionStatus,
    DateTime? subscriptionExpiresAt,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
