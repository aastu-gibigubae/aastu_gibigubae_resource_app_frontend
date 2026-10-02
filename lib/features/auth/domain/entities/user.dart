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
  final String role;
  final String subscriptionStatus;
  final String activationStatus;
  final DateTime? subscriptionExpiresAt;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'student',
    this.subscriptionStatus = 'none',
    this.activationStatus = 'pending',
    this.subscriptionExpiresAt,
    required this.createdAt,
  });

  bool get isPremium {
    if (subscriptionStatus != 'premium' && subscriptionStatus != 'active') {
      return false;
    }
    if (subscriptionExpiresAt != null &&
        DateTime.now().isAfter(subscriptionExpiresAt!)) {
      return false;
    }
    return true;
  }
  bool get isAdmin => role == 'admin';
  bool get isActivated => activationStatus == 'active';

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? subscriptionStatus,
    String? activationStatus,
    DateTime? subscriptionExpiresAt,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      activationStatus: activationStatus ?? this.activationStatus,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
