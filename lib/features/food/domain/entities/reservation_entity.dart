class ReservationEntity {
  final String id;
  final String foodItemId;
  final String foodItemName;
  final String foodItemImageUrl;
  final String restaurantId;
  final String restaurantName;
  final String charityId;
  final String charityName;
  final DateTime reservedAt;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final String pickupTime;
  final int quantity;

  const ReservationEntity({
    required this.id,
    required this.foodItemId,
    required this.foodItemName,
    required this.foodItemImageUrl,
    required this.restaurantId,
    required this.restaurantName,
    required this.charityId,
    required this.charityName,
    required this.reservedAt,
    required this.status,
    required this.pickupTime,
    required this.quantity,
  });
}
