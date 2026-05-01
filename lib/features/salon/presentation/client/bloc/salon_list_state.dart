part of 'salon_list_bloc.dart';

sealed class SalonListState {
  const SalonListState();
}

final class SalonListInitial extends SalonListState {
  const SalonListInitial();
}

final class SalonListLoading extends SalonListState {
  const SalonListLoading();
}

final class SalonListLoaded extends SalonListState {
  final List<Salon> salons;
  const SalonListLoaded(this.salons);
}

final class SalonListError extends SalonListState {
  final String message;
  const SalonListError(this.message);
}
