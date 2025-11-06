import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<void> createNotification(NotificationEntity notification);
  Future<List<NotificationEntity>> getNotifications(String restaurantId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String restaurantId);
  Future<int> getUnreadCount(String restaurantId);
}


