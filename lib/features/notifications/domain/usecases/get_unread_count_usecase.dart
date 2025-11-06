import '../repositories/notification_repository.dart';

class GetUnreadCountUseCase {
  final NotificationRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<int> call(String restaurantId) async {
    return await repository.getUnreadCount(restaurantId);
  }
}


