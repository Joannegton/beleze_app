abstract class RoleIds {
  static const int owner = 2;
  static const int admin = 2;
  static const int professional = 4;
  static const int worker = 4;
  static const int client = 7;
  static const int user = 7;
}

extension RoleIdExtension on int {
  String toRoleName() => switch (this) {
        RoleIds.owner => 'Proprietário',
        RoleIds.professional => 'Profissional',
        RoleIds.client => 'Cliente',
        _ => 'Desconhecido',
      };

  bool get isOwner => this == RoleIds.owner;
  bool get isProfessional => this == RoleIds.professional;
  bool get isClient => this == RoleIds.client;
}
