import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../services/api_service.dart';

class CampaignProvider extends ChangeNotifier {
  final ApiService _api;

  List<Campaign> _campaigns = [];
  bool _isLoading = false;
  String? _error;

  CampaignProvider(this._api);

  List<Campaign> get campaigns => _campaigns;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCampaigns() async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.getCampaigns();
    if (result.isSuccess) {
      _campaigns = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createCampaign(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.createCampaign(data);
    if (result.isSuccess) {
      _campaigns.insert(0, result.data!);
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

  Future<bool> updateCampaign(int id, Map<String, dynamic> data) async {
    final result = await _api.updateCampaign(id, data);
    if (result.isSuccess) {
      final index = _campaigns.indexWhere((c) => c.id == id);
      if (index != -1) _campaigns[index] = result.data!;
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> sendCampaign(int id) async {
    final result = await _api.sendCampaign(id);
    if (result.isSuccess) {
      await loadCampaigns();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> pauseCampaign(int id) async {
    final result = await _api.pauseCampaign(id);
    if (result.isSuccess) {
      await loadCampaigns();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }
}
