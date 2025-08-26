import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../models/chat_room_model.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepositoryImpl(this._firestore);

  @override
  Future<List<ChatRoomEntity>> getChatRoomsByUser(String userId) async {
    try {
      // Get all active chat rooms and filter in memory to avoid index requirements
      final querySnapshot = await _firestore
          .collection('chat_rooms')
          .where('isActive', isEqualTo: true)
          .get();

      final allRooms = querySnapshot.docs
          .map((doc) => ChatRoomModel.fromJson(doc.data(), doc.id))
          .toList();

      // Filter for rooms where user is either restaurant or charity
      final userRooms = allRooms
          .where(
            (room) => room.restaurantId == userId || room.charityId == userId,
          )
          .toList();

      // Sort by last message time
      userRooms.sort((a, b) {
        final aTime = a.lastMessageAt ?? DateTime.now();
        final bTime = b.lastMessageAt ?? DateTime.now();
        return bTime.compareTo(aTime);
      });

      return userRooms;
    } catch (e) {
      throw Exception('Failed to get chat rooms: $e');
    }
  }

  @override
  Future<ChatRoomEntity?> getChatRoomById(String chatRoomId) async {
    try {
      final doc = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .get();

      if (doc.exists) {
        return ChatRoomModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get chat room: $e');
    }
  }

  @override
  Future<void> createChatRoom(ChatRoomEntity chatRoom) async {
    try {
      // Convert ChatRoomEntity to ChatRoomModel
      final chatRoomModel = ChatRoomModel(
        id: chatRoom.id,
        requestId: chatRoom.requestId,
        restaurantId: chatRoom.restaurantId,
        charityId: chatRoom.charityId,
        restaurantName: chatRoom.restaurantName,
        charityName: chatRoom.charityName,
        proposalTitle: chatRoom.proposalTitle,
        createdAt: chatRoom.createdAt,
        isActive: chatRoom.isActive,
        lastMessageAt: chatRoom.lastMessageAt,
        lastMessageText: chatRoom.lastMessageText,
      );

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoom.id)
          .set(chatRoomModel.toJson());
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }

  @override
  Future<void> updateChatRoom(ChatRoomEntity chatRoom) async {
    try {
      // Convert ChatRoomEntity to ChatRoomModel
      final chatRoomModel = ChatRoomModel(
        id: chatRoom.id,
        requestId: chatRoom.requestId,
        restaurantId: chatRoom.restaurantId,
        charityId: chatRoom.charityId,
        restaurantName: chatRoom.restaurantName,
        charityName: chatRoom.charityName,
        proposalTitle: chatRoom.proposalTitle,
        createdAt: chatRoom.createdAt,
        isActive: chatRoom.isActive,
        lastMessageAt: chatRoom.lastMessageAt,
        lastMessageText: chatRoom.lastMessageText,
      );

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoom.id)
          .update(chatRoomModel.toJson());
    } catch (e) {
      throw Exception('Failed to update chat room: $e');
    }
  }

  @override
  Future<void> closeChatRoom(String chatRoomId) async {
    try {
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to close chat room: $e');
    }
  }

  @override
  Future<List<ChatMessageEntity>> getMessagesByChatRoom(
    String chatRoomId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy(
            'createdAt',
            descending: true,
          ) // Get newest first for flutter_chat_ui
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatMessageModel.fromJson(doc.data(), doc.id))
          .toList(); // flutter_chat_ui expects newest first
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Future<void> sendMessage(ChatMessageEntity message) async {
    try {
      // Convert ChatMessageEntity to ChatMessageModel
      final messageModel = ChatMessageModel(
        id: message.id,
        chatRoomId: message.chatRoomId,
        senderId: message.senderId,
        senderName: message.senderName,
        type: message.type,
        content: message.content,
        fileUrl: message.fileUrl,
        fileSize: message.fileSize,
        duration: message.duration,
        createdAt: message.createdAt,
        isRead: message.isRead,
      );

      final messageRef = await _firestore
          .collection('chat_rooms')
          .doc(message.chatRoomId)
          .collection('messages')
          .add(messageModel.toJson());

      // Update chat room with last message info
      await _firestore.collection('chat_rooms').doc(message.chatRoomId).update({
        'lastMessageAt': message.createdAt,
        'lastMessageText': message.content,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    try {
      // This would need to be implemented with the specific chat room ID
      // For now, we'll implement it when we have the full context
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  @override
  Stream<List<ChatMessageEntity>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy(
          'createdAt',
          descending: true,
        ) // Get newest first for flutter_chat_ui
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromJson(doc.data(), doc.id))
              .toList(), // flutter_chat_ui expects newest first
        );
  }

  @override
  Stream<List<ChatRoomEntity>> getChatRoomsStream(String userId) {
    // Use a simpler query to avoid index requirements
    // Get all chat rooms and filter in memory
    return _firestore
        .collection('chat_rooms')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final allRooms = snapshot.docs
              .map((doc) => ChatRoomModel.fromJson(doc.data(), doc.id))
              .toList();

          // Filter for rooms where user is either restaurant or charity
          final userRooms = allRooms
              .where(
                (room) =>
                    room.restaurantId == userId || room.charityId == userId,
              )
              .toList();

          // Sort by last message time
          userRooms.sort((a, b) {
            final aTime = a.lastMessageAt ?? DateTime.now();
            final bTime = b.lastMessageAt ?? DateTime.now();
            return bTime.compareTo(aTime);
          });

          return userRooms;
        });
  }
}
