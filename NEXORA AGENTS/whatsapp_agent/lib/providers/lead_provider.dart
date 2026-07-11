import 'package:flutter/material.dart';
import '../models/lead.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class LeadProvider extends ChangeNotifier {
  final ApiService _api;

  List<Lead> _leads = [];
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = '';
  String _stageFilter = '';
  String _sourceFilter = '';

  LeadProvider(this._api);

  List<Lead> get leads => _leads;
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Lead> get filteredLeads {
    var list = _leads;
    if (_searchQuery.isNotEmpty) {
      list = list.where((l) =>
          l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (l.phone?.contains(_searchQuery) ?? false) ||
          (l.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
    }
    if (_statusFilter.isNotEmpty) {
      list = list.where((l) => l.status == _statusFilter).toList();
    }
    if (_stageFilter.isNotEmpty) {
      list = list.where((l) => l.stage == _stageFilter).toList();
    }
    if (_sourceFilter.isNotEmpty) {
      list = list.where((l) => l.source == _sourceFilter).toList();
    }
    return list;
  }

  Future<void> loadLeads() async {
    _isLoading = true;
    notifyListeners();

    final filters = <String, String>{};
    if (_statusFilter.isNotEmpty) filters['status'] = _statusFilter;
    if (_stageFilter.isNotEmpty) filters['stage'] = _stageFilter;
    if (_sourceFilter.isNotEmpty) filters['source'] = _sourceFilter;

    final result = await _api.getLeads(filters: filters);
    if (result.isSuccess) {
      _leads = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.getCustomers();
    if (result.isSuccess) {
      _customers = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createLead(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.createLead(data);
    if (result.isSuccess) {
      _leads.insert(0, result.data!);
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

  Future<bool> updateLead(int id, Map<String, dynamic> data) async {
    final result = await _api.updateLead(id, data);
    if (result.isSuccess) {
      final index = _leads.indexWhere((l) => l.id == id);
      if (index != -1) _leads[index] = result.data!;
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<Customer?> convertLead(int id, Map<String, dynamic> data) async {
    final result = await _api.convertLead(id, data);
    if (result.isSuccess) {
      _leads.removeWhere((l) => l.id == id);
      _customers.insert(0, result.data!);
      notifyListeners();
      return result.data;
    }
    _error = result.error;
    notifyListeners();
    return null;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setStageFilter(String filter) {
    _stageFilter = filter;
    notifyListeners();
  }

  void setSourceFilter(String filter) {
    _sourceFilter = filter;
    notifyListeners();
  }
}
