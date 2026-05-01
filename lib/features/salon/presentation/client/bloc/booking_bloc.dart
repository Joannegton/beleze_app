import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/entities/professional.dart';
import '../../../domain/entities/service.dart';
import '../../../domain/entities/time_slot.dart';
import '../../../domain/repositories/appointment_repository.dart';
import '../../../domain/repositories/salon_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final SalonRepository _salonRepository;
  final AppointmentRepository _appointmentRepository;

  BookingBloc({
    required SalonRepository salonRepository,
    required AppointmentRepository appointmentRepository,
  })  : _salonRepository = salonRepository,
        _appointmentRepository = appointmentRepository,
        super(const BookingInitial()) {
    on<BookingServiceSelected>(_onServiceSelected);
    on<BookingProfessionalSelected>(_onProfessionalSelected);
    on<BookingDateSelected>(_onDateSelected);
    on<BookingSlotSelected>(_onSlotSelected);
    on<BookingConfirmed>(_onConfirmed);
    on<BookingReset>(_onReset);
    on<BookingLoadForReschedule>(_onLoadForReschedule);
    on<BookingRescheduleConfirmed>(_onRescheduleConfirmed);
  }

  Future<void> _onServiceSelected(
    BookingServiceSelected event,
    Emitter<BookingState> emit,
  ) async {
    final current = state is BookingInProgress
        ? state as BookingInProgress
        : BookingInProgress(tenantId: event.tenantId);
    emit(current.copyWith(
      service: event.service,
      professional: null,
      selectedDate: null,
      availableSlots: null,
      selectedSlot: null,
    ));

    final result = await _salonRepository.getProfessionalsForService(
      event.tenantId,
      event.service.id,
    );
    result.fold(
      (f) => emit(BookingError(f.message)),
      (pros) => emit((state as BookingInProgress).copyWith(availableProfessionals: pros)),
    );
  }

  Future<void> _onProfessionalSelected(
    BookingProfessionalSelected event,
    Emitter<BookingState> emit,
  ) async {
    if (state is! BookingInProgress) return;
    final current = state as BookingInProgress;
    emit(current.copyWith(
      professional: event.professional,
      selectedDate: null,
      availableSlots: null,
      selectedSlot: null,
    ));
  }

  Future<void> _onDateSelected(
    BookingDateSelected event,
    Emitter<BookingState> emit,
  ) async {
    if (state is! BookingInProgress) return;
    final current = state as BookingInProgress;
    emit(current.copyWith(selectedDate: event.date, isLoadingSlots: true));

    final result = await _salonRepository.getAvailableSlots(
      tenantId: current.tenantId,
      professionalId: current.professional!.id,
      serviceId: current.service!.id,
      date: event.date,
    );

    result.fold(
      (f) => emit(current.copyWith(isLoadingSlots: false)),
      (slots) => emit(current.copyWith(
        availableSlots: slots,
        isLoadingSlots: false,
      )),
    );
  }

  Future<void> _onSlotSelected(
    BookingSlotSelected event,
    Emitter<BookingState> emit,
  ) {
    if (state is! BookingInProgress) return Future.value();
    final current = state as BookingInProgress;
    emit(current.copyWith(selectedSlot: event.slot));
    return Future.value();
  }

  Future<void> _onConfirmed(
    BookingConfirmed event,
    Emitter<BookingState> emit,
  ) async {
    if (state is! BookingInProgress) return;
    final current = state as BookingInProgress;
    emit(current.copyWith(isConfirming: true));

    final result = await _appointmentRepository.createAppointment(
      tenantId: current.tenantId,
      professionalId: current.professional!.id,
      serviceId: current.service!.id,
      startTime: current.selectedSlot!.startTime,
      notes: event.notes,
    );

    result.fold(
      (f) => emit(BookingError(f.message)),
      (appointment) {
        final enriched = Appointment(
          id: appointment.id,
          tenantId: appointment.tenantId,
          professionalId: appointment.professionalId,
          professionalName: current.professional?.name ?? appointment.professionalName,
          serviceId: appointment.serviceId,
          serviceName: current.service?.name ?? appointment.serviceName,
          startTime: appointment.startTime,
          endTime: appointment.endTime,
          status: appointment.status,
          pricePaid: current.service?.price ?? appointment.pricePaid,
          notes: appointment.notes,
        );
        emit(BookingSuccess(enriched));
      },
    );
  }

  void _onReset(BookingReset event, Emitter<BookingState> emit) {
    emit(const BookingInitial());
  }

  Future<void> _onLoadForReschedule(
    BookingLoadForReschedule event,
    Emitter<BookingState> emit,
  ) async {
    final result = await _appointmentRepository.getAppointmentById(event.appointmentId);
    result.fold(
      (f) => emit(BookingError(f.message)),
      (appointment) {
        emit(BookingInProgress(
          tenantId: appointment.tenantId,
          rescheduleAppointmentId: event.appointmentId,
        ));
      },
    );
  }

  Future<void> _onRescheduleConfirmed(
    BookingRescheduleConfirmed event,
    Emitter<BookingState> emit,
  ) async {
    if (state is! BookingInProgress) return;
    final current = state as BookingInProgress;
    emit(current.copyWith(isConfirming: true));

    final result = await _appointmentRepository.updateAppointment(
      appointmentId: event.appointmentId,
      professionalId: current.professional!.id,
      serviceId: current.service!.id,
      startTime: current.selectedSlot!.startTime,
      notes: event.notes,
    );

    result.fold(
      (f) => emit(BookingError(f.message)),
      (appointment) {
        final enriched = Appointment(
          id: appointment.id,
          tenantId: appointment.tenantId,
          professionalId: appointment.professionalId,
          professionalName: current.professional?.name ?? appointment.professionalName,
          serviceId: appointment.serviceId,
          serviceName: current.service?.name ?? appointment.serviceName,
          startTime: appointment.startTime,
          endTime: appointment.endTime,
          status: appointment.status,
          pricePaid: current.service?.price ?? appointment.pricePaid,
          notes: appointment.notes,
        );
        emit(BookingSuccess(enriched));
      },
    );
  }
}
