import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/models/chat_model.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final ChatRepository repo;
  ChatsBloc(this.repo) : super(ChatsInitial()) {
    on<LoadChats>(_onLoad);
  }

  Future<void> _onLoad(LoadChats e, Emitter<ChatsState> emit) async {
    emit(ChatsLoading());
    try {
      final list = await repo.getUserChats(e.userId);
      final chats = list.map((m) => ChatModel.fromJson(m as Map<String, dynamic>)).toList();
      emit(ChatsLoaded(chats));
    } catch (ex) {
      emit(ChatsError(ex.toString()));
    }
  }
}
