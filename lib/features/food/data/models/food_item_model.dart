import '../../domain/entities/food_item_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItemModel extends FoodItemEntity {
  FoodItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.quantity,
    required super.imageUrl,
    required super.restaurantId,
    required super.restaurantName,
    required super.createdAt,
    required super.isAvailable,
    required super.expirationHours,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json, String id) {
    return FoodItemModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isAvailable: json['isAvailable'] ?? true,
      expirationHours: json['expirationHours'] ?? 24, // Default to 24 hours
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAvailable': isAvailable,
      'expirationHours': expirationHours,
    };
  }
}
