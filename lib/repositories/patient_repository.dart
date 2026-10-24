import '../services/patient_service.dart';

class PatientRepository {
  PatientRepository({PatientService? service})
    : _service = service ?? PatientService();

  final PatientService _service;

  // Récupérer mon dossier médical
  Future<Map<String, dynamic>> getMyRecord() async {
    return _service.getMyRecord();
  }

  // Accéder au portail patient
  Future<Map<String, dynamic>> getPatientPortal() async {
    return _service.getPatientPortal();
  }
}
