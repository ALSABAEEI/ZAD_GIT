import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/notification_entity.dart';
import '../usecases/create_notification_usecase.dart';

class NotificationService {
  final CreateNotificationUseCase createNotificationUseCase;

  NotificationService(this.createNotificationUseCase);

  /// Create notification when a proposal is accepted or rejected
  Future<void> createProposalStatusNotification({
    required String restaurantId,
    required String proposalTitle,
    required String organizationName,
    required String status, // 'accepted' or 'rejected'
    String? proposalId,
  }) async {
    final isAccepted = status == 'accepted';
    final notification = NotificationEntity(
      id: FirebaseFirestore.instance.collection('notifications').doc().id,
      restaurantId: restaurantId,
      title: isAccepted ? 'Proposal Accepted! 🎉' : 'Proposal Update',
      message: isAccepted
          ? '$organizationName accepted your proposal "$proposalTitle". You can now chat with them!'
          : '$organizationName declined your proposal "$proposalTitle". Keep trying with other proposals!',
      type: 'proposal_status',
      createdAt: DateTime.now(),
      metadata: {
        'proposalId': proposalId,
        'proposalTitle': proposalTitle,
        'organizationName': organizationName,
        'status': status,
      },
    );

    await createNotificationUseCase(notification);
  }

  /// Organization-side: notify when a new request is created by a restaurant
  Future<void> createOrgRequestNotification({
    required String charityId,
    required String restaurantName,
    required String proposalTitle,
    required String status, // pending | accepted | rejected
    required String requestId,
  }) async {
    final notification = NotificationEntity(
      id: FirebaseFirestore.instance.collection('notifications_org').doc().id,
      restaurantId: charityId, // reuse field to store target user id
      title: 'New Request from $restaurantName',
      message: '$restaurantName applied to "$proposalTitle". Status: $status',
      type: 'org_request',
      createdAt: DateTime.now(),
      metadata: {
        'requestId': requestId,
        'restaurantName': restaurantName,
        'proposalTitle': proposalTitle,
        'status': status,
      },
    );

    await createNotificationUseCase(notification);
  }

  /// Create notification when food is reserved
  Future<void> createReservationNotification({
    required String restaurantId,
    required String foodItemName,
    required String organizationName,
    String? foodItemId,
    String? reservationId,
  }) async {
    final notification = NotificationEntity(
      id: FirebaseFirestore.instance.collection('notifications').doc().id,
      restaurantId: restaurantId,
      title: 'Food Reserved! 🍽️',
      message:
          '$organizationName reserved your "$foodItemName". They will pick it up soon!',
      type: 'reservation',
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

  /// Create notification when reservation is cancelled
  Future<void> createReservationCancelledNotification({
    required String restaurantId,
    required String foodItemName,
    required String organizationName,
    String? foodItemId,
    String? reservationId,
  }) async {
    final notification = NotificationEntity(
      id: FirebaseFirestore.instance.collection('notifications').doc().id,
      restaurantId: restaurantId,
      title: 'Reservation Cancelled',
      message:
          '$organizationName cancelled their reservation for "$foodItemName". The item is now available again.',
      type: 'reservation_cancelled',
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
}
