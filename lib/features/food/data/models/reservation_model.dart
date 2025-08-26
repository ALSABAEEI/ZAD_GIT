import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reservation_entity.dart';

class ReservationModel extends ReservationEntity {
  const ReservationModel({
    required super.id,
    required super.foodItemId,
    required super.foodItemName,
    required super.foodItemImageUrl,
    required super.restaurantId,
    required super.restaurantName,
    required super.charityId,
    required super.charityName,
    required super.reservedAt,
    required super.status,
    required super.pickupTime,
    required super.quantity,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] ?? '',
      foodItemId: json['foodItemId'] ?? '',
      foodItemName: json['foodItemName'] ?? '',
      foodItemImageUrl: json['foodItemImageUrl'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      charityId: json['charityId'] ?? '',
      charityName: json['charityName'] ?? '',
      reservedAt: (json['reservedAt'] as Timestamp).toDate(),
      status: json['status'] ?? 'pending',
      pickupTime: json['pickupTime'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodItemId': foodItemId,
      'foodItemName': foodItemName,
      'foodItemImageUrl': foodItemImageUrl,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'charityId': charityId,
      'charityName': charityName,
      'reservedAt': Timestamp.fromDate(reservedAt),
      'status': status,
      'pickupTime': pickupTime,
      'quantity': quantity,
    };
  }
}
