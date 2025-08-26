import '../entities/reservation_entity.dart';
import '../repositories/reservation_repository.dart';

class CreateReservationUseCase {
  final ReservationRepository repository;

  CreateReservationUseCase(this.repository);

  Future<void> call(ReservationEntity reservation) async {
    return await repository.createReservation(reservation);
  }
}
