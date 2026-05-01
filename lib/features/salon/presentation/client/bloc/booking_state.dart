part of 'booking_bloc.dart';

sealed class BookingState {
  const BookingState();
}

final class BookingInitial extends BookingState {
  const BookingInitial();
}

final class BookingInProgress extends BookingState {
  final String tenantId;
  final SalonService? service;
  final List<Professional>? availableProfessionals;
  final Professional? professional;
  final DateTime? selectedDate;
  final List<TimeSlot>? availableSlots;
  final TimeSlot? selectedSlot;
  final bool isLoadingSlots;
  final bool isConfirming;
  final String? rescheduleAppointmentId;

  const BookingInProgress({
    required this.tenantId,
    this.service,
    this.availableProfessionals,
    this.professional,
    this.selectedDate,
    this.availableSlots,
    this.selectedSlot,
    this.isLoadingSlots = false,
    this.isConfirming = false,
    this.rescheduleAppointmentId,
  });

  BookingInProgress copyWith({
    SalonService? service,
    List<Professional>? availableProfessionals,
    Professional? professional,
    DateTime? selectedDate,
    List<TimeSlot>? availableSlots,
    TimeSlot? selectedSlot,
    bool? isLoadingSlots,
    bool? isConfirming,
    String? rescheduleAppointmentId,
  }) =>
      BookingInProgress(
        tenantId: tenantId,
        service: service ?? this.service,
        availableProfessionals: availableProfessionals ?? this.availableProfessionals,
        professional: professional ?? this.professional,
        selectedDate: selectedDate ?? this.selectedDate,
        availableSlots: availableSlots ?? this.availableSlots,
        selectedSlot: selectedSlot ?? this.selectedSlot,
        isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
        isConfirming: isConfirming ?? this.isConfirming,
        rescheduleAppointmentId: rescheduleAppointmentId ?? this.rescheduleAppointmentId,
      );

  bool get canSelectDate => professional != null;
  bool get canConfirm => selectedSlot != null && !isConfirming;
}

final class BookingSuccess extends BookingState {
  final Appointment appointment;
  const BookingSuccess(this.appointment);
}

final class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
}
