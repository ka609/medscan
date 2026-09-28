import 'package:flutter/foundation.dart';

import '../models/imaging_study.dart';
import '../repositories/imaging_repository.dart';

class ImagingProvider extends ChangeNotifier {
  ImagingProvider({ImagingRepository? repository})
    : _repository = repository ?? ImagingRepository();

  final ImagingRepository _repository;

  List<ImagingStudy> _studies = [];
  ImagingStudy? _study;

  bool _isLoading = false;
  String? _error;

  List<ImagingStudy> get studies => _studies;

  ImagingStudy? get study => _study;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<bool> getImagingStudies({String? patientId}) async {
    _setLoading(true);
    _clearError();

    try {
      _studies = await _repository.getImagingStudies(patientId: patientId);

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> getImagingStudy(String studyId) async {
    _setLoading(true);
    _clearError();

    try {
      _study = await _repository.getImagingStudy(studyId);

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> triggerAiAnalysis(String studyId) async {
    _setLoading(true);
    _clearError();

    try {
      _study = await _repository.triggerAiAnalysis(studyId);

      return true;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitReport({
    required String studyId,
    required String conclusion,
    required String aiAgreementStatus,
    String? recommendedActions,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _study = await _repository.submitReport(
        studyId: studyId,
        conclusion: conclusion,
        aiAgreementStatus: aiAgreementStatus,
        recommendedActions: recommendedActions,
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
    _studies = [];
    _study = null;

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
