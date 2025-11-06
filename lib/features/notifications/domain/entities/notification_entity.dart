class NotificationEntity {
  final String id;
  final String restaurantId;
  final String title;
  final String message;
  final String
  type; // 'proposal_status', 'reservation', 'reservation_cancelled'
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>?
  metadata; // Additional data like proposalId, foodItemId, etc.

  const NotificationEntity({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  NotificationEntity copyWith({
    String? id,
    String? restaurantId,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}


