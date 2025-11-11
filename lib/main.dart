import 'package:chatapp/presentation/bloc/auth/auth_bloc.dart';
import 'package:chatapp/presentation/bloc/chat_messages/chat_messages_bloc.dart';
import 'package:chatapp/presentation/bloc/chats/chats_bloc.dart';
import 'package:chatapp/presentation/pages/chat_page.dart';
import 'package:chatapp/presentation/pages/chats_page.dart';
import 'package:chatapp/presentation/pages/login_page.dart';
import 'package:chatapp/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/api/dio_client.dart';
import 'core/socket/socket_manager.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dioClient = await DioClient.create();
  final socketManager = SocketManager();

  runApp(MyApp(dioClient: dioClient, socketManager: socketManager));
}

class MyApp extends StatelessWidget {
  final DioClient dioClient;
  final SocketManager socketManager;
  const MyApp({required this.dioClient, required this.socketManager, super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository(dioClient.dio);
    final chatRepo = ChatRepository(dioClient.dio);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepo),
        RepositoryProvider.value(value: chatRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(authRepo)),
          BlocProvider(create: (_) => ChatsBloc(chatRepo)),
          BlocProvider(create: (_) => ChatMessagesBloc(repo: chatRepo, socketManager: socketManager)),
        ],
        child: MaterialApp(
          title: 'Chat Interview App',
          theme: AppTheme.light(),
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (_) => const LoginPage(),
            '/chats': (_) => const ChatsPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/chat') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => ChatPage(chatId: args['chatId'], otherName: args['otherName']),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
