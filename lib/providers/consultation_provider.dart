import 'package:flutter/foundation.dart';

import '../models/consultation.dart';
import '../repositories/consultation_repository.dart';

class ConsultationProvider extends ChangeNotifier {
  ConsultationProvider({ConsultationRepository? repository})
    : _repository = repository ?? ConsultationRepository();

  final ConsultationRepository _repository;

  Consultation? _consultation;

  bool _isLoading = false;
  String? _error;

  Consultation? get consultation => _consultation;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<bool> createConsultation({
    required String patientId,
    required String chiefComplaint,
    required String examinationNotes,
    required String diagnosis,
    required String treatmentPlan,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _consultation = await _repository.createConsultation(
        patientId: patientId,
        chiefComplaint: chiefComplaint,
        examinationNotes: examinationNotes,
        diagnosis: diagnosis,
        treatmentPlan: treatmentPlan,
      );

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearData() {
    _consultation = null;
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
