import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_food_items_usecase.dart';
import '../../domain/usecases/get_food_items_with_restaurant_names_usecase.dart';
import '../../domain/usecases/add_food_item_usecase.dart';
import '../../domain/entities/food_item_entity.dart';

// Events
abstract class FoodEvent {}

class LoadFoodItems extends FoodEvent {}

class AddFoodItem extends FoodEvent {
  final FoodItemEntity foodItem;
  AddFoodItem(this.foodItem);
}

// States
abstract class FoodState {}

class FoodInitial extends FoodState {}

class FoodLoading extends FoodState {}

class FoodLoaded extends FoodState {
  final List<FoodItemEntity> foodItems;
  FoodLoaded(this.foodItems);
}

class FoodError extends FoodState {
  final String message;
  FoodError(this.message);
}

class FoodItemAdded extends FoodState {}

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final GetFoodItemsUseCase getFoodItemsUseCase;
  final GetFoodItemsWithRestaurantNamesUseCase
  getFoodItemsWithRestaurantNamesUseCase;
  final AddFoodItemUseCase addFoodItemUseCase;

  FoodBloc({
    required this.getFoodItemsUseCase,
    required this.getFoodItemsWithRestaurantNamesUseCase,
    required this.addFoodItemUseCase,
  }) : super(FoodInitial()) {
    on<LoadFoodItems>(_onLoadFoodItems);
    on<AddFoodItem>(_onAddFoodItem);
  }

  Future<void> _onLoadFoodItems(
    LoadFoodItems event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    try {
      final foodItems = await getFoodItemsWithRestaurantNamesUseCase.execute();
      emit(FoodLoaded(foodItems));
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }

  Future<void> _onAddFoodItem(
    AddFoodItem event,
    Emitter<FoodState> emit,
  ) async {
    try {
      await addFoodItemUseCase(event.foodItem);
      emit(FoodItemAdded());
      // Reload food items after adding
      add(LoadFoodItems());
    } catch (e) {
      emit(FoodError(e.toString()));
    }
  }
}
