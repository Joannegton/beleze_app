import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/professional.dart';
import '../../domain/entities/salon.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/salon_repository.dart';
import '../datasources/salon_remote_datasource.dart';

class SalonRepositoryImpl implements SalonRepository {
  final SalonRemoteDatasource _datasource;

  SalonRepositoryImpl(this._datasource);

  @override
  Future<Result<Failure, List<Salon>>> getNearbySalons({
    double? lat,
    double? lng,
  }) =>
      _execute(() => _datasource.getNearbySalons(lat: lat, lng: lng));

  @override
  Future<Result<Failure, Salon>> getSalonBySlug(String slug) =>
      _execute(() => _datasource.getSalonBySlug(slug));

  @override
  Future<Result<Failure, List<SalonService>>> getSalonServices(String tenantId) =>
      _execute(() => _datasource.getSalonServices(tenantId));

  @override
  Future<Result<Failure, List<Professional>>> getSalonProfessionals(
          String tenantId) =>
      _execute(() => _datasource.getSalonProfessionals(tenantId));

  @override
  Future<Result<Failure, List<Professional>>> getProfessionalsForService(
          String tenantId, String serviceId) =>
      _execute(() =>
          _datasource.getProfessionalsForService(tenantId, serviceId));

  @override
  Future<Result<Failure, List<TimeSlot>>> getAvailableSlots({
    required String tenantId,
    required String professionalId,
    required String serviceId,
    required DateTime date,
  }) async {
    try {
      final raw = await _datasource.getAvailableSlots(
        tenantId: tenantId,
        professionalId: professionalId,
        serviceId: serviceId,
        date: date,
      );
      final slots = raw
          .map((e) => TimeSlot(
                startTime: DateTime.parse(e['start'] as String),
                endTime: DateTime.parse(e['end'] as String),
                available: true,
              ))
          .toList();
      return ok(slots);
    } on DioException catch (e) {
      return err(_mapError(e));
    }
  }

  @override
  Future<Result<Failure, List<Salon>>> getFavoriteSalons() =>
      _execute(() => _datasource.getFavoriteSalons());

  @override
  Future<Result<Failure, void>> addFavoriteSalon(String salonId) =>
      _execute(() => _datasource.addFavoriteSalon(salonId));

  @override
  Future<Result<Failure, void>> removeFavoriteSalon(String salonId) =>
      _execute(() => _datasource.removeFavoriteSalon(salonId));

  @override
  Future<Result<Failure, Professional>> createProfessional(
    String tenantId, {
    required String name,
    required String specialties,
    required double commission,
    required bool active,
    required Map<String, String> workHours,
  }) =>
      _execute(() => _datasource.createProfessional(
        tenantId,
        name: name,
        specialties: specialties,
        commission: commission,
        active: active,
        workHours: workHours,
      ));

  @override
  Future<Result<Failure, Professional>> updateProfessional(
    String tenantId,
    String professionalId, {
    required String name,
    required String specialties,
    required double commission,
    required bool active,
    required Map<String, String> workHours,
  }) =>
      _execute(() => _datasource.updateProfessional(
        tenantId,
        professionalId,
        name: name,
        specialties: specialties,
        commission: commission,
        active: active,
        workHours: workHours,
      ));

  @override
  Future<Result<Failure, void>> deleteProfessional(
    String tenantId,
    String professionalId,
  ) =>
      _execute(() => _datasource.deleteProfessional(tenantId, professionalId));

  Future<Result<Failure, T>> _execute<T>(Future<T> Function() action) async {
    try {
      return ok(await action());
    } on DioException catch (e) {
      return err(_mapError(e));
    }
  }

  Failure _mapError(DioException e) {
    return switch (e.response?.statusCode) {
      401 => const UnauthorizedFailure(),
      404 => NotFoundFailure(e.message ?? 'Não encontrado'),
      _ when e.type == DioExceptionType.connectionError =>
        const NetworkFailure(),
      _ => ServerFailure(e.message ?? 'Erro inesperado',
          statusCode: e.response?.statusCode),
    };
  }
}
