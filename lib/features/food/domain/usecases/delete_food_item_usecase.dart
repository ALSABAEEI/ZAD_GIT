import '../repositories/food_repository.dart';

class DeleteFoodItemUseCase {
  final FoodRepository repository;

  DeleteFoodItemUseCase(this.repository);

  Future<void> execute(String foodItemId) async {
    await repository.deleteFoodItem(foodItemId);
  }
}
