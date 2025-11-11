import 'package:dio/dio.dart';

class ChatRepository {
  final Dio dio;
  ChatRepository(this.dio);

  Future<List<dynamic>> getUserChats(String userId) async {
    final r = await dio.get('/chats/user-chats/$userId');
    if (r.data is List) return r.data as List<dynamic>;
    if (r.data is Map && r.data['data'] is List) return r.data['data'] as List<dynamic>;
    return [];
  }

  Future<List<dynamic>> getMessages(String chatId) async {
    final r = await dio.get('/messages/get-messagesformobile/$chatId');
    if (r.data is List) return r.data as List<dynamic>;
    if (r.data is Map && r.data['data'] is List) return r.data['data'] as List<dynamic>;
    return [];
  }

  Future<Map<String, dynamic>> sendMessageRest(Map<String, dynamic> payload) async {
    final r = await dio.post('/messages/sendMessage', data: payload);
    return r.data is Map<String, dynamic> ? r.data as Map<String, dynamic> : {'raw': r.data};
  }
}
