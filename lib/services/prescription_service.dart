import '../core/network/api_client.dart';
import '../models/prescription.dart';

class PrescriptionService {
  PrescriptionService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  // Consulter une prescription
  Future<Prescription> getPrescription(String code) async {
    final response = await _apiClient.get('/v1/prescriptions/$code');

    return Prescription.fromJson(response.data as Map<String, dynamic>);
  }
}
