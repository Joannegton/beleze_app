import '../../domain/entities/professional_block.dart';

class ProfessionalBlockModel extends ProfessionalBlock {
  const ProfessionalBlockModel({
    required super.id,
    required super.tenantId,
    required super.professionalId,
    required super.dataInicio,
    required super.dataFim,
    super.motivo,
    super.recorrente,
  });

  factory ProfessionalBlockModel.fromJson(Map<String, dynamic> json) =>
      ProfessionalBlockModel(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String,
        professionalId: json['professional_id'] as String,
        dataInicio: DateTime.parse(json['data_inicio'] as String),
        dataFim: DateTime.parse(json['data_fim'] as String),
        motivo: json['motivo'] as String?,
        recorrente: json['recorrente'] as bool? ?? false,
      );
}
