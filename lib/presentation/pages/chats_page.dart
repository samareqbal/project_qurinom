import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/chats/chats_bloc.dart';
import '../../data/models/chat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/api/dio_client.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});
  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late ChatsBloc bloc;
  bool loading = true;
  List<ChatModel> chats = [];

  @override
  void initState() {
    super.initState();
    bloc = context.read<ChatsBloc>();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    if (userId.isEmpty) {
      // try to fetch from sample or alert
    } else {
      bloc.add(LoadChats(userId));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Chats', style: TextStyle(fontSize: 20),)),
      body: RefreshIndicator(
        onRefresh: _loadChats,
        child: BlocBuilder<ChatsBloc, ChatsState>(
          builder: (context, state) {
            if (state is ChatsLoading) return const Center(child: CircularProgressIndicator());
            if (state is ChatsLoaded) {
              final items = state.chats;
              if (items.isEmpty) return const Center(child: Text('No chats yet'));
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {

                  final c = items[i];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.primaryContainer,
                        child: Text(
                          c.title.isNotEmpty ? c.title[0].toUpperCase() : '?',
                          style: TextStyle(color: color.onPrimaryContainer),
                        ),
                      ),
                      title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Participants: ${c.participants.length}',
                        style: TextStyle(color: color.onSurfaceVariant),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(context, '/chat',
                            arguments: {'chatId': c.id, 'otherName': c.title});
                      },
                    ),
                  );


                  // return ListTile(
                  //   tileColor: Theme.of(context).colorScheme.surfaceVariant,
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  //   title: Text(c.title),
                  //   subtitle: Text('Participants: ${c.participants.length}'),
                  //   onTap: () {
                  //     Navigator.pushNamed(context, '/chat', arguments: {'chatId': c.id, 'otherName': c.title});
                  //   },
                  // );
                },
              );
            }
            if (state is ChatsError) return Center(child: Text('Error: ${state.error}'));
            return const Center(child: Text('Pull to load chats'));
          },
        ),
      ),
    );
  }
}
