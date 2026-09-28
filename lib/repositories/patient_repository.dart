import '../models/patient.dart';
import '../services/patient_service.dart';

class PatientRepository {
  PatientRepository({
    PatientService? service,
  }) : _service = service ?? PatientService();

  final PatientService _service;

  // Rechercher des patients
  Future<List<Patient>> searchPatients({
    String? query,
  }) async {
    return _service.searchPatients(
      query: query,
    );
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
    return _service.createPatient(
      nationalId: nationalId,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      gender: gender,
      bloodGroup: bloodGroup,
      phone: phone,
      emergencyContact: emergencyContact,
      allergies: allergies,
      chronicConditions: chronicConditions,
    );
  }

  // Récupérer un patient
  Future<Patient> getPatient(
    String patientId,
  ) async {
    return _service.getPatient(patientId);
  }

  // Récupérer mon dossier
  Future<Map<String, dynamic>> getMyRecord() async {
    return _service.getMyRecord();
  }

  // Enregistrer les constantes
  Future<Map<String, dynamic>> recordVitals({
    required String patientId,
    required Map<String, dynamic> vitals,
  }) async {
    return _service.recordVitals(
      patientId: patientId,
      vitals: vitals,
    );
  }
}