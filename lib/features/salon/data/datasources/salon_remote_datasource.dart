import 'package:dio/dio.dart';
import '../models/appointment_model.dart';
import '../models/professional_block_model.dart';
import '../models/professional_model.dart';
import '../models/salon_model.dart';
import '../models/service_model.dart';

abstract interface class SalonRemoteDatasource {
  Future<List<SalonModel>> getNearbySalons({double? lat, double? lng, String? city});
  Future<SalonModel> getSalonBySlug(String slug);
  Future<List<ServiceModel>> getSalonServices(String tenantId);
  Future<List<ProfessionalModel>> getSalonProfessionals(String tenantId);
  Future<List<ProfessionalModel>> getProfessionalsForService(
      String tenantId, String serviceId);
  Future<List<Map<String, dynamic>>> getAvailableSlots({
    required String tenantId,
    required String professionalId,
    required String serviceId,
    required DateTime date,
  });
  Future<AppointmentModel> createAppointment({
    required String tenantId,
    required String professionalId,
    required String serviceId,
    required DateTime startTime,
    String? notes,
  });
  Future<List<AppointmentModel>> getMyAppointments();
  Future<List<AppointmentModel>> getProfessionalSchedule({
    String? tenantId,
    String? professionalId,
    required DateTime date,
  });
  Future<List<AppointmentModel>> getDaySchedule({
    required String tenantId,
    required DateTime date,
  });
  Future<void> cancelAppointment(String appointmentId);
  Future<AppointmentModel> getAppointmentById(String appointmentId);
  Future<AppointmentModel> updateAppointment({
    required String appointmentId,
    required String professionalId,
    required String serviceId,
    required DateTime startTime,
    String? notes,
  });

  Future<AppointmentModel> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  });

  Future<List<SalonModel>> getFavoriteSalons();
  Future<void> addFavoriteSalon(String salonId);
  Future<void> removeFavoriteSalon(String salonId);

  Future<List<ProfessionalBlockModel>> listBlocks({
    required String tenantId,
    required String professionalId,
    DateTime? from,
    DateTime? to,
  });

  Future<ProfessionalBlockModel> createBlock({
    required String tenantId,
    required String professionalId,
    required DateTime dataInicio,
    required DateTime dataFim,
    String? motivo,
    bool recorrente = false,
  });

  Future<void> deleteBlock({
    required String tenantId,
    required String professionalId,
    required String blockId,
  });

  Future<ProfessionalModel> createProfessional(
    String tenantId, {
    required String name,
    required String specialties,
    required double commission,
    required bool active,
    required Map<String, String> workHours,
  });

  Future<ProfessionalModel> updateProfessional(
    String tenantId,
    String professionalId, {
    required String name,
    required String specialties,
    required double commission,
    required bool active,
    required Map<String, String> workHours,
  });

  Future<void> deleteProfessional(String tenantId, String professionalId);
}

class SalonRemoteDatasourceImpl implements SalonRemoteDatasource {
  final Dio _dio;

  SalonRemoteDatasourceImpl(this._dio);

