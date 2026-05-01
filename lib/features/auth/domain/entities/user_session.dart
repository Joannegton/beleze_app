enum UserRole { owner, professional, client }

extension UserRoleExtension on UserRole {
  static UserRole fromString(String value) => switch (value.toUpperCase()) {
        'OWNER' => UserRole.owner,
        'PROFESSIONAL' => UserRole.professional,
        _ => UserRole.client,
      };

  String get label => switch (this) {
        UserRole.owner => 'Proprietário',
        UserRole.professional => 'Profissional',
        UserRole.client => 'Cliente',
      };
}

class UserSession {
  final String userId;
  final String email;
  final UserRole role;
  final String? tenantId;

  const UserSession({
    required this.userId,
    required this.email,
    required this.role,
    this.tenantId,
  });
}
