import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ConversationProvider extends ChangeNotifier {
  final ApiService _api;

  List<Conversation> _conversations = [];
  Conversation? _selectedConversation;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = '';
  String _departmentFilter = '';

  ConversationProvider(this._api);

  List<Conversation> get conversations => _conversations;
  Conversation? get selectedConversation => _selectedConversation;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get departmentFilter => _departmentFilter;

  int get unreadCount =>
      _conversations.where((c) => c.isUnread).length;

  List<Conversation> get filteredConversations {
    var list = _conversations;
    if (_searchQuery.isNotEmpty) {
      list = list.where((c) =>
          c.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.lastMessage?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
    }
    if (_statusFilter.isNotEmpty) {
      list = list.where((c) => c.status == _statusFilter).toList();
    }
    if (_departmentFilter.isNotEmpty) {
      list = list.where((c) => c.department == _departmentFilter).toList();
    }
    list.sort((a, b) {
      final aTime = a.lastMessageAt ?? a.updatedAt;
      final bTime = b.lastMessageAt ?? b.updatedAt;
      return bTime.compareTo(aTime);
    });
    return list;
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    final filters = <String, String>{};
    if (_statusFilter.isNotEmpty) filters['status'] = _statusFilter;
    if (_departmentFilter.isNotEmpty) filters['department'] = _departmentFilter;

    final result = await _api.getConversations(filters: filters);
    if (result.isSuccess) {
      _conversations = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectConversation(int id) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.getConversation(id);
    if (result.isSuccess) {
      _selectedConversation = result.data;
      _error = null;
      await loadMessages(id);
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages(int conversationId) async {
    final result = await _api.getMessages(conversationId);
    if (result.isSuccess) {
      _messages = result.data ?? [];
    }
  }

  Future<bool> sendMessage(int conversationId, String content) async {
    final result = await _api.sendMessage(conversationId, content);
    if (result.isSuccess) {
      _messages.add(result.data!);
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> requestHandoff(int conversationId) async {
    final result = await _api.requestHandoff(conversationId);
    if (result.isSuccess) {
      await selectConversation(conversationId);
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> resumeAI(int conversationId) async {
    final result = await _api.resumeAI(conversationId);
    if (result.isSuccess) {
      await selectConversation(conversationId);
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> assignConversation(int id, String agentEmail) async {
    final result = await _api.assignConversation(id, agentEmail);
    if (result.isSuccess) {
      await loadConversations();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
    loadConversations();
  }

  void setDepartmentFilter(String filter) {
    _departmentFilter = filter;
    notifyListeners();
    loadConversations();
  }
}
