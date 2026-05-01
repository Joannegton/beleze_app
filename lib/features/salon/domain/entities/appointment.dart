enum AppointmentStatus { pending, confirmed, cancelled, completed, noShow }

extension AppointmentStatusExtension on AppointmentStatus {
  static AppointmentStatus fromString(String value) =>
      switch (value.toUpperCase()) {
        'PENDING' => AppointmentStatus.pending,
        'CONFIRMED' => AppointmentStatus.confirmed,
        'CANCELLED' => AppointmentStatus.cancelled,
        'COMPLETED' => AppointmentStatus.completed,
        'NO_SHOW' => AppointmentStatus.noShow,
        _ => AppointmentStatus.pending,
      };

  String get label => switch (this) {
        AppointmentStatus.pending => 'Pendente',
        AppointmentStatus.confirmed => 'Confirmado',
        AppointmentStatus.cancelled => 'Cancelado',
        AppointmentStatus.completed => 'Concluído',
        AppointmentStatus.noShow => 'Não compareceu',
      };

  String get stringValue => switch (this) {
        AppointmentStatus.pending => 'PENDING',
        AppointmentStatus.confirmed => 'CONFIRMED',
        AppointmentStatus.cancelled => 'CANCELLED',
        AppointmentStatus.completed => 'COMPLETED',
        AppointmentStatus.noShow => 'NO_SHOW',
      };
}

class Appointment {
  final String id;
  final String tenantId;
  final String professionalId;
  final String professionalName;
  final String serviceId;
  final String serviceName;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final double pricePaid;
  final String? notes;

  const Appointment({
    required this.id,
    required this.tenantId,
    required this.professionalId,
    required this.professionalName,
    required this.serviceId,
    required this.serviceName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.pricePaid,
    this.notes,
  });
}
