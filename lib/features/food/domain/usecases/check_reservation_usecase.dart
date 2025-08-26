import '../repositories/reservation_repository.dart';

class CheckReservationUseCase {
  final ReservationRepository repository;

  CheckReservationUseCase(this.repository);

  Future<bool> call(String foodItemId, String charityId) async {
    return await repository.isFoodItemReserved(foodItemId, charityId);
  }
}
