import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/knowledge_document.dart';

class KnowledgeProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<KnowledgeDocument> _documents = [];

  bool get loading => _loading;
  String? get error => _error;
  List<KnowledgeDocument> get documents => _documents;

  Future<void> fetchDocuments() async {
    _loading = true;
    notifyListeners();
    final result = await ApiService.getList('/knowledge');
    if (result.isSuccess && result.data != null) {
      _documents = result.data!.map((e) => KnowledgeDocument.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> createDocument(Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await ApiService.post('/knowledge', data);
    if (result.isSuccess) {
      await fetchDocuments();
    } else {
      _error = result.error;
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateDocument(String id, Map<String, dynamic> data) async {
    final result = await ApiService.put('/knowledge/$id', data);
    if (result.isSuccess) {
      await fetchDocuments();
    }
  }

  Future<void> deleteDocument(String id) async {
    final result = await ApiService.delete('/knowledge/$id');
    if (result.isSuccess) {
      await fetchDocuments();
    }
  }
}
