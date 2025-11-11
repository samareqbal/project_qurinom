import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  IO.Socket? _socket;
  final String baseUrl;

  SocketManager({this.baseUrl = 'http://45.129.87.38:6065'});

  void connect({String? token}) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': token != null ? {'token': token} : {},
    });

    _socket!.onConnect((_) {
      print('Socket connected: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.onError((err) {
      print('Socket error: $err');
    });

    _socket!.connect();
  }

  void onMessage(void Function(dynamic data) handler) {
    _socket?.on('message', handler);
  }

  void sendMessage(Map<String, dynamic> payload) {
    if (_socket?.connected ?? false) {
      _socket!.emit('send_message', payload);
      //print('Sent via socket: $payload');
    } else {
      print('Socket not connected, fallback to REST');
    }
  }

  bool get isConnected => _socket?.connected ?? false;

  void dispose() {
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
  }
}
