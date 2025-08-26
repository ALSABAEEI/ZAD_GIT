import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id;
  final String requestId;
  final String restaurantId;
  final String charityId;
  final String restaurantName;
  final String charityName;
  final String proposalTitle;
  final DateTime createdAt;
  final bool isActive;
  final DateTime? lastMessageAt;
  final String? lastMessageText;

  const ChatRoomEntity({
    required this.id,
    required this.requestId,
    required this.restaurantId,
    required this.charityId,
    required this.restaurantName,
    required this.charityName,
    required this.proposalTitle,
    required this.createdAt,
    required this.isActive,
    this.lastMessageAt,
    this.lastMessageText,
  });

  @override
  List<Object?> get props => [
    id,
    requestId,
    restaurantId,
    charityId,
    restaurantName,
    charityName,
    proposalTitle,
    createdAt,
    isActive,
    lastMessageAt,
    lastMessageText,
  ];
}
