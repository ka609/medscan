import '../core/network/api_client.dart';

class PatientService {
  PatientService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  // Récupérer mon dossier médical
  Future<Map<String, dynamic>> getMyRecord() async {
    final response = await _apiClient.get('/v1/patient/my-record');

    return Map<String, dynamic>.from(response.data as Map);
  }

  // Accéder au portail patient
  Future<Map<String, dynamic>> getPatientPortal() async {
    final response = await _apiClient.get('/v1/portal/patient');

    return Map<String, dynamic>.from(response.data as Map);
  }
}
