import '../repositories/food_repository.dart';
import '../entities/food_item_entity.dart';

class GetFoodItemsUseCase {
  final FoodRepository repository;

  GetFoodItemsUseCase(this.repository);

  Future<List<FoodItemEntity>> call() async {
    return await repository.getFoodItems();
  }
}
