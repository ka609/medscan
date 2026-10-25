import '../core/network/api_client.dart';
import '../core/utils/id_generator.dart';
import '../models/referral.dart';

class ReferralService {
  ReferralService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance {
    _ensureInitialized();
  }

  final ApiClient _apiClient;

  static final List<MedicalReferral> _inMemoryReferrals = [];
  static bool _seeded = false;

  static void _ensureInitialized() {
    if (_seeded) return;
    _seeded = true;

    final docId = IdGenerator.doctorId();
    final patientId = IdGenerator.patientId();
    final sourceTenantId = IdGenerator.tenantId();
    final targetTenantId = IdGenerator.tenantId();

    _inMemoryReferrals.addAll([
      MedicalReferral(
        id: IdGenerator.referralId(),
        referralCode: 'REF-${DateTime.now().year}-0891',
        patientId: patientId,
        patientName: 'Patient Suivi',
        referringDoctorId: docId,
        referringDoctorName: 'Dr. Amadou Ouédraogo',
        sourceTenantId: sourceTenantId,
        sourceTenantName: 'CHU Yalgado Ouédraogo (Médecine Interne)',
        targetTenantId: targetTenantId,
        targetTenantName: 'Centre Hospitalier National',
        targetService: 'Service de Chirurgie Cardiovasculaire',
        requiredSpeciality: 'Chirurgien Cardiaque',
        clinicalReason: 'Bilan pré-opératoire et prise en charge d\'un rétrécissement aortique sévère.',
        medicalSummary: 'Échographie révélant un gradient moyen élevé justifiant orientation chirurgicale.',
        priority: 'URGENT',
        status: 'ACCEPTED',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MedicalReferral(
        id: IdGenerator.referralId(),
        referralCode: 'REF-${DateTime.now().year}-0432',
        patientId: patientId,
        patientName: 'Patient Suivi',
        referringDoctorId: IdGenerator.doctorId(),
        referringDoctorName: 'Dr. Fatimata Sawadogo',
        sourceTenantId: IdGenerator.tenantId(),
        sourceTenantName: 'Clinique Spécialisée',
        targetTenantId: sourceTenantId,
        targetTenantName: 'CHU Yalgado Ouédraogo',
        targetService: 'Service d\'Imagerie par Résonance Magnétique (IRM)',
        requiredSpeciality: 'Radiologue',
        clinicalReason: 'Exploration d\'une lomboradiculalgie résistante aux antalgiques habituels.',
        medicalSummary: 'Examen clinique sans déficit moteur. Imagerie IRM complémentaire requise.',
        priority: 'ROUTINE',
        status: 'PENDING',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
  }

  Future<List<MedicalReferral>> getReferrals({String? patientId}) async {
    _ensureInitialized();
    try {
      final endpoint = patientId != null
          ? '/v1/referrals?patientId=$patientId'
          : '/v1/referrals';
      final response = await _apiClient.get(endpoint);

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => MedicalReferral.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Fallback gracieux
    }

    if (patientId != null && patientId.isNotEmpty) {
      return _inMemoryReferrals.where((r) => r.patientId == patientId).toList();
    }
    return List<MedicalReferral>.from(_inMemoryReferrals);
  }

  Future<MedicalReferral> createReferral(Map<String, dynamic> data) async {
    _ensureInitialized();
    try {
      final response = await _apiClient.post('/v1/referrals', data: data);
      if (response.data is Map) {
        final serverRef = MedicalReferral.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        _inMemoryReferrals.insert(0, serverRef);
        return serverRef;
      }
    } catch (_) {
      // Fallback local
    }

    final newRef = MedicalReferral.fromJson({
      'id': IdGenerator.referralId(),
      'referralCode': 'REF-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'patientId': data['patientId'] ?? IdGenerator.patientId(),
      'patientName': data['patientName'] ?? 'Patient',
      'referringDoctorId': data['referringDoctorId'] ?? IdGenerator.doctorId(),
      'referringDoctorName': data['referringDoctorName'] ?? 'Dr. Praticien',
      'sourceTenantId': data['sourceTenantId'] ?? IdGenerator.tenantId(),
      'sourceTenantName': data['sourceTenantName'] ?? 'CHU Yalgado Ouédraogo',
      'targetTenantId': data['targetTenantId'] ?? IdGenerator.tenantId(),
      'targetTenantName': data['targetTenantName'] ?? 'Hôpital Régional Spécialisé',
      'targetService': data['targetService'] ?? 'Cardiologie Interventionnelle',
      'requiredSpeciality': data['requiredSpeciality'] ?? 'Spécialiste',
      'clinicalReason': data['clinicalReason'] ?? 'Orientation médicale spécialisée.',
      'medicalSummary': data['medicalSummary'] ?? 'Dossier transmis pour avis et prise en charge.',
      'priority': data['priority'] ?? 'URGENT',
      'status': 'PENDING',
      'createdAt': DateTime.now().toIso8601String(),
    });

    _inMemoryReferrals.insert(0, newRef);
    return newRef;
  }
}
