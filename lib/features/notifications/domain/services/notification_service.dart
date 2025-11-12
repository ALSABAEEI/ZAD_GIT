import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/notification_entity.dart';
import '../usecases/create_notification_usecase.dart';

/// Centralized notification service (two events only):
/// 1) Restaurant applies to a proposal -> notify the organization
/// 2) Organization reserves a food item -> notify the restaurant
class NotificationService {
  final CreateNotificationUseCase createNotificationUseCase;

  NotificationService(this.createNotificationUseCase);

  /// Organization gets notified when a restaurant applies to their proposal.
  Future<void> notifyOrgOnRestaurantApplied({
    required String organizationUserId, // target org account id
    required String restaurantName,
    required String proposalTitle,
    required String requestId,
  }) async {
    final notification = NotificationEntity(
      id: FirebaseFirestore.instance.collection('notifications').doc().id,
      restaurantId: organizationUserId, // target user id
      title: 'New Application',
      message: '$restaurantName applied to "$proposalTitle".',
      type: 'org_application',
      createdAt: DateTime.now(),
      metadata: {
        'requestId': requestId,
        'restaurantName': restaurantName,
        'proposalTitle': proposalTitle,
      },
    );

    await createNotificationUseCase(notification);
  }

  /// Restaurant gets notified when an organization reserves one of its items.
  Future<void> notifyRestaurantOnFoodReserved({
    required String restaurantUserId, // target restaurant account id
    required String foodItemName,
    required String organizationName,
    String? foodItemId,
    String? reservationId,
  }) async {
    final notification = NotificationEntity(
      id: FirebaseFirestore.instance.collection('notifications').doc().id,
      restaurantId: restaurantUserId, // target user id
      title: 'Food Reserved',
      message: '$organizationName reserved "$foodItemName".',
      type: 'food_reserved',
      createdAt: DateTime.now(),
      metadata: {
        'foodItemId': foodItemId,
        'foodItemName': foodItemName,
        'organizationName': organizationName,
        'reservationId': reservationId,
      },
    );

    await createNotificationUseCase(notification);
  }

  /// Restaurant gets notified when an organization accepts/rejects its application.
  Future<void> notifyRestaurantOnRequestDecision({
    required String restaurantUserId,
    required String proposalTitle,
    required String organizationName,
    required String status, // 'accepted' or 'rejected'
    required String requestId,
  }) async {
    final isAccepted = status == 'accepted';
    final notification = NotificationEntity(
      id: FirebaseFirestore.instance.collection('notifications').doc().id,
      restaurantId: restaurantUserId,
      title: isAccepted ? 'Application Accepted' : 'Application Rejected',
      message:
          '$organizationName ${isAccepted ? 'accepted' : 'rejected'} your application for \"$proposalTitle\".',
      type: 'request_decision',
      createdAt: DateTime.now(),
      metadata: {
        'requestId': requestId,
        'proposalTitle': proposalTitle,
        'organizationName': organizationName,
        'status': status,
      },
    );

    await createNotificationUseCase(notification);
  }
}
