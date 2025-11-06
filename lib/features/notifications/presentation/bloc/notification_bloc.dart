import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/create_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';

// Events
abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {
  final String restaurantId;
  LoadNotifications(this.restaurantId);
}

class CreateNotificationEvent extends NotificationEvent {
  final NotificationEntity notification;
  CreateNotificationEvent(this.notification);
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;
  MarkNotificationAsRead(this.notificationId);
}

class LoadUnreadCount extends NotificationEvent {
  final String restaurantId;
  LoadUnreadCount(this.restaurantId);
}

// States
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  NotificationsLoaded(this.notifications);
}

class UnreadCountLoaded extends NotificationState {
  final int count;
  UnreadCountLoaded(this.count);
}

class NotificationCreated extends NotificationState {}

class NotificationMarkedAsRead extends NotificationState {}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

// BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final CreateNotificationUseCase createNotificationUseCase;
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final MarkAsReadUseCase markAsReadUseCase;

  NotificationBloc({
    required this.createNotificationUseCase,
    required this.getNotificationsUseCase,
    required this.getUnreadCountUseCase,
    required this.markAsReadUseCase,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<CreateNotificationEvent>(_onCreateNotification);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<LoadUnreadCount>(_onLoadUnreadCount);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await getNotificationsUseCase(event.restaurantId);
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError('Failed to load notifications: ${e.toString()}'));
    }
  }

  Future<void> _onCreateNotification(
    CreateNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await createNotificationUseCase(event.notification);
      emit(NotificationCreated());
    } catch (e) {
      emit(NotificationError('Failed to create notification: ${e.toString()}'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await markAsReadUseCase(event.notificationId);
      emit(NotificationMarkedAsRead());
    } catch (e) {
      emit(NotificationError('Failed to mark as read: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final count = await getUnreadCountUseCase(event.restaurantId);
      emit(UnreadCountLoaded(count));
    } catch (e) {
      emit(NotificationError('Failed to load unread count: ${e.toString()}'));
    }
  }
}


