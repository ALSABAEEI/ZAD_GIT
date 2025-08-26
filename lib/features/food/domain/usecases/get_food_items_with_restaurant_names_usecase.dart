import '../../domain/repositories/food_repository.dart';
import '../../domain/entities/food_item_entity.dart';

class GetFoodItemsWithRestaurantNamesUseCase {
  final FoodRepository _foodRepository;

  GetFoodItemsWithRestaurantNamesUseCase(this._foodRepository);

  Future<List<FoodItemEntity>> execute() async {
    return await _foodRepository.getFoodItemsWithRestaurantNames();
  }
}
