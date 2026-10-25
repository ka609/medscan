import '../core/network/api_client.dart';
import '../models/referral.dart';

class ReferralService {
  ReferralService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<List<MedicalReferral>> getReferrals({String? patientId}) async {
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

    return _getDemoReferrals();
  }

  Future<MedicalReferral> createReferral(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/v1/referrals', data: data);
      if (response.data is Map) {
        return MedicalReferral.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (_) {
      // Fallback local
    }

    return MedicalReferral.fromJson({
      'id': 'ref-${DateTime.now().millisecondsSinceEpoch}',
      'referralCode': 'REF-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'patientId': data['patientId'] ?? 'pat-001',
      'patientName': data['patientName'] ?? 'Kaboré Souleymane',
      'referringDoctorId': data['referringDoctorId'] ?? 'doc-001',
      'referringDoctorName': data['referringDoctorName'] ?? 'Dr. Amadou Ouédraogo',
      'sourceTenantId': data['sourceTenantId'] ?? 'ten-001',
      'sourceTenantName': data['sourceTenantName'] ?? 'CHU Yalgado Ouédraogo',
      'targetTenantId': data['targetTenantId'] ?? 'ten-002',
      'targetTenantName': data['targetTenantName'] ?? 'Hôpital Militaire de Campagne',
      'targetService': data['targetService'] ?? 'Cardiologie Interventionnelle',
      'requiredSpeciality': data['requiredSpeciality'] ?? 'Cardiologue Spécialiste',
      'clinicalReason': data['clinicalReason'] ?? 'Suspicion d\'angor instable, exploration coronarienne urgente requise.',
      'medicalSummary': data['medicalSummary'] ?? 'Patient hypertendu sous trithérapie. Douleurs thoraciques rétrosternales à l\'effort.',
      'priority': data['priority'] ?? 'URGENT',
      'status': 'PENDING',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  List<MedicalReferral> _getDemoReferrals() {
    return [
      MedicalReferral(
        id: 'ref-001',
        referralCode: 'REF-2026-00891',
        patientId: 'pat-001',
        patientName: 'Kaboré Souleymane',
        referringDoctorId: 'doc-001',
        referringDoctorName: 'Dr. Amadou Ouédraogo',
        sourceTenantId: 'ten-001',
        sourceTenantName: 'CHU Yalgado Ouédraogo (Médecine Interne)',
        targetTenantId: 'ten-002',
        targetTenantName: 'Centre Hospitalier National Blaise Compaoré',
        targetService: 'Service de Chirurgie Cardiovasculaire',
        requiredSpeciality: 'Chirurgien Cardiaque',
        clinicalReason: 'Bilan pré-opératoire et prise en charge d\'un rétrécissement aortique sévère calcifié.',
        medicalSummary: 'Échographie transthoracique du 10/10/2026 révélant une Vmax > 4 m/s avec gradient moyen 45 mmHg.',
        priority: 'URGENT',
        status: 'ACCEPTED',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MedicalReferral(
        id: 'ref-002',
        referralCode: 'REF-2026-00432',
        patientId: 'pat-001',
        patientName: 'Kaboré Souleymane',
        referringDoctorId: 'doc-002',
        referringDoctorName: 'Dr. Fatimata Sawadogo',
        sourceTenantId: 'ten-003',
        sourceTenantName: 'Clinique Philadelphie',
        targetTenantId: 'ten-001',
        targetTenantName: 'CHU Yalgado Ouédraogo',
        targetService: 'Service d\'Imagerie par Résonance Magnétique (IRM)',
        requiredSpeciality: 'Radiologue',
        clinicalReason: 'Exploration d\'une lomboradiculalgie L5 hyperalgique résistante aux AINS.',
        medicalSummary: 'Examen neurologique sans déficit moteur. Scanner initial non concluant.',
        priority: 'ROUTINE',
        status: 'PENDING',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}

