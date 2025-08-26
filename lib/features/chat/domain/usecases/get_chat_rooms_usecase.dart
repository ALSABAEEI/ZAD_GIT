import '../repositories/chat_repository.dart';
import '../entities/chat_room_entity.dart';

class GetChatRoomsUseCase {
  final ChatRepository repository;

  GetChatRoomsUseCase(this.repository);

  Future<List<ChatRoomEntity>> execute(String userId) async {
    return await repository.getChatRoomsByUser(userId);
  }
}
