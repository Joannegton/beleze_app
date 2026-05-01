import '../../domain/entities/professional.dart';

class ProfessionalModel extends Professional {
  const ProfessionalModel({
    required super.id,
    required super.tenantId,
    required super.name,
    required super.serviceIds,
    required super.active,
    super.avatarUrl,
    super.specialties,
    super.commission,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    final services = json['services'] as List<dynamic>? ?? [];
    return ProfessionalModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['nome'] as String,
      active: json['ativo'] as bool? ?? true,
      avatarUrl: json['avatar_url'] as String?,
      specialties: json['especialidades'] as String? ?? '',
      commission: (json['comissao'] as num?)?.toDouble() ?? 0.0,
      serviceIds: services.map((s) => s['id'] as String).toList(),
    );
  }
}
