import '../repositories/notification_repository.dart';

class MarkAsReadUseCase {
  final NotificationRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<void> call(String notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}


