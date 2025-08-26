import '../repositories/food_repository.dart';
import '../entities/food_item_entity.dart';

class AddFoodItemUseCase {
  final FoodRepository repository;

  AddFoodItemUseCase(this.repository);

  Future<void> call(FoodItemEntity foodItem) async {
    return await repository.addFoodItem(foodItem);
  }
}
