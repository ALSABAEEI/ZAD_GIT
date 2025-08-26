import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../models/reservation_model.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ReservationEntity>> getReservationsByCharity(
    String charityId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('reservations')
          .where('charityId', isEqualTo: charityId)
          .get();

      final reservations = querySnapshot.docs
          .map(
            (doc) => ReservationModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();

      // Sort in memory instead of using Firestore ordering
      reservations.sort((a, b) => b.reservedAt.compareTo(a.reservedAt));

      return reservations;
    } catch (e) {
      throw Exception('Failed to fetch reservations: $e');
    }
  }

  @override
  Future<void> createReservation(ReservationEntity reservation) async {
    try {
      final reservationModel = ReservationModel(
        id: reservation.id,
        foodItemId: reservation.foodItemId,
        foodItemName: reservation.foodItemName,
        foodItemImageUrl: reservation.foodItemImageUrl,
        restaurantId: reservation.restaurantId,
        restaurantName: reservation.restaurantName,
        charityId: reservation.charityId,
        charityName: reservation.charityName,
        reservedAt: reservation.reservedAt,
        status: reservation.status,
        pickupTime: reservation.pickupTime,
        quantity: reservation.quantity,
      );

      // Create the reservation
      await _firestore
          .collection('reservations')
          .doc(reservation.id)
          .set(reservationModel.toJson());

      // Update the food item to mark it as unavailable
      await _firestore
          .collection('food_items')
          .doc(reservation.foodItemId)
          .update({'isAvailable': false});

      // If reservation is accepted, create a chat room for Super Hero Charity mode
      if (reservation.status == 'accepted') {
        await _createChatRoom(reservation);
      }

      print(
        'RESERVATION: Created reservation ${reservation.id} for ${reservation.foodItemName} and marked food item as unavailable',
      );
    } catch (e) {
      throw Exception('Failed to create reservation: $e');
    }
  }

  @override
  Future<void> updateReservationStatus(
    String reservationId,
    String status,
  ) async {
    try {
      await _firestore.collection('reservations').doc(reservationId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update reservation status: $e');
    }
  }

  @override
  Future<void> deleteReservation(String reservationId) async {
    try {
      // Get the reservation first to get the food item ID
      final reservationDoc = await _firestore
          .collection('reservations')
          .doc(reservationId)
          .get();

      if (reservationDoc.exists) {
        final reservationData = reservationDoc.data()!;
        final foodItemId = reservationData['foodItemId'] as String;

        // Delete the reservation
        await _firestore.collection('reservations').doc(reservationId).delete();

        // Check if there are any other reservations for this food item
        final otherReservations = await _firestore
            .collection('reservations')
            .where('foodItemId', isEqualTo: foodItemId)
            .get();

        // If no other reservations exist, mark the food item as available again
        if (otherReservations.docs.isEmpty) {
          await _firestore.collection('food_items').doc(foodItemId).update({
            'isAvailable': true,
          });
        }

        print(
          'RESERVATION: Deleted reservation $reservationId and updated food item availability',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete reservation: $e');
    }
  }

  @override
  Future<bool> isFoodItemReserved(String foodItemId, String charityId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reservations')
          .where('foodItemId', isEqualTo: foodItemId)
          .where('charityId', isEqualTo: charityId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check reservation status: $e');
    }
  }

  Future<void> _createChatRoom(ReservationEntity reservation) async {
    try {
      final chatRoomId =
          '${reservation.restaurantId}_${reservation.charityId}_${reservation.foodItemId}';

      final chatRoom = {
        'id': chatRoomId,
        'requestId': reservation.id,
        'restaurantId': reservation.restaurantId,
        'charityId': reservation.charityId,
        'restaurantName': reservation.restaurantName,
        'charityName': reservation.charityName,
        'proposalTitle': reservation.foodItemName,
        'createdAt': reservation.reservedAt,
        'isActive': true,
        'lastMessageAt': reservation.reservedAt,
        'lastMessageText': 'Reservation accepted - Chat now available!',
      };

      await _firestore.collection('chat_rooms').doc(chatRoomId).set(chatRoom);

      print('CHAT: Created chat room $chatRoomId for Super Hero Charity mode');
    } catch (e) {
      print('CHAT: Error creating chat room: $e');
      // Don't throw error to avoid breaking reservation creation
    }
  }
}
