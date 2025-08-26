import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_room_entity.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.id,
    required super.requestId,
    required super.restaurantId,
    required super.charityId,
    required super.restaurantName,
    required super.charityName,
    required super.proposalTitle,
    required super.createdAt,
    required super.isActive,
    super.lastMessageAt,
    super.lastMessageText,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatRoomModel(
      id: id,
      requestId: json['requestId'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      charityId: json['charityId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      charityName: json['charityName'] ?? '',
      proposalTitle: json['proposalTitle'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
      lastMessageAt: json['lastMessageAt'] != null
          ? (json['lastMessageAt'] as Timestamp).toDate()
          : null,
      lastMessageText: json['lastMessageText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'restaurantId': restaurantId,
      'charityId': charityId,
      'restaurantName': restaurantName,
      'charityName': charityName,
      'proposalTitle': proposalTitle,
      'createdAt': createdAt,
      'isActive': isActive,
      'lastMessageAt': lastMessageAt,
      'lastMessageText': lastMessageText,
    };
  }
}
