import '../core/network/api_client.dart';
import '../models/consultation.dart';

class ConsultationService {
  ConsultationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<Consultation> createConsultation({
    required String patientId,
    required String chiefComplaint,
    required String examinationNotes,
    required String diagnosis,
    required String treatmentPlan,
  }) async {
    final response = await _apiClient.post(
      '/v1/patients/$patientId/consultations',
      data: {
        'chiefComplaint': chiefComplaint,
        'examinationNotes': examinationNotes,
        'diagnosis': diagnosis,
        'treatmentPlan': treatmentPlan,
      },
    );

    return Consultation.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}