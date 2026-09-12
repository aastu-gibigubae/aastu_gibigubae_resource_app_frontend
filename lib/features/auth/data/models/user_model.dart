import '../../domain/entities/user.dart';

/// ================================================================
/// USER MODEL
///
/// JSON-serialisable DTO that maps to the backend response.
/// Converts to and from the domain [User] entity.
/// ================================================================

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String subscriptionStatus;
  final String activationStatus;
  final String? subscriptionExpiresAt;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'student',
    required this.subscriptionStatus,
    this.activationStatus = 'pending',
    this.subscriptionExpiresAt,
    required this.createdAt,
  });

  // ── JSON ────────────────────────────────────────────────────────

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: (json['role'] as String?) ?? 'student',
      subscriptionStatus:
          (json['subscription_status'] as String?) ?? 'none',
      activationStatus:
          (json['activation_status'] as String?) ?? 'pending',
      subscriptionExpiresAt:
          json['subscription_expires_at'] as String?,
      createdAt: (json['created_at'] as String?) ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        'role': role,
        'subscription_status': subscriptionStatus,
        'activation_status': activationStatus,
        if (subscriptionExpiresAt != null)
          'subscription_expires_at': subscriptionExpiresAt,
        'created_at': createdAt,
      };

  // ── Domain conversion ────────────────────────────────────────────

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      subscriptionStatus: subscriptionStatus,
      activationStatus: activationStatus,
      subscriptionExpiresAt: subscriptionExpiresAt != null
          ? DateTime.tryParse(subscriptionExpiresAt!)
          : null,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      subscriptionStatus: user.subscriptionStatus,
      activationStatus: user.activationStatus,
      subscriptionExpiresAt: user.subscriptionExpiresAt?.toIso8601String(),
      createdAt: user.createdAt.toIso8601String(),
    );
  }
}
