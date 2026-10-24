import '../models/prescription.dart';
import '../services/prescription_service.dart';

class PrescriptionRepository {
  PrescriptionRepository({PrescriptionService? service})
    : _service = service ?? PrescriptionService();

  final PrescriptionService _service;

  // Consulter une prescription
  Future<Prescription> getPrescription(String code) async {
    return _service.getPrescription(code);
  }
}
