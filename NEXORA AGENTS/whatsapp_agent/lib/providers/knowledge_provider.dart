import 'package:flutter/material.dart';
import '../models/knowledge_document.dart';
import '../services/api_service.dart';

class KnowledgeProvider extends ChangeNotifier {
  final ApiService _api;

  List<KnowledgeDocument> _documents = [];
  bool _isLoading = false;
  String? _error;
  String? _queryResult;
  String _searchQuery = '';

  KnowledgeProvider(this._api);

  List<KnowledgeDocument> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get queryResult => _queryResult;

  List<KnowledgeDocument> get filteredDocuments {
    if (_searchQuery.isEmpty) return _documents;
    return _documents.where((d) =>
        d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        d.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()))).toList();
  }

  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.getKnowledgeDocuments();
    if (result.isSuccess) {
      _documents = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadDocument(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.uploadKnowledge(data);
    if (result.isSuccess) {
      _documents.insert(0, result.data!);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDocument(int id) async {
    final result = await _api.deleteKnowledge(id);
    if (result.isSuccess) {
      _documents.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<void> queryKnowledge(String query) async {
    _isLoading = true;
    _queryResult = null;
    notifyListeners();

    final result = await _api.queryKnowledge(query);
    if (result.isSuccess) {
      _queryResult = result.data;
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearQueryResult() {
    _queryResult = null;
    notifyListeners();
  }
}
