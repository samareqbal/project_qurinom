import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class SocketManager {
  IO.Socket? _socket;
  final String baseUrl;
  SocketManager({this.baseUrl = 'http://45.129.87.38:6065'});

  Future<void> connect({String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    final prefToken = prefs.getString('auth_token');
    final t = token ?? prefToken;

    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': t != null ? {'token': t} : {},
    });

    _socket!.onConnect((_) => print('Socket connected: ${_socket!.id}'));
    _socket!.onDisconnect((_) => print('Socket disconnected'));
    _socket!.onError((err) => print('Socket error: $err'));
    _socket!.on('message', (data) => print('Socket event message: $data'));

    _socket!.connect();
  }

  void sendMessage(Map<String, dynamic> payload) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send_message', payload);
    } else {
      throw Exception('Socket not connected');
    }
  }

  void on(String event, void Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  bool get isConnected => _socket?.connected ?? false;

  void dispose() {
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
  }
}
