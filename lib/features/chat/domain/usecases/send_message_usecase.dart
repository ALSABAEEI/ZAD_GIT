import '../repositories/chat_repository.dart';
import '../entities/chat_message_entity.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> execute(ChatMessageEntity message) async {
    await repository.sendMessage(message);
  }
}
