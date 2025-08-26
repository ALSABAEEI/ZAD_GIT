import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/get_chat_rooms_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/create_chat_room_usecase.dart';
import '../../domain/repositories/chat_repository.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatRooms extends ChatEvent {
  final String userId;

  const LoadChatRooms(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SendMessage extends ChatEvent {
  final ChatMessageEntity message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateChatRoom extends ChatEvent {
  final ChatRoomEntity chatRoom;

  const CreateChatRoom(this.chatRoom);

  @override
  List<Object?> get props => [chatRoom];
}

class LoadMessages extends ChatEvent {
  final String chatRoomId;

  const LoadMessages(this.chatRoomId);

  @override
  List<Object?> get props => [chatRoomId];
}

// States
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoomEntity> chatRooms;

  const ChatRoomsLoaded(this.chatRooms);

  @override
  List<Object?> get props => [chatRooms];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageSent extends ChatState {}

class MessagesLoaded extends ChatState {
  final List<ChatMessageEntity> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatRoomsUseCase getChatRoomsUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final CreateChatRoomUseCase createChatRoomUseCase;
  final ChatRepository chatRepository;

  ChatBloc({
    required this.getChatRoomsUseCase,
    required this.sendMessageUseCase,
    required this.createChatRoomUseCase,
    required this.chatRepository,
  }) : super(ChatInitial()) {
    on<LoadChatRooms>(_onLoadChatRooms);
    on<SendMessage>(_onSendMessage);
    on<CreateChatRoom>(_onCreateChatRoom);
    on<LoadMessages>(_onLoadMessages);
  }

  Future<void> _onLoadChatRooms(
    LoadChatRooms event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final chatRooms = await getChatRoomsUseCase.execute(event.userId);
      emit(ChatRoomsLoaded(chatRooms));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await sendMessageUseCase.execute(event.message);
      emit(MessageSent());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onCreateChatRoom(
    CreateChatRoom event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await createChatRoomUseCase.execute(event.chatRoom);
      // Reload chat rooms after creating new one
      if (state is ChatRoomsLoaded) {
        final currentState = state as ChatRoomsLoaded;
        final updatedRooms = [...currentState.chatRooms, event.chatRoom];
        emit(ChatRoomsLoaded(updatedRooms));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final messages = await chatRepository.getMessagesByChatRoom(
        event.chatRoomId,
      );
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
