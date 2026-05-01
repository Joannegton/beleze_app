part of 'booking_bloc.dart';

sealed class BookingEvent {
  const BookingEvent();
}

final class BookingServiceSelected extends BookingEvent {
  final String tenantId;
  final SalonService service;
  const BookingServiceSelected({required this.tenantId, required this.service});
}

final class BookingProfessionalSelected extends BookingEvent {
  final Professional professional;
  const BookingProfessionalSelected(this.professional);
}

final class BookingDateSelected extends BookingEvent {
  final DateTime date;
  const BookingDateSelected(this.date);
}

final class BookingSlotSelected extends BookingEvent {
  final TimeSlot slot;
  const BookingSlotSelected(this.slot);
}

final class BookingConfirmed extends BookingEvent {
  final String? notes;
  const BookingConfirmed({this.notes});
}

final class BookingReset extends BookingEvent {
  const BookingReset();
}

final class BookingLoadForReschedule extends BookingEvent {
  final String appointmentId;
  const BookingLoadForReschedule(this.appointmentId);
}

final class BookingRescheduleConfirmed extends BookingEvent {
  final String appointmentId;
  final String? notes;
  const BookingRescheduleConfirmed({required this.appointmentId, this.notes});
}
