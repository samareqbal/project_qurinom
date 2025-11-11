import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/chat_messages/chat_messages_bloc.dart';
import '../../data/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String otherName;

  const ChatPage({required this.chatId, required this.otherName, super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatMessagesBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<ChatMessagesBloc>();
    bloc.add(LoadMessages(widget.chatId));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final payload = {
      "chatId": widget.chatId,
      "senderId": userId,
      "content": _ctrl.text.trim(),
      "messageType": "text",
      "fileUrl": ""
    };
    bloc.add(SendMessageEvent(payload));
    _ctrl.clear();

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Widget _buildBubble(MessageModel m, bool isMine) {
    final color = Theme.of(context).colorScheme;
    final bg = isMine ? color.primary : color.surfaceVariant;
    final textColor = isMine ? color.onPrimary : color.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(m.content, style: TextStyle(color: textColor, fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              '${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherName)),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatMessagesBloc, ChatMessagesState>(
              listener: (context, state) {
                if (state is MessagesLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                }
              },
              builder: (context, state) {
                if (state is MessagesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MessagesLoaded) {
                  final msgs = state.messages;
                  if (msgs.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: msgs.length,
                    itemBuilder: (context, i) {
                      final m = msgs[i];
                      //final myId = context.read<ChatMessagesBloc>().socketManager.isConnected;
                      return FutureBuilder(
                        future: SharedPreferences.getInstance(),
                        builder: (context, snap) {
                          final userId = snap.data?.getString('user_id') ?? '';
                          final isMine = m.senderId == userId;
                          return _buildBubble(m, isMine);
                        },
                      );
                    },
                  );
                }
                if (state is MessagesError) {
                  return Center(child: Text('Error: ${state.error}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8, bottom: 8, top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
