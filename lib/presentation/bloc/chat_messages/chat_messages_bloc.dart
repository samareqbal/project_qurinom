import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../core/socket/socket_manager.dart';
import '../../../data/models/message_model.dart';

part 'chat_messages_event.dart';
part 'chat_messages_state.dart';

class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final ChatRepository repo;
  final SocketManager socketManager;

  ChatMessagesBloc({required this.repo, required this.socketManager})
      : super(ChatMessagesInitial()) {
    on<LoadMessages>(_onLoad);
    on<SendMessageEvent>(_onSend);
    on<NewIncomingMessageEvent>(_onNewIncoming);

    socketManager.onMessage((data) {
      print('Received socket message: $data');
      try {
        final msg = MessageModel.fromJson(data);
        add(NewIncomingMessageEvent(msg));
      } catch (e) {
        print('Error parsing incoming message: $e');
      }
    });
  }

  Future<void> _onLoad(LoadMessages e, Emitter<ChatMessagesState> emit) async {
    emit(MessagesLoading());
    try {
      final list = await repo.getMessages(e.chatId);
      final messages =
      list.map((m) => MessageModel.fromJson(m as Map<String, dynamic>)).toList();
      emit(MessagesLoaded(messages));
    } catch (ex) {
      emit(MessagesError(ex.toString()));
    }
  }

  Future<void> _onSend(SendMessageEvent e, Emitter<ChatMessagesState> emit) async {
    final current = state;
    List<MessageModel> currentList = [];
    if (current is MessagesLoaded) currentList = List.from(current.messages);

    final optimistic = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: e.payload['chatId'] ?? '',
      senderId: e.payload['senderId'] ?? '',
      content: e.payload['content'] ?? '',
      messageType: e.payload['messageType'] ?? 'text',
      fileUrl: e.payload['fileUrl'] ?? '',
      createdAt: DateTime.now(),
    );

    currentList.add(optimistic);
    emit(MessagesLoaded(currentList));

    try {
      if (socketManager.isConnected) {
        socketManager.sendMessage(e.payload);
      } else {
        await repo.sendMessageRest(e.payload);
      }
    } catch (ex) {
      try {
        await repo.sendMessageRest(e.payload);
      } catch (ex2) {
        emit(MessagesError('Failed to send: ${ex2.toString()}'));
      }
    }
  }

  Future<void> _onNewIncoming(
      NewIncomingMessageEvent e, Emitter<ChatMessagesState> emit) async {
    final current = state;
    if (current is MessagesLoaded) {
      final updated = List<MessageModel>.from(current.messages)..add(e.message);
      emit(MessagesLoaded(updated));
    }
  }
}
