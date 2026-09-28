import 'package:flutter/foundation.dart';

import '../models/prescription.dart';
import '../repositories/prescription_repository.dart';

class PrescriptionProvider extends ChangeNotifier {
  PrescriptionProvider({PrescriptionRepository? repository})
    : _repository = repository ?? PrescriptionRepository();

  final PrescriptionRepository _repository;

  Prescription? _prescription;

  bool _isLoading = false;
  String? _error;

  Prescription? get prescription => _prescription;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<bool> createPrescription({
    required String patientId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required int durationDays,
    required String instructions,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _prescription = await _repository.createPrescription(
        patientId: patientId,
        medicationName: medicationName,
        dosage: dosage,
        frequency: frequency,
        durationDays: durationDays,
        instructions: instructions,
      );

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> getPrescription(String code) async {
    _setLoading(true);
    _clearError();

    try {
      _prescription = await _repository.getPrescription(code);

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> dispensePrescription(String code) async {
    _setLoading(true);
    _clearError();

    try {
      _prescription = await _repository.dispensePrescription(code);

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearData() {
    _prescription = null;
    notifyListeners();
  }

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
