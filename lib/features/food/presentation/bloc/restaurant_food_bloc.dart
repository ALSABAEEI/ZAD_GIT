import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/food_item_entity.dart';
import '../../domain/usecases/get_restaurant_food_items_usecase.dart';
import '../../domain/usecases/delete_food_item_usecase.dart';

// Events
abstract class RestaurantFoodEvent extends Equatable {
  const RestaurantFoodEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurantFoodItems extends RestaurantFoodEvent {
  final String restaurantId;

  const LoadRestaurantFoodItems(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class DeleteRestaurantFoodItem extends RestaurantFoodEvent {
  final String foodItemId;

  const DeleteRestaurantFoodItem(this.foodItemId);

  @override
  List<Object?> get props => [foodItemId];
}

// States
abstract class RestaurantFoodState extends Equatable {
  const RestaurantFoodState();

  @override
  List<Object?> get props => [];
}

class RestaurantFoodInitial extends RestaurantFoodState {}

class RestaurantFoodLoading extends RestaurantFoodState {}

class RestaurantFoodLoaded extends RestaurantFoodState {
  final List<FoodItemEntity> foodItems;

  const RestaurantFoodLoaded(this.foodItems);

  @override
  List<Object?> get props => [foodItems];
}

class RestaurantFoodError extends RestaurantFoodState {
  final String message;

  const RestaurantFoodError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class RestaurantFoodBloc
    extends Bloc<RestaurantFoodEvent, RestaurantFoodState> {
  final GetRestaurantFoodItemsUseCase getRestaurantFoodItemsUseCase;
  final DeleteFoodItemUseCase deleteFoodItemUseCase;

  RestaurantFoodBloc({
    required this.getRestaurantFoodItemsUseCase,
    required this.deleteFoodItemUseCase,
  }) : super(RestaurantFoodInitial()) {
    on<LoadRestaurantFoodItems>(_onLoadRestaurantFoodItems);
    on<DeleteRestaurantFoodItem>(_onDeleteRestaurantFoodItem);
  }

  Future<void> _onLoadRestaurantFoodItems(
    LoadRestaurantFoodItems event,
    Emitter<RestaurantFoodState> emit,
  ) async {
    emit(RestaurantFoodLoading());
    try {
      final foodItems = await getRestaurantFoodItemsUseCase.execute(
        event.restaurantId,
      );
      emit(RestaurantFoodLoaded(foodItems));
    } catch (e) {
      emit(RestaurantFoodError(e.toString()));
    }
  }

  Future<void> _onDeleteRestaurantFoodItem(
    DeleteRestaurantFoodItem event,
    Emitter<RestaurantFoodState> emit,
  ) async {
    try {
      // Delete from database
      await deleteFoodItemUseCase.execute(event.foodItemId);

      // Update local state by removing the deleted item
      if (state is RestaurantFoodLoaded) {
        final currentState = state as RestaurantFoodLoaded;
        final updatedItems = currentState.foodItems
            .where((item) => item.id != event.foodItemId)
            .toList();
        emit(RestaurantFoodLoaded(updatedItems));
      }
    } catch (e) {
      emit(RestaurantFoodError(e.toString()));
    }
  }
}
