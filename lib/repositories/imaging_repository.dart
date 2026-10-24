import '../models/imaging_study.dart';
import '../services/examination_service.dart';

class ImagingRepository {
  ImagingRepository({ImagingService? service})
      : _service = service ?? ImagingService();

  final ImagingService _service;

  Future<List<ImagingStudy>> getImagingStudies({
    String? patientId,
  }) async {
    return _service.getImagingStudies(
      patientId: patientId,
    );
  }

  Future<ImagingStudy> getImagingStudy(
    String studyId,
  ) async {
    return _service.getImagingStudy(studyId);
  }

  Future<ImagingStudy> triggerAiAnalysis(
    String studyId,
  ) async {
    return _service.triggerAiAnalysis(studyId);
  }

  Future<ImagingStudy> submitReport({
    required String studyId,
    required String conclusion,
    required String aiAgreementStatus,
    String? recommendedActions,
  }) async {
    return _service.submitReport(
      studyId: studyId,
      conclusion: conclusion,
      aiAgreementStatus: aiAgreementStatus,
      recommendedActions: recommendedActions,
    );
  }
}