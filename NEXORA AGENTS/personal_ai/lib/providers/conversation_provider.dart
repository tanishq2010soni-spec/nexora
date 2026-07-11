import 'package:flutter/foundation.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

class ConversationProvider extends ChangeNotifier {
  final ApiService _apiService;
  final WebSocketService _wsService;

  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  bool _loading = false;
  String? _error;

  ConversationProvider({
    required ApiService apiService,
    required WebSocketService wsService,
  })  : _apiService = apiService,
        _wsService = wsService {
    _wsService.listen(_handleWsMessage);
  }

  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  bool get loading => _loading;
  String? get error => _error;

  void _handleWsMessage(Map<String, dynamic> message) {
    if (message['type'] == 'message' && _currentConversation != null) {
      final msg = Message.fromJson(message['data'] as Map<String, dynamic>);
      final updated = _currentConversation!.messages;
      _currentConversation = Conversation(
        id: _currentConversation!.id,
        title: _currentConversation!.title,
        messages: [...updated, msg],
        createdAt: _currentConversation!.createdAt,
        updatedAt: _currentConversation!.updatedAt,
      );
      notifyListeners();
    }
  }

  Future<void> loadConversations() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getConversations();
    if (result.isSuccess) {
      _conversations = result.data ?? [];
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> selectConversation(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getConversation(id);
    if (result.isSuccess) {
      _currentConversation = result.data;
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<Message?> sendMessage(String content) async {
    final result = await _apiService.sendMessage(
      content,
      _currentConversation?.id,
    );
    if (result.isSuccess) {
      return result.data;
    }
    _error = result.error;
    notifyListeners();
    return null;
  }

  Future<Conversation?> createConversation() async {
    final result = await _apiService.sendMessage('', null);
    if (result.isSuccess) {
      await loadConversations();
      return _conversations.firstOrNull;
    }
    _error = result.error;
    notifyListeners();
    return null;
  }

  Future<bool> deleteConversation(String id) async {
    final result = await _apiService.deleteConversation(id);
    if (result.isSuccess) {
      _conversations.removeWhere((c) => c.id == id);
      if (_currentConversation?.id == id) {
        _currentConversation = null;
      }
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
