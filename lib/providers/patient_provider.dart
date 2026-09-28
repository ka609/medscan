import 'package:flutter/foundation.dart';

import '../models/patient.dart';
import '../services/patient_service.dart';

class PatientProvider extends ChangeNotifier {
  PatientProvider({PatientService? service})
      : _service = service ?? PatientService();

  final PatientService _service;

  List<Patient> _patients = [];
  Patient? _patient;
  Map<String, dynamic>? _myRecord;

  bool _isLoading = false;
  String? _error;

  List<Patient> get patients => _patients;

  Patient? get patient => _patient;

  Map<String, dynamic>? get myRecord => _myRecord;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // Rechercher des patients
  Future<void> searchPatients({
    String? query,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _patients = await _service.searchPatients(
        query: query,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Créer un patient
  Future<bool> createPatient({
    required String nationalId,
    required String firstName,
    required String lastName,
    required String birthDate,
    required String gender,
    required String bloodGroup,
    required String phone,
    required String emergencyContact,
    required List<String> allergies,
    required List<String> chronicConditions,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _patient = await _service.createPatient(
        nationalId: nationalId,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        gender: gender,
        bloodGroup: bloodGroup,
        phone: phone,
        emergencyContact: emergencyContact,
        allergies: allergies,
        chronicConditions: chronicConditions,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Récupérer un patient
  Future<bool> getPatient(
    String patientId,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      _patient = await _service.getPatient(
        patientId,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Récupérer mon dossier
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

  // Enregistrer les constantes
  Future<bool> recordVitals({
    required String patientId,
    required Map<String, dynamic> vitals,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _service.recordVitals(
        patientId: patientId,
        vitals: vitals,
      );

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
    _patients = [];
    _patient = null;
    _myRecord = null;

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