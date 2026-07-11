import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/campaign.dart';

class CampaignProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<Campaign> _campaigns = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Campaign> get campaigns => _campaigns;

  Future<void> fetchCampaigns() async {
    _loading = true;
    notifyListeners();
    final result = await ApiService.getList('/campaigns');
    if (result.isSuccess && result.data != null) {
      _campaigns = result.data!.map((e) => Campaign.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> createCampaign(Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await ApiService.post('/campaigns', data);
    if (result.isSuccess) {
      await fetchCampaigns();
    } else {
      _error = result.error;
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateCampaign(String id, Map<String, dynamic> data) async {
    final result = await ApiService.put('/campaigns/$id', data);
    if (result.isSuccess) {
      await fetchCampaigns();
    }
  }

  Future<void> deleteCampaign(String id) async {
    final result = await ApiService.delete('/campaigns/$id');
    if (result.isSuccess) {
      await fetchCampaigns();
    }
  }
}
