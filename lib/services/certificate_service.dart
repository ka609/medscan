import '../core/network/api_client.dart';
import '../models/certificate.dart';
import '../models/message.dart';
import 'message_service.dart';

class CertificateService {
  CertificateService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  static final List<MedicalCertificate> _inMemoryCertificates = [
    MedicalCertificate(
      id: 'cert-001',
      certificateNumber: 'CERT-2026-00412',
      type: 'SICK_LEAVE',
      patientId: 'pat-001',
      patientName: 'Kala Pham',
      doctorId: 'doc-001',
      doctorName: 'Dr. Amadou Ouédraogo (Cardiologue)',
      tenantId: 'ten-001',
      hospitalName: 'CHU Yalgado Ouédraogo',
      diagnosisOrReason: 'Syndrome viral fébrile aigu avec asthénie majeure nécessitant repos strict.',
      restDurationDays: 4,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      employerOrInstitution: 'Direction Générale des Ressources Humaines',
      allowPhysicalActivities: false,
      status: 'ISSUED',
      digitalSealHash: 'SHA256:4a8b29c1e7f6032d1845bb09f12c8a90d4e3f21b79e8d47b192c3d4e5f6a7b8c',
      verificationUrl: 'https://medscan-sluw.onrender.com/medscan/api/v1/certificates/verify?code=CERT-2026-00412',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MedicalCertificate(
      id: 'cert-002',
      certificateNumber: 'CERT-2026-00288',
      type: 'FITNESS_CERTIFICATE',
      patientId: 'pat-001',
      patientName: 'Kala Pham',
      doctorId: 'doc-002',
      doctorName: 'Dr. Fatimata Sawadogo (Médecin Généraliste)',
      tenantId: 'ten-002',
      hospitalName: 'Clinique Internationale Philadelphie',
      diagnosisOrReason: 'Examen clinique cardiorespiratoire normal. Apte aux épreuves physiques et activités sportives.',
      restDurationDays: 0,
      startDate: DateTime.now().subtract(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 350)),
      employerOrInstitution: 'Fédération Nationale de Sport',
      allowPhysicalActivities: true,
      status: 'ISSUED',
      digitalSealHash: 'SHA256:91ef20a845cd1203e87bb1246193e1f0a459b76c82301938fe71024bd7a93012',
      verificationUrl: 'https://medscan-sluw.onrender.com/medscan/api/v1/certificates/verify?code=CERT-2026-00288',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  // Récupérer les certificats médicaux (filtrés selon patient ou médecin émetteur)
  Future<List<MedicalCertificate>> getCertificates({
    String? patientId,
    String? doctorId,
    bool isDoctor = false,
  }) async {
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

    final cert = MedicalCertificate.fromJson({
      'id': 'cert-${now.millisecondsSinceEpoch}',
      'certificateNumber': 'CERT-2026-${now.millisecondsSinceEpoch.toString().substring(7)}',
      'type': data['type'] ?? 'SICK_LEAVE',
      'patientId': data['patientId'] ?? 'pat-001',
      'patientName': data['patientName'] ?? 'Kala Pham',
      'doctorId': data['doctorId'] ?? 'doc-001',
      'doctorName': data['doctorName'] ?? 'Dr. Amadou Ouédraogo',
      'tenantId': data['tenantId'] ?? 'ten-001',
      'hospitalName': data['hospitalName'] ?? 'CHU Yalgado Ouédraogo',
      'diagnosisOrReason': data['diagnosisOrReason'] ?? 'Repos médical strict requis suite à consultation.',
      'restDurationDays': duration,
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
      'employerOrInstitution': data['employerOrInstitution'] ?? 'Direction des Ressources Humaines',
      'allowPhysicalActivities': data['allowPhysicalActivities'] ?? false,
      'status': 'ISSUED',
      'digitalSealHash': 'SHA256:7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069',
      'verificationUrl': 'https://medscan-sluw.onrender.com/medscan/api/v1/certificates/verify?code=CERT-2026-${now.millisecondsSinceEpoch.toString().substring(7)}',
      'createdAt': now.toIso8601String(),
    });

    _inMemoryCertificates.insert(0, cert);
    _dispatchPatientNotification(cert);

    return cert;
  }

  void _dispatchPatientNotification(MedicalCertificate cert) {
    MessageService.addAlert(
      ClinicalAlert(
        id: 'alt-cert-${cert.id}',
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
