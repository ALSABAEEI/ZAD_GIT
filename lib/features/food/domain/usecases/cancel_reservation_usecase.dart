import '../repositories/reservation_repository.dart';

class CancelReservationUseCase {
  final ReservationRepository repository;

  CancelReservationUseCase(this.repository);

  Future<void> call(String reservationId) async {
    return await repository.deleteReservation(reservationId);
  }
}
