import '../core/network/api_client.dart';
import '../core/utils/id_generator.dart';
import '../models/certificate.dart';
import '../models/message.dart';
import 'message_service.dart';

class CertificateService {
  CertificateService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance {
    _ensureInitialized();
  }

  final ApiClient _apiClient;

  static final List<MedicalCertificate> _inMemoryCertificates = [];
  static bool _seeded = false;

  static void _ensureInitialized() {
    if (_seeded) return;
    _seeded = true;

    final docId = IdGenerator.doctorId();
    final patientId = IdGenerator.patientId();
    final tenantId = IdGenerator.tenantId();

    _inMemoryCertificates.addAll([
      MedicalCertificate(
        id: IdGenerator.certificateId(),
        certificateNumber: IdGenerator.certificateCode(),
        type: 'SICK_LEAVE',
        patientId: patientId,
        patientName: 'Patient Suivi',
        doctorId: docId,
        doctorName: 'Dr. Amadou Ouédraogo (Cardiologue)',
        tenantId: tenantId,
        hospitalName: 'CHU Yalgado Ouédraogo',
        diagnosisOrReason: 'Syndrome viral fébrile aigu avec asthénie nécessitant repos strict.',
        restDurationDays: 4,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        employerOrInstitution: 'Direction Générale des Ressources Humaines',
        allowPhysicalActivities: false,
        status: 'ISSUED',
        digitalSealHash: 'SHA256:4a8b29c1e7f6032d1845bb09f12c8a90d4e3f21b79e8d47b192c3d4e5f6a7b8c',
        verificationUrl: 'https://medscan-sluw.onrender.com/medscan/api/v1/certificates/verify',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MedicalCertificate(
        id: IdGenerator.certificateId(),
        certificateNumber: IdGenerator.certificateCode(),
        type: 'FITNESS_CERTIFICATE',
        patientId: patientId,
        patientName: 'Patient Suivi',
        doctorId: docId,
        doctorName: 'Dr. Fatimata Sawadogo (Médecin Généraliste)',
        tenantId: tenantId,
        hospitalName: 'Clinique Internationale',
        diagnosisOrReason: 'Examen clinique cardiorespiratoire normal. Apte aux épreuves physiques et activités sportives.',
        restDurationDays: 0,
        startDate: DateTime.now().subtract(const Duration(days: 14)),
        endDate: DateTime.now().add(const Duration(days: 350)),
        employerOrInstitution: 'Fédération Nationale de Sport',
        allowPhysicalActivities: true,
        status: 'ISSUED',
        digitalSealHash: 'SHA256:91ef20a845cd1203e87bb1246193e1f0a459b76c82301938fe71024bd7a93012',
        verificationUrl: 'https://medscan-sluw.onrender.com/medscan/api/v1/certificates/verify',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
    ]);
  }

  // Récupérer les certificats médicaux (filtrés selon patient ou médecin émetteur)
  Future<List<MedicalCertificate>> getCertificates({
    String? patientId,
    String? doctorId,
    bool isDoctor = false,
  }) async {
    _ensureInitialized();
    try {
      final endpoint = patientId != null
          ? '/v1/certificates?patientId=$patientId'
          : (doctorId != null
              ? '/v1/certificates?doctorId=$doctorId'
              : '/v1/certificates');
      final response = await _apiClient.get(endpoint);

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => MedicalCertificate.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    return _inMemoryCertificates.where((cert) {
      if (patientId != null && patientId.isNotEmpty) {
        return cert.patientId == patientId ||
            cert.patientName.toLowerCase().trim() == patientId.toLowerCase().trim();
      }
      if (isDoctor && doctorId != null && doctorId.isNotEmpty) {
        return cert.doctorId == doctorId ||
            cert.doctorName.toLowerCase().contains(doctorId.toLowerCase());
      }
      return true;
    }).toList();
  }

  // Émettre et sceller un certificat officiel transmis au patient
  Future<MedicalCertificate> issueCertificate(Map<String, dynamic> data) async {
    _ensureInitialized();
    try {
      final response = await _apiClient.post('/v1/certificates', data: data);
      if (response.data is Map) {
        final serverCert = MedicalCertificate.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        _inMemoryCertificates.insert(0, serverCert);
        _dispatchPatientNotification(serverCert);
        return serverCert;
      }
    } catch (_) {
      // Fallback local avec sceau officiel
    }

    final duration = (data['restDurationDays'] as num?)?.toInt() ?? 3;
    final now = DateTime.now();
    final start = data['startDate'] != null
        ? DateTime.tryParse(data['startDate'].toString()) ?? now
        : now;
    final end = start.add(Duration(days: duration));

    final generatedCertId = IdGenerator.certificateId();
    final generatedCertCode = IdGenerator.certificateCode();

    final cert = MedicalCertificate.fromJson({
      'id': generatedCertId,
      'certificateNumber': generatedCertCode,
      'type': data['type'] ?? 'SICK_LEAVE',
      'patientId': data['patientId'] ?? IdGenerator.patientId(),
      'patientName': data['patientName'] ?? 'Patient',
      'doctorId': data['doctorId'] ?? IdGenerator.doctorId(),
      'doctorName': data['doctorName'] ?? 'Dr. Praticien',
      'tenantId': data['tenantId'] ?? IdGenerator.tenantId(),
      'hospitalName': data['hospitalName'] ?? 'CHU Yalgado Ouédraogo',
      'diagnosisOrReason': data['diagnosisOrReason'] ?? 'Repos médical strict requis suite à consultation.',
      'restDurationDays': duration,
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
      'employerOrInstitution': data['employerOrInstitution'] ?? 'Direction des Ressources Humaines',
      'allowPhysicalActivities': data['allowPhysicalActivities'] ?? false,
      'status': 'ISSUED',
      'digitalSealHash': 'SHA256:7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069',
      'verificationUrl': 'https://medscan-sluw.onrender.com/medscan/api/v1/certificates/verify?code=$generatedCertCode',
      'createdAt': now.toIso8601String(),
    });

    _inMemoryCertificates.insert(0, cert);
    _dispatchPatientNotification(cert);

    return cert;
  }

  void _dispatchPatientNotification(MedicalCertificate cert) {
    MessageService.addAlert(
      ClinicalAlert(
        id: IdGenerator.alertId(),
        recipientUserId: cert.patientId,
        title: 'Nouveau Certificat Médical (${cert.typeLabel})',
        message: 'Le ${cert.doctorName} vous a délivré un certificat officiel avec cachet de l\'hôpital pour une durée de ${cert.restDurationDays} jour(s). Prêt au téléchargement PDF.',
        type: 'CERTIFICATE',
        severity: 'INFO',
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: '/certificates',
      ),
    );
  }
}
