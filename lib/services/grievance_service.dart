import '../core/network/api_client.dart';
import '../models/grievance.dart';

class GrievanceService {
  GrievanceService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<List<PatientGrievance>> getGrievances({String? tenantId}) async {
    try {
      final endpoint = tenantId != null
          ? '/v1/grievances?tenantId=$tenantId'
          : '/v1/grievances';
      final response = await _apiClient.get(endpoint);

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => PatientGrievance.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    return _getDemoGrievances();
  }

  Future<PatientGrievance> submitGrievance(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/v1/grievances', data: data);
      if (response.data is Map) {
        return PatientGrievance.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (_) {
      // Fallback
    }

    return PatientGrievance.fromJson({
      'id': 'grv-${DateTime.now().millisecondsSinceEpoch}',
      'grievanceCode': 'REC-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'patientId': data['patientId'] ?? 'pat-001',
      'patientName': data['patientName'] ?? 'Kaboré Souleymane',
      'patientPhone': data['patientPhone'] ?? '+226 70 00 00 00',
      'doctorId': data['doctorId'] ?? 'doc-001',
      'doctorName': data['doctorName'] ?? 'Dr. Amadou Ouédraogo',
      'tenantId': data['tenantId'] ?? 'ten-001',
      'hospitalName': data['hospitalName'] ?? 'CHU Yalgado Ouédraogo',
      'consultationId': data['consultationId'],
      'grievanceType': data['grievanceType'] ?? 'COMPLAINT',
      'category': data['category'] ?? 'CARE_QUALITY',
      'rating': data['rating'] ?? 4,
      'severity': data['severity'] ?? 'MEDIUM',
      'title': data['title'] ?? 'Avis sur la prise en charge',
      'description': data['description'] ?? '',
      'status': 'SUBMITTED',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  List<PatientGrievance> _getDemoGrievances() {
    return [
      PatientGrievance(
        id: 'grv-001',
        grievanceCode: 'REC-2026-0012',
        patientId: 'pat-001',
        patientName: 'Kaboré Souleymane',
        patientPhone: '+226 70 12 34 56',
        doctorId: 'doc-002',
        doctorName: 'Dr. Fatimata Sawadogo',
        tenantId: 'ten-001',
        hospitalName: 'CHU Yalgado Ouédraogo',
        grievanceType: 'FEEDBACK',
        category: 'CARE_QUALITY',
        rating: 5,
        severity: 'LOW',
        title: 'Excellente prise en charge en cardiologie',
        description: 'Médecin très à l\'écoute, explications claires sur la posologie et respect parfait des horaires de consultation.',
        status: 'RESOLVED',
        adminNotes: 'Avis positif transmis au chef de service pour félicitations au praticien.',
        adminActionTaken: 'Transmission au registre de valorisation de l\'équipe médicale.',
        reviewedByAdminName: 'Directeur Général de l\'Hôpital',
        reviewedAt: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      PatientGrievance(
        id: 'grv-002',
        grievanceCode: 'REC-2026-0019',
        patientId: 'pat-001',
        patientName: 'Kaboré Souleymane',
        patientPhone: '+226 70 12 34 56',
        doctorId: 'doc-005',
        doctorName: 'Dr. Ibrahim Traoré',
        tenantId: 'ten-001',
        hospitalName: 'CHU Yalgado Ouédraogo',
        grievanceType: 'COMPLAINT',
        category: 'DELAY_WAIT_TIME',
        rating: 2,
        severity: 'MEDIUM',
        title: 'Attente de plus de 2 heures sans information au guichet',
        description: 'Rendez-vous fixé à 09h00, passage effectif à 11h15 sans explication de l\'accueil sur le retard.',
        status: 'UNDER_REVIEW',
        adminNotes: 'Instruction en cours auprès du secrétariat médical pour révision du cadencement des flux.',
        adminActionTaken: 'Sensibilisation de l\'équipe d\'accueil à la communication préventive.',
        reviewedByAdminName: 'Directeur Qualité & Relation Usagers',
        reviewedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
