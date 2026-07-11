import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/appointment.dart';

class AppointmentProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<Appointment> _appointments = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Appointment> get appointments => _appointments;

  Future<void> fetchAppointments() async {
    _loading = true;
    notifyListeners();
    final result = await ApiService.getList('/appointments');
    if (result.isSuccess && result.data != null) {
      _appointments = result.data!.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> createAppointment(Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await ApiService.post('/appointments', data);
    if (result.isSuccess) {
      await fetchAppointments();
    } else {
      _error = result.error;
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> data) async {
    final result = await ApiService.put('/appointments/$id', data);
    if (result.isSuccess) {
      await fetchAppointments();
    }
  }
}
