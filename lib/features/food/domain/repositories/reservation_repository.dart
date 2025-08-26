import '../entities/reservation_entity.dart';

abstract class ReservationRepository {
  Future<List<ReservationEntity>> getReservationsByCharity(String charityId);
  Future<void> createReservation(ReservationEntity reservation);
  Future<void> updateReservationStatus(String reservationId, String status);
  Future<void> deleteReservation(String reservationId);
  Future<bool> isFoodItemReserved(String foodItemId, String charityId);
}
