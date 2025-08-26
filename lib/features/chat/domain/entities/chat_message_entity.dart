import 'package:equatable/equatable.dart';

enum MessageType { text, image, file }

class ChatMessageEntity extends Equatable {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final MessageType type;
  final String content;
  final String? fileUrl;
  final int? fileSize;
  final int? duration; // for voice messages in seconds
  final DateTime createdAt;
  final bool isRead;

  const ChatMessageEntity({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.content,
    this.fileUrl,
    this.fileSize,
    this.duration,
    required this.createdAt,
    required this.isRead,
  });

  @override
  List<Object?> get props => [
    id,
    chatRoomId,
    senderId,
    senderName,
    type,
    content,
    fileUrl,
    fileSize,
    duration,
    createdAt,
    isRead,
  ];
}
