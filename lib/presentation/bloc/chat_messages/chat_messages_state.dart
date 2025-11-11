part of 'chat_messages_bloc.dart';

abstract class ChatMessagesState extends Equatable {
  const ChatMessagesState();
  @override
  List<Object?> get props => [];
}

class ChatMessagesInitial extends ChatMessagesState {}
class MessagesLoading extends ChatMessagesState {}
class MessagesLoaded extends ChatMessagesState {
  final List<MessageModel> messages;
  const MessagesLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}
class MessagesError extends ChatMessagesState {
  final String error;
  const MessagesError(this.error);
  @override
  List<Object?> get props => [error];
}
