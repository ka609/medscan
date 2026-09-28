import '../core/network/api_client.dart';
import '../models/patient.dart';

class PatientService {
  PatientService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  // Rechercher des patients
  Future<List<Patient>> searchPatients({
    String? query,
  }) async {
    final response = await _apiClient.get(
      '/v1/patients',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty)
          'q': query.trim(),
      },
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => Patient.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Créer un patient
  Future<Patient> createPatient({
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
    final response = await _apiClient.post(
      '/v1/patients',
      data: {
        'nationalId': nationalId,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'phone': phone,
        'emergencyContact': emergencyContact,
        'allergies': allergies,
        'chronicConditions': chronicConditions,
      },
    );

    return Patient.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // Récupérer un patient
  Future<Patient> getPatient(
    String patientId,
  ) async {
    final response = await _apiClient.get(
      '/v1/patients/$patientId',
    );

    return Patient.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // Récupérer mon dossier
  Future<Map<String, dynamic>> getMyRecord() async {
    final response = await _apiClient.get(
      '/v1/patient/my-record',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  // Enregistrer les constantes
  Future<Map<String, dynamic>> recordVitals({
    required String patientId,
    required Map<String, dynamic> vitals,
  }) async {
    final response = await _apiClient.post(
      '/v1/patients/$patientId/vitals',
      data: vitals,
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }
}