import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/professional.dart';
import '../entities/salon.dart';
import '../entities/service.dart';
import '../entities/time_slot.dart';

abstract interface class SalonRepository {
  Future<Result<Failure, List<Salon>>> getNearbySalons({double? lat, double? lng});
  Future<Result<Failure, Salon>> getSalonBySlug(String slug);
  Future<Result<Failure, List<SalonService>>> getSalonServices(String tenantId);
  Future<Result<Failure, List<Professional>>> getSalonProfessionals(String tenantId);
  Future<Result<Failure, List<Professional>>> getProfessionalsForService(
      String tenantId, String serviceId);
  Future<Result<Failure, List<TimeSlot>>> getAvailableSlots({
    required String tenantId,
    required String professionalId,
    required String serviceId,
    required DateTime date,
  });
  Future<Result<Failure, List<Salon>>> getFavoriteSalons();
  Future<Result<Failure, void>> addFavoriteSalon(String salonId);
  Future<Result<Failure, void>> removeFavoriteSalon(String salonId);
  Future<Result<Failure, Professional>> createProfessional(
    String tenantId, {
    required String name,
    required String specialties,
    required double commission,
    required bool active,
    required Map<String, String> workHours,
  });
  Future<Result<Failure, Professional>> updateProfessional(
    String tenantId,
    String professionalId, {
    required String name,
    required String specialties,
    required double commission,
    required bool active,
    required Map<String, String> workHours,
  });
  Future<Result<Failure, void>> deleteProfessional(String tenantId, String professionalId);
}
