import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/appointment.dart' show Appointment, AppointmentStatus;

abstract interface class AppointmentRepository {
  Future<Result<Failure, Appointment>> createAppointment({
    required String tenantId,
    required String professionalId,
    required String serviceId,
    required DateTime startTime,
    String? notes,
  });

  Future<Result<Failure, List<Appointment>>> getMyAppointments();

  Future<Result<Failure, List<Appointment>>> getProfessionalSchedule({
    String? tenantId,
    String? professionalId,
    required DateTime date,
  });

  Future<Result<Failure, List<Appointment>>> getDaySchedule({
    required String tenantId,
    required DateTime date,
  });

  Future<Result<Failure, void>> cancelAppointment(String appointmentId);
  Future<Result<Failure, Appointment>> getAppointmentById(String appointmentId);
  Future<Result<Failure, Appointment>> updateAppointment({
    required String appointmentId,
    required String professionalId,
    required String serviceId,
    required DateTime startTime,
    String? notes,
  });

  Future<Result<Failure, Appointment>> updateAppointmentStatus({
    required String appointmentId,
    required AppointmentStatus status,
  });
}
