import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/salon.dart';
import '../../../domain/repositories/salon_repository.dart';

part 'salon_list_event.dart';
part 'salon_list_state.dart';

class SalonListBloc extends Bloc<SalonListEvent, SalonListState> {
  final SalonRepository _repository;

  SalonListBloc(this._repository) : super(const SalonListInitial()) {
    on<SalonListLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    SalonListLoadRequested event,
    Emitter<SalonListState> emit,
  ) async {
    emit(const SalonListLoading());
    final result = await _repository.getNearbySalons(
      lat: event.lat,
      lng: event.lng,
    );
    result.fold(
      (f) => emit(SalonListError(f.message)),
      (salons) => emit(SalonListLoaded(salons)),
    );
  }
}
