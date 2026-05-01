class ProfessionalBlock {
  final String id;
  final String tenantId;
  final String professionalId;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String? motivo;
  final bool recorrente;

  const ProfessionalBlock({
    required this.id,
    required this.tenantId,
    required this.professionalId,
    required this.dataInicio,
    required this.dataFim,
    this.motivo,
    this.recorrente = false,
  });
}
