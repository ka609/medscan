import '../core/network/api_client.dart';
import '../models/imaging_study.dart';

class ImagingService {
  ImagingService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<List<ImagingStudy>> getImagingStudies({String? patientId}) async {
    final response = await _apiClient.get(
      '/v1/imaging/studies',
      queryParameters: {
        if (patientId != null && patientId.isNotEmpty) 'patientId': patientId,
      },
    );

    final data = response.data as List<dynamic>;

    return data
        .map((item) => ImagingStudy.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ImagingStudy> getImagingStudy(String studyId) async {
    final response = await _apiClient.get('/v1/imaging/studies/$studyId');

    return ImagingStudy.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ImagingStudy> triggerAiAnalysis(String studyId) async {
    final response = await _apiClient.post(
      '/v1/imaging/studies/$studyId/ai-analyze',
    );

    return ImagingStudy.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ImagingStudy> submitReport({
    required String studyId,
    required String conclusion,
    required String aiAgreementStatus,
    String? recommendedActions,
  }) async {
    final data = <String, dynamic>{
      'conclusion': conclusion,
      'aiAgreementStatus': aiAgreementStatus,
    };

    if (recommendedActions != null) {
      data['recommendedActions'] = recommendedActions;
    }

    final response = await _apiClient.post(
      '/v1/imaging/studies/$studyId/report',
      data: data,
    );

    return ImagingStudy.fromJson(response.data as Map<String, dynamic>);
  }
}