  @override
  Future<List<SalonModel>> getNearbySalons({double? lat, double? lng, String? city}) async {
    final response = await _dio.get('tenants', queryParameters: {
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (city != null) 'city': city,
    });
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => SalonModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<SalonModel> getSalonBySlug(String slug) async {
    final response = await _dio.get('tenants/$slug');
    return SalonModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<ServiceModel>> getSalonServices(String tenantId) async {
    final response = await _dio.get('tenants/$tenantId/services');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ProfessionalModel>> getSalonProfessionals(String tenantId) async {
    final response = await _dio.get('tenants/$tenantId/professionals');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => ProfessionalModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ProfessionalModel>> getProfessionalsForService(
      String tenantId, String serviceId) async {
    final response = await _dio.get(
      'tenants/$tenantId/professionals/by-service/$serviceId',
    );
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => ProfessionalModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableSlots({
    required String tenantId,
    required String professionalId,
    required String serviceId,
    required DateTime date,
  }) async {
    final response = await _dio.get(
      'tenants/$tenantId/professionals/$professionalId/availability',
      queryParameters: {
        'serviceId': serviceId,
        'date': date.toIso8601String().split('T').first,
      },
    );
    return (response.data['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  @override
  Future<AppointmentModel> createAppointment({
    required String tenantId,
    required String professionalId,
    required String serviceId,
    required DateTime startTime,
    String? notes,
  }) async {
    final response = await _dio.post(
      'tenants/$tenantId/appointments',
      data: {
        'professionalId': professionalId,
        'serviceId': serviceId,
        'scheduledAt': startTime.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
    );
    return AppointmentModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<AppointmentModel>> getMyAppointments() async {
    final response = await _dio.get('appointments/my');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<AppointmentModel>> getProfessionalSchedule({
    String? tenantId,
    String? professionalId,
    required DateTime date,
  }) async {
    final String endpoint = (tenantId != null && professionalId != null)
        ? 'tenants/$tenantId/professionals/$professionalId/schedule'
        : 'appointments/my/professional-schedule';
    final response = await _dio.get(
      endpoint,
      queryParameters: {'date': date.toIso8601String().split('T').first},
    );
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<AppointmentModel>> getDaySchedule({
    required String tenantId,
    required DateTime date,
  }) async {
    final response = await _dio.get(
      'tenants/$tenantId/appointments/schedule',
      queryParameters: {'date': date.toIso8601String().split('T').first},
    );
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> cancelAppointment(String appointmentId) =>
      _dio.patch('appointments/$appointmentId/cancel');

  @override
  Future<List<ProfessionalBlockModel>> listBlocks({
    required String tenantId,
    required String professionalId,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _dio.get(
      'tenants/$tenantId/professionals/$professionalId/blocks',
      queryParameters: {
        if (from != null) 'from': from.toIso8601String().split('T').first,
        if (to != null) 'to': to.toIso8601String().split('T').first,
      },
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => ProfessionalBlockModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProfessionalBlockModel> createBlock({
    required String tenantId,
    required String professionalId,
    required DateTime dataInicio,
    required DateTime dataFim,
    String? motivo,
    bool recorrente = false,
  }) async {
    final response = await _dio.post(
      'tenants/$tenantId/professionals/$professionalId/blocks',
      data: {
        'dataInicio': dataInicio.toIso8601String(),
        'dataFim': dataFim.toIso8601String(),
        if (motivo != null) 'motivo': motivo,
        'recorrente': recorrente,
      },
    );
    return ProfessionalBlockModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteBlock({
    required String tenantId,
    required String professionalId,
    required String blockId,
  }) =>
      _dio.delete(
          'tenants/$tenantId/professionals/$professionalId/blocks/$blockId');

  @override
  Future<AppointmentModel> getAppointmentById(String appointmentId) async {
    final response = await _dio.get('appointments/$appointmentId');
    return AppointmentModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AppointmentModel> updateAppointment({
    required String appointmentId,
    required String professionalId,
    required String serviceId,
    required DateTime startTime,
    String? notes,
  }) async {
    final response = await _dio.patch(
      'appointments/$appointmentId',
      data: {
        'professionalId': professionalId,
        'serviceId': serviceId,
        'startTime': startTime.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
    );
    return AppointmentModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<SalonModel>> getFavoriteSalons() async {
    final response = await _dio.get('me/favorites');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => SalonModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addFavoriteSalon(String salonId) =>
      _dio.post('me/favorites', data: {'salonId': salonId});

  @override
  Future<void> removeFavoriteSalon(String salonId) =>
      _dio.delete('me/favorites/$salonId');

  @override
  Future<AppointmentModel> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    final response = await _dio.patch(
      'appointments/$appointmentId/status',
      data: {'status': status},
    );
    return AppointmentModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ProfessionalModel> createProfessional(
    String tenantId, {
    required String name,
    required String specialties,
    required double commission,
    required bool active,
    required Map<String, String> workHours,
  }) async {
    final response = await _dio.post(
      'tenants/$tenantId/professionals',
      data: {
        'name': name,
        'specialties': specialties,
        'commission': commission,
        'active': active,
        'workHours': workHours,
      },
    );
    return ProfessionalModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ProfessionalModel> updateProfessional(
    String tenantId,
    String professionalId, {
    required String name,
    required String specialties,
    required double commission,
    required bool active,
    required Map<String, String> workHours,
  }) async {
    final response = await _dio.patch(
      'tenants/$tenantId/professionals/$professionalId',
      data: {
        'name': name,
        'specialties': specialties,
        'commission': commission,
        'active': active,
        'workHours': workHours,
      },
    );
    return ProfessionalModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProfessional(String tenantId, String professionalId) =>
      _dio.delete('tenants/$tenantId/professionals/$professionalId');
}
