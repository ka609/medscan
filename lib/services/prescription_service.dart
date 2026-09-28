import '../core/network/api_client.dart';
import '../models/prescription.dart';

class PrescriptionService {
  PrescriptionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<Prescription> createPrescription({
    required String patientId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required int durationDays,
    required String instructions,
  }) async {
    final response = await _apiClient.post(
      '/v1/patients/$patientId/prescriptions',
      data: {
        'medicationName': medicationName,
        'dosage': dosage,
        'frequency': frequency,
        'durationDays': durationDays,
        'instructions': instructions,
      },
    );

    return Prescription.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<Prescription> getPrescription(String code) async {
    final response = await _apiClient.get(
      '/v1/prescriptions/$code',
    );

    return Prescription.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<Prescription> dispensePrescription(String code) async {
    final response = await _apiClient.post(
      '/v1/prescriptions/$code/dispense',
    );

    return Prescription.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}