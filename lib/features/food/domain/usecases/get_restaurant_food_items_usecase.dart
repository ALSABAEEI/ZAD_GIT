import 'package:flutter_bloc/flutter_bloc.dart';
import '../entities/food_item_entity.dart';
import '../repositories/food_repository.dart';

class GetRestaurantFoodItemsUseCase {
  final FoodRepository repository;

  GetRestaurantFoodItemsUseCase(this.repository);

  Future<List<FoodItemEntity>> execute(String restaurantId) async {
    return await repository.getFoodItemsByRestaurant(restaurantId);
  }
}
