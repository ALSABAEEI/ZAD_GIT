import '../entities/food_item_entity.dart';
import '../entities/reservation_entity.dart';
import '../repositories/food_repository.dart';

class GetFoodItemFromReservationUseCase {
  final FoodRepository foodRepository;

  GetFoodItemFromReservationUseCase(this.foodRepository);

  Future<FoodItemEntity> call(ReservationEntity reservation) async {
    try {
      // Get the specific food item by ID from the database
      final foodItem = await foodRepository.getFoodItemById(
        reservation.foodItemId,
      );

      if (foodItem != null) {
        // Return the food item with isAvailable set to false since it's reserved
        return FoodItemEntity(
          id: foodItem.id,
          name: foodItem.name,
          description: foodItem.description,
          price: foodItem.price,
          quantity: foodItem.quantity,
          imageUrl: foodItem.imageUrl,
          restaurantId: foodItem.restaurantId,
          restaurantName: foodItem.restaurantName,
          createdAt: foodItem.createdAt,
          isAvailable: false, // Since it's reserved
          expirationHours: foodItem.expirationHours,
        );
      } else {
        // Food item not found in database, use reservation data
        return FoodItemEntity(
          id: reservation.foodItemId,
          name: reservation.foodItemName,
          description: 'Food item details not available',
          price: 0,
          quantity: reservation.quantity,
          imageUrl: reservation.foodItemImageUrl,
          restaurantId: reservation.restaurantId,
          restaurantName: reservation.restaurantName,
          createdAt: reservation.reservedAt,
          isAvailable: false,
          expirationHours: 24, // Default fallback
        );
      }
    } catch (e) {
      // Fallback to reservation data if fetching fails
      return FoodItemEntity(
        id: reservation.foodItemId,
        name: reservation.foodItemName,
        description: 'Food item details not available',
        price: 0,
        quantity: reservation.quantity,
        imageUrl: reservation.foodItemImageUrl,
        restaurantId: reservation.restaurantId,
        restaurantName: reservation.restaurantName,
        createdAt: reservation.reservedAt,
        isAvailable: false,
        expirationHours: 24, // Default fallback
      );
    }
  }
}
