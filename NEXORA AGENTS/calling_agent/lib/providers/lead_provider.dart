import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/lead.dart';

class LeadProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<Lead> _leads = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Lead> get leads => _leads;

  Future<void> fetchLeads({String? status, String? campaignId}) async {
    _loading = true;
    notifyListeners();
    String path = '/leads?limit=100';
    if (status != null) path += '&status=$status';
    if (campaignId != null) path += '&campaign_id=$campaignId';
    final result = await ApiService.getList(path);
    if (result.isSuccess && result.data != null) {
      _leads = result.data!.map((e) => Lead.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> createLead(Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await ApiService.post('/leads', data);
    if (result.isSuccess) {
      await fetchLeads();
    } else {
      _error = result.error;
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateLead(String id, Map<String, dynamic> data) async {
    final result = await ApiService.put('/leads/$id', data);
    if (result.isSuccess) {
      await fetchLeads();
    }
  }

  Future<void> deleteLead(String id) async {
    final result = await ApiService.delete('/leads/$id');
    if (result.isSuccess) {
      await fetchLeads();
    }
  }

  Future<void> importLeads(String filePath) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await ApiService.upload('/leads/import', filePath, 'file');
    if (result.isSuccess) {
      await fetchLeads();
    } else {
      _error = result.error;
      _loading = false;
      notifyListeners();
    }
  }
}
