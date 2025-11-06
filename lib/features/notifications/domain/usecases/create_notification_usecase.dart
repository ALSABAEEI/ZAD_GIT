import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class CreateNotificationUseCase {
  final NotificationRepository repository;

  CreateNotificationUseCase(this.repository);

  Future<void> call(NotificationEntity notification) async {
    return await repository.createNotification(notification);
  }
}


