import '../models/consultation.dart';
import '../services/appointment_service.dart';

class ConsultationRepository {
  ConsultationRepository({
    ConsultationService? service,
  }) : _service = service ?? ConsultationService();

  final ConsultationService _service;

  // Créer une consultation
  Future<Consultation> createConsultation({
    required String patientId,
    required String chiefComplaint,
    required String examinationNotes,
    required String diagnosis,
    required String treatmentPlan,
  }) async {
    return _service.createConsultation(
      patientId: patientId,
      chiefComplaint: chiefComplaint,
      examinationNotes: examinationNotes,
      diagnosis: diagnosis,
      treatmentPlan: treatmentPlan,
    );
  }
}