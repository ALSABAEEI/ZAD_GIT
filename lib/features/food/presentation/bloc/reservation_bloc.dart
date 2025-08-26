import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/usecases/get_reservations_usecase.dart';
import '../../domain/usecases/create_reservation_usecase.dart';
import '../../domain/usecases/check_reservation_usecase.dart';
import '../../domain/usecases/cancel_reservation_usecase.dart';

// Events
abstract class ReservationEvent {}

class LoadReservations extends ReservationEvent {
  final String charityId;
  LoadReservations(this.charityId);
}

class CreateReservation extends ReservationEvent {
  final ReservationEntity reservation;
  CreateReservation(this.reservation);
}

class CheckReservation extends ReservationEvent {
  final String foodItemId;
  final String charityId;
  CheckReservation(this.foodItemId, this.charityId);
}

class CancelReservation extends ReservationEvent {
  final String reservationId;
  final String charityId;
  CancelReservation(this.reservationId, this.charityId);
}

// States
abstract class ReservationState {}

class ReservationInitial extends ReservationState {}

class ReservationLoading extends ReservationState {}

class ReservationsLoaded extends ReservationState {
  final List<ReservationEntity> reservations;
  ReservationsLoaded(this.reservations);
}

class ReservationCreated extends ReservationState {
  final ReservationEntity reservation;
  ReservationCreated(this.reservation);
}

class ReservationChecked extends ReservationState {
  final bool isReserved;
  ReservationChecked(this.isReserved);
}

class ReservationError extends ReservationState {
  final String message;
  ReservationError(this.message);
}

// BLoC
class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final GetReservationsUseCase getReservationsUseCase;
  final CreateReservationUseCase createReservationUseCase;
  final CheckReservationUseCase checkReservationUseCase;
  final CancelReservationUseCase cancelReservationUseCase;

  ReservationBloc({
    required this.getReservationsUseCase,
    required this.createReservationUseCase,
    required this.checkReservationUseCase,
    required this.cancelReservationUseCase,
  }) : super(ReservationInitial()) {
    on<LoadReservations>(_onLoadReservations);
    on<CreateReservation>(_onCreateReservation);
    on<CheckReservation>(_onCheckReservation);
    on<CancelReservation>(_onCancelReservation);
  }

  Future<void> _onLoadReservations(
    LoadReservations event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationLoading());
    try {
      final reservations = await getReservationsUseCase(event.charityId);
      emit(ReservationsLoaded(reservations));
    } catch (e) {
      emit(ReservationError(e.toString()));
    }
  }

  Future<void> _onCreateReservation(
    CreateReservation event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationLoading());
    try {
      await createReservationUseCase(event.reservation);
      emit(ReservationCreated(event.reservation));
    } catch (e) {
      emit(ReservationError(e.toString()));
    }
  }

  Future<void> _onCheckReservation(
    CheckReservation event,
    Emitter<ReservationState> emit,
  ) async {
    try {
      final isReserved = await checkReservationUseCase(
        event.foodItemId,
        event.charityId,
      );
      emit(ReservationChecked(isReserved));
    } catch (e) {
      emit(ReservationError(e.toString()));
    }
  }

  Future<void> _onCancelReservation(
    CancelReservation event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationLoading());
    try {
      await cancelReservationUseCase(event.reservationId);
      // Reload reservations after cancellation
      final reservations = await getReservationsUseCase(event.charityId);
      emit(ReservationsLoaded(reservations));
    } catch (e) {
      emit(ReservationError(e.toString()));
    }
  }
}
