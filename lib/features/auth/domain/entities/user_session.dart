enum UserRole {
  owner(2),
  professional(4),
  client(7);

  final int roleIdNum;
  const UserRole(this.roleIdNum);

  static UserRole fromRoleIdNum(int? roleIdNum) => switch (roleIdNum) {
    2 => UserRole.owner,
    4 => UserRole.professional,
    7 => UserRole.client,
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
