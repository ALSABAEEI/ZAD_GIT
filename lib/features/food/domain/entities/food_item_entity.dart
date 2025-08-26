class FoodItemEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String imageUrl;
  final String restaurantId;
  final String restaurantName;
  final DateTime createdAt;
  final bool isAvailable;
  final int expirationHours; // Hours until the food expires

  FoodItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.restaurantId,
    required this.restaurantName,
    required this.createdAt,
    required this.isAvailable,
    required this.expirationHours,
  });
}
