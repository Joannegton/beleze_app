part of 'salon_list_bloc.dart';

sealed class SalonListEvent {
  const SalonListEvent();
}

final class SalonListLoadRequested extends SalonListEvent {
  final double? lat;
  final double? lng;
  const SalonListLoadRequested({this.lat, this.lng});
}
