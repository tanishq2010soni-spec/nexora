import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/contact.dart';

class ContactProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<Contact> _contacts = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Contact> get contacts => _contacts;

  Future<void> fetchContacts() async {
    _loading = true;
    notifyListeners();
    final result = await ApiService.getList('/contacts');
    if (result.isSuccess && result.data != null) {
      _contacts = result.data!.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> createContact(Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await ApiService.post('/contacts', data);
    if (result.isSuccess) {
      await fetchContacts();
    } else {
      _error = result.error;
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateContact(String id, Map<String, dynamic> data) async {
    final result = await ApiService.put('/contacts/$id', data);
    if (result.isSuccess) {
      await fetchContacts();
    }
  }
}
