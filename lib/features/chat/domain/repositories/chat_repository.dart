import '../entities/chat_room_entity.dart';
import '../entities/chat_message_entity.dart';

abstract class ChatRepository {
  // Chat Rooms
  Future<List<ChatRoomEntity>> getChatRoomsByUser(String userId);
  Future<ChatRoomEntity?> getChatRoomById(String chatRoomId);
  Future<void> createChatRoom(ChatRoomEntity chatRoom);
  Future<void> updateChatRoom(ChatRoomEntity chatRoom);
  Future<void> closeChatRoom(String chatRoomId);

  // Messages
  Future<List<ChatMessageEntity>> getMessagesByChatRoom(String chatRoomId);
  Future<void> sendMessage(ChatMessageEntity message);
  Future<void> markMessageAsRead(String messageId);
  Stream<List<ChatMessageEntity>> getMessagesStream(String chatRoomId);

  // Real-time updates
  Stream<List<ChatRoomEntity>> getChatRoomsStream(String userId);
}
