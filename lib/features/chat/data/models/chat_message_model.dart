import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.chatRoomId,
    required super.senderId,
    required super.senderName,
    required super.type,
    required super.content,
    super.fileUrl,
    super.fileSize,
    super.duration,
    required super.createdAt,
    required super.isRead,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatMessageModel(
      id: id,
      chatRoomId: json['chatRoomId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      content: json['content'] ?? '',
      fileUrl: json['fileUrl'],
      fileSize: json['fileSize'],
      duration: json['duration'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'type': type.toString().split('.').last,
      'content': content,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'duration': duration,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }
}
