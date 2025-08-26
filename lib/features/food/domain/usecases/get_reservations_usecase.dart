import '../entities/reservation_entity.dart';
import '../repositories/reservation_repository.dart';

class GetReservationsUseCase {
  final ReservationRepository repository;

  GetReservationsUseCase(this.repository);

  Future<List<ReservationEntity>> call(String charityId) async {
    return await repository.getReservationsByCharity(charityId);
  }
}
