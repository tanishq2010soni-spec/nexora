import 'package:flutter/foundation.dart';
import '../models/memory_entry.dart';
import '../services/api_service.dart';

class MemoryProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<MemoryEntry> _memories = [];
  String _searchQuery = '';
  bool _loading = false;
  String? _error;

  MemoryProvider({required ApiService apiService}) : _apiService = apiService;

  List<MemoryEntry> get memories => _memories;
  String get searchQuery => _searchQuery;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> search(String query) async {
    _searchQuery = query;
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.searchMemory(query);
    if (result.isSuccess) {
      _memories = result.data ?? [];
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_searchQuery.isNotEmpty) {
      await search(_searchQuery);
    }
  }

  Future<void> deleteMemory(String id) async {
    _memories.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
