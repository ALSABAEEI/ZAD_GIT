import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createNotification(NotificationEntity notification) async {
    final model = NotificationModel.fromEntity(notification);
    await _firestore
        .collection('notifications')
        .doc(notification.id)
        .set(model.toFirestore());
  }

  @override
  Future<List<NotificationEntity>> getNotifications(String restaurantId) async {
    // Avoid composite index requirement by fetching by restaurantId only and sorting client-side
    final querySnapshot = await _firestore
        .collection('notifications')
        .where('restaurantId', isEqualTo: restaurantId)
        .get();

    final results = querySnapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  @override
  Future<void> markAllAsRead(String restaurantId) async {
    final batch = _firestore.batch();
    // Fetch by restaurantId only to avoid composite index and filter client-side
    final querySnapshot = await _firestore
        .collection('notifications')
        .where('restaurantId', isEqualTo: restaurantId)
        .get();

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      if ((data['isRead'] ?? false) == false) {
        batch.update(doc.reference, {'isRead': true});
      }
    }

    await batch.commit();
  }

  @override
  Future<int> getUnreadCount(String restaurantId) async {
    // Fetch by restaurantId only to avoid composite index and count client-side
    final querySnapshot = await _firestore
        .collection('notifications')
        .where('restaurantId', isEqualTo: restaurantId)
        .get();

    int count = 0;
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      if ((data['isRead'] ?? false) == false) count++;
    }
    return count;
  }
}
