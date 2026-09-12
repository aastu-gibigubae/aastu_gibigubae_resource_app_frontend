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
  final String subscriptionStatus;
  final String? subscriptionExpiresAt;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.subscriptionStatus,
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
      subscriptionStatus:
          (json['subscription_status'] as String?) ?? 'free',
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
        'subscription_status': subscriptionStatus,
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
      subscriptionStatus: subscriptionStatus,
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
      subscriptionStatus: user.subscriptionStatus,
      subscriptionExpiresAt: user.subscriptionExpiresAt?.toIso8601String(),
      createdAt: user.createdAt.toIso8601String(),
    );
  }
}
