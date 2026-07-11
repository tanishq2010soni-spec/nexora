import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Timer? _reconnectTimer;
  bool _disposed = false;
  bool _intentionalDisconnect = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _baseDelay = Duration(seconds: 1);

  Stream<Map<String, dynamic>>? get messages => _messageController?.stream;

  WebSocketService({this.url = 'ws://localhost:8000/ws'});

  bool get isConnected => _channel != null;

  void connect() {
    if (_disposed) return;
    _intentionalDisconnect = false;
    _messageController = StreamController<Map<String, dynamic>>.broadcast(
      onCancel: () {},
    );
    _doConnect();
  }

  void _doConnect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _reconnectAttempts = 0;

      _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController?.add(message);
          } catch (_) {}
        },
        onError: (error) {
          _handleDisconnect();
        },
        onDone: () {
          _handleDisconnect();
        },
      );
    } catch (e) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _channel = null;
    if (!_intentionalDisconnect && !_disposed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts || _disposed) return;
    _reconnectTimer?.cancel();
    final delay = _baseDelay * (_reconnectAttempts + 1);
    _reconnectAttempts++;
    _reconnectTimer = Timer(delay, _doConnect);
  }

  void sendMessage(String content, String? conversationId) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({
      'type': 'message',
      'content': content,
      'conversation_id': conversationId,
    }));
  }

  void listen(void Function(Map<String, dynamic>) handler) {
    _messageController?.stream.listen(handler);
  }

  void disconnect() {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _messageController?.close();
    _messageController = null;
  }
}
