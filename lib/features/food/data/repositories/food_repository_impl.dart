import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/entities/food_item_entity.dart';
import '../models/food_item_model.dart';

class FoodRepositoryImpl implements FoodRepository {
  final FirebaseFirestore _firestore;

  FoodRepositoryImpl(this._firestore);

  @override
  Future<List<FoodItemEntity>> getFoodItems() async {
    try {
      final querySnapshot = await _firestore.collection('food_items').get();
      return querySnapshot.docs
          .map((doc) => FoodItemModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get food items: $e');
    }
  }

  @override
  Future<List<FoodItemEntity>> getFoodItemsWithRestaurantNames() async {
    try {
      final querySnapshot = await _firestore.collection('food_items').get();
      final foodItems = <FoodItemEntity>[];

      for (final doc in querySnapshot.docs) {
        final foodItem = FoodItemModel.fromJson(doc.data(), doc.id);

        // If restaurant name is empty or default, fetch it from users collection
        if (foodItem.restaurantName.isEmpty ||
            foodItem.restaurantName == 'Restaurant Name' ||
            foodItem.restaurantName == 'Unknown Restaurant') {
          try {
            final userDoc = await _firestore
                .collection('users')
                .doc(foodItem.restaurantId)
                .get();

            if (userDoc.exists) {
              final userData = userDoc.data();
              final actualRestaurantName =
                  userData?['name'] ?? 'Unknown Restaurant';

              // Create updated food item with correct restaurant name
              final updatedFoodItem = FoodItemModel(
                id: foodItem.id,
                name: foodItem.name,
                description: foodItem.description,
                price: foodItem.price,
                quantity: foodItem.quantity,
                imageUrl: foodItem.imageUrl,
                restaurantId: foodItem.restaurantId,
                restaurantName: actualRestaurantName,
                createdAt: foodItem.createdAt,
                isAvailable: foodItem.isAvailable,
                expirationHours: foodItem.expirationHours,
              );

              foodItems.add(updatedFoodItem);
            } else {
              foodItems.add(foodItem);
            }
          } catch (e) {
            print('Error fetching restaurant name for ${foodItem.id}: $e');
            foodItems.add(foodItem);
          }
        } else {
          foodItems.add(foodItem);
        }
      }

      return foodItems;
    } catch (e) {
      throw Exception('Failed to get food items with restaurant names: $e');
    }
  }

  @override
  Future<FoodItemEntity?> getFoodItemById(String foodItemId) async {
    try {
      final doc = await _firestore
          .collection('food_items')
          .doc(foodItemId)
          .get();

      if (doc.exists) {
        return FoodItemModel.fromJson(doc.data()!, doc.id);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to fetch food item: $e');
    }
  }

  @override
  Future<List<FoodItemEntity>> getFoodItemsByRestaurant(
    String restaurantId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('food_items')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      return querySnapshot.docs
          .map((doc) => FoodItemModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get restaurant food items: $e');
    }
  }

  @override
  Future<void> addFoodItem(FoodItemEntity foodItem) async {
    try {
      print('Repository: Starting to add food item...');
      final foodItemModel = foodItem as FoodItemModel;
      print('Repository: Food item model created: ${foodItemModel.name}');
      final jsonData = foodItemModel.toJson();
      print('Repository: JSON data prepared: $jsonData');
      await _firestore.collection('food_items').add(jsonData);
      print('Repository: Food item added successfully to Firestore');
    } catch (e) {
      print('Repository: Error adding food item: $e');
      throw Exception('Failed to add food item: $e');
    }
  }

  @override
  Future<void> updateFoodItem(FoodItemEntity foodItem) async {
    try {
      final foodItemModel = foodItem as FoodItemModel;
      await _firestore
          .collection('food_items')
          .doc(foodItem.id)
          .update(foodItemModel.toJson());
    } catch (e) {
      throw Exception('Failed to update food item: $e');
    }
  }

  @override
  Future<void> deleteFoodItem(String foodItemId) async {
    try {
      await _firestore.collection('food_items').doc(foodItemId).delete();
    } catch (e) {
      throw Exception('Failed to delete food item: $e');
    }
  }
}
