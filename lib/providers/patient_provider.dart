import 'package:flutter/foundation.dart';

import '../services/patient_service.dart';

class PatientProvider extends ChangeNotifier {
  PatientProvider({PatientService? service})
    : _service = service ?? PatientService();

  final PatientService _service;

  Map<String, dynamic>? _myRecord;
  Map<String, dynamic>? _patientPortal;

  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get myRecord => _myRecord;

  Map<String, dynamic>? get patientPortal => _patientPortal;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // Récupérer mon dossier médical
  Future<bool> getMyRecord() async {
    _setLoading(true);
    _clearError();

    try {
      _myRecord = await _service.getMyRecord();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Accéder au portail patient
  Future<bool> getPatientPortal() async {
    _setLoading(true);
    _clearError();

    try {
      _patientPortal = await _service.getPatientPortal();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Vider les données
  void clearData() {
    _myRecord = null;
    _patientPortal = null;

    notifyListeners();
  }

  // Effacer l'erreur
  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
