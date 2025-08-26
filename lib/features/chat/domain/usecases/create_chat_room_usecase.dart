import '../repositories/chat_repository.dart';
import '../entities/chat_room_entity.dart';

class CreateChatRoomUseCase {
  final ChatRepository repository;

  CreateChatRoomUseCase(this.repository);

  Future<void> execute(ChatRoomEntity chatRoom) async {
    await repository.createChatRoom(chatRoom);
  }
}
