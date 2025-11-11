part of 'chat_messages_bloc.dart';

abstract class ChatMessagesEvent extends Equatable {
  const ChatMessagesEvent();
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatMessagesEvent {
  final String chatId;
  const LoadMessages(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

class SendMessageEvent extends ChatMessagesEvent {
  final Map<String, dynamic> payload;
  const SendMessageEvent(this.payload);
  @override
  List<Object?> get props => [payload];
}

class NewIncomingMessageEvent extends ChatMessagesEvent {
  final MessageModel message;
  const NewIncomingMessageEvent(this.message);
  @override
  List<Object?> get props => [message];
}

