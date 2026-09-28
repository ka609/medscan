import '../models/prescription.dart';
import '../services/prescription_service.dart';

class PrescriptionRepository {
  PrescriptionRepository({PrescriptionService? service})
      : _service = service ?? PrescriptionService();

  final PrescriptionService _service;

  Future<Prescription> createPrescription({
    required String patientId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required int durationDays,
    required String instructions,
  }) async {
    return _service.createPrescription(
      patientId: patientId,
      medicationName: medicationName,
      dosage: dosage,
      frequency: frequency,
      durationDays: durationDays,
      instructions: instructions,
    );
  }

  Future<Prescription> getPrescription(
    String code,
  ) async {
    return _service.getPrescription(code);
  }

  Future<Prescription> dispensePrescription(
    String code,
  ) async {
    return _service.dispensePrescription(code);
  }
}