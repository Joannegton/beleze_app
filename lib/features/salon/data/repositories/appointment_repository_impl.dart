import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/salon_remote_datasource.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final SalonRemoteDatasource _datasource;

  AppointmentRepositoryImpl(this._datasource);

  @override
  Future<Result<Failure, Appointment>> createAppointment({
    required String tenantId,
    required String professionalId,
    required String serviceId,
    required DateTime startTime,
    String? notes,
  }) =>
      _execute(() => _datasource.createAppointment(
            tenantId: tenantId,
            professionalId: professionalId,
            serviceId: serviceId,
            startTime: startTime,
            notes: notes,
          ));

  @override
  Future<Result<Failure, List<Appointment>>> getMyAppointments() =>
      _execute(_datasource.getMyAppointments);

  @override
  Future<Result<Failure, List<Appointment>>> getProfessionalSchedule({
    String? tenantId,
    String? professionalId,
    required DateTime date,
  }) =>
      _execute(() => _datasource.getProfessionalSchedule(
            tenantId: tenantId,
            professionalId: professionalId,
            date: date,
          ));

  @override
  Future<Result<Failure, List<Appointment>>> getDaySchedule({
    required String tenantId,
    required DateTime date,
  }) =>
      _execute(() => _datasource.getDaySchedule(
            tenantId: tenantId,
            date: date,
          ));

  @override
  Future<Result<Failure, void>> cancelAppointment(String appointmentId) =>
      _execute(() => _datasource.cancelAppointment(appointmentId));

  @override
  Future<Result<Failure, Appointment>> getAppointmentById(String appointmentId) =>
      _execute(() => _datasource.getAppointmentById(appointmentId));

  @override
  Future<Result<Failure, Appointment>> updateAppointment({
    required String appointmentId,
    required String professionalId,
    required String serviceId,
    required DateTime startTime,
    String? notes,
  }) =>
      _execute(() => _datasource.updateAppointment(
            appointmentId: appointmentId,
            professionalId: professionalId,
            serviceId: serviceId,
            startTime: startTime,
            notes: notes,
          ));

  @override
  Future<Result<Failure, Appointment>> updateAppointmentStatus({
    required String appointmentId,
    required AppointmentStatus status,
  }) =>
      _execute(() => _datasource.updateAppointmentStatus(
            appointmentId: appointmentId,
            status: status.stringValue,
          ));

  Future<Result<Failure, T>> _execute<T>(Future<T> Function() action) async {
    try {
      return ok(await action());
    } on DioException catch (e) {
      return err(_mapError(e));
    }
  }

  Failure _mapError(DioException e) => switch (e.response?.statusCode) {
        401 => const UnauthorizedFailure(),
        404 => NotFoundFailure(e.message ?? 'Não encontrado'),
        _ when e.type == DioExceptionType.connectionError =>
          const NetworkFailure(),
        _ => ServerFailure(e.message ?? 'Erro inesperado',
            statusCode: e.response?.statusCode),
      };
}
