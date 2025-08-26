import '../entities/food_item_entity.dart';

abstract class FoodRepository {
  Future<List<FoodItemEntity>> getFoodItems();
  Future<FoodItemEntity?> getFoodItemById(String foodItemId);
  Future<List<FoodItemEntity>> getFoodItemsWithRestaurantNames();
  Future<List<FoodItemEntity>> getFoodItemsByRestaurant(String restaurantId);
  Future<void> addFoodItem(FoodItemEntity foodItem);
  Future<void> updateFoodItem(FoodItemEntity foodItem);
  Future<void> deleteFoodItem(String foodItemId);
}
