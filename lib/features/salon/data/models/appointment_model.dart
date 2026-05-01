import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.tenantId,
    required super.professionalId,
    required super.professionalName,
    required super.serviceId,
    required super.serviceName,
    required super.startTime,
    required super.endTime,
    required super.status,
    required super.pricePaid,
    super.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      AppointmentModel(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String,
        professionalId: json['professional_id'] as String,
        professionalName: json['professional']?['nome'] as String? ?? '',
        serviceId: json['service_id'] as String,
        serviceName: json['service']?['nome'] as String? ?? '',
        startTime: DateTime.parse(json['data_inicio'] as String),
        endTime: DateTime.parse(json['data_fim'] as String),
        status: AppointmentStatusExtension.fromString(json['status'] as String),
        pricePaid: (json['preco_cobrado'] as num).toDouble(),
        notes: json['notas'] as String?,
      );
}
