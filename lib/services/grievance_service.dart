import '../core/network/api_client.dart';
import '../core/utils/id_generator.dart';
import '../models/grievance.dart';

class GrievanceService {
  GrievanceService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance {
    _ensureInitialized();
  }

  final ApiClient _apiClient;

  static final List<PatientGrievance> _inMemoryGrievances = [];
  static bool _seeded = false;

  static void _ensureInitialized() {
    if (_seeded) return;
    _seeded = true;

    final patientId = IdGenerator.patientId();
    final doc1Id = IdGenerator.doctorId();
    final doc2Id = IdGenerator.doctorId();
    final tenantId = IdGenerator.tenantId();

    _inMemoryGrievances.addAll([
      PatientGrievance(
        id: IdGenerator.grievanceId(),
        grievanceCode: 'REC-${DateTime.now().year}-0012',
        patientId: patientId,
        patientName: 'Patient Suivi',
        patientPhone: '+226 70 12 34 56',
        doctorId: doc1Id,
        doctorName: 'Dr. Fatimata Sawadogo',
        tenantId: tenantId,
        hospitalName: 'CHU Yalgado Ouédraogo',
        grievanceType: 'FEEDBACK',
        category: 'CARE_QUALITY',
        rating: 5,
        severity: 'LOW',
        title: 'Excellente prise en charge en cardiologie',
        description: 'Praticien très à l\'écoute, explications claires sur la posologie et respect parfait des horaires de consultation.',
        status: 'RESOLVED',
        adminNotes: 'Avis positif transmis pour valorisation du praticien.',
        adminActionTaken: 'Transmission au registre de valorisation.',
        reviewedByAdminName: 'Direction Médicale',
        reviewedAt: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      PatientGrievance(
        id: IdGenerator.grievanceId(),
        grievanceCode: 'REC-${DateTime.now().year}-0019',
        patientId: patientId,
        patientName: 'Patient Suivi',
        patientPhone: '+226 70 12 34 56',
        doctorId: doc2Id,
        doctorName: 'Dr. Ibrahim Traoré',
        tenantId: tenantId,
        hospitalName: 'CHU Yalgado Ouédraogo',
        grievanceType: 'COMPLAINT',
        category: 'DELAY_WAIT_TIME',
        rating: 2,
        severity: 'MEDIUM',
        title: 'Délai d\'attente en salle avant consultation',
        description: 'Plus d\'une heure d\'attente avant d\'être reçu malgré la réservation confirmée.',
        status: 'UNDER_REVIEW',
        adminNotes: 'Régulation en cours avec le bureau des admissions.',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
    ]);
  }

  Future<List<PatientGrievance>> getGrievances({String? patientId}) async {
    _ensureInitialized();
    try {
      final endpoint = patientId != null
          ? '/v1/grievances?patientId=$patientId'
          : '/v1/grievances';
      final response = await _apiClient.get(endpoint);

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => PatientGrievance.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Fallback gracieux
    }

    if (patientId != null && patientId.isNotEmpty) {
      return _inMemoryGrievances.where((g) => g.patientId == patientId).toList();
    }
    return List<PatientGrievance>.from(_inMemoryGrievances);
  }

  Future<PatientGrievance> submitGrievance(Map<String, dynamic> data) async {
    _ensureInitialized();
    try {
      final response = await _apiClient.post('/v1/grievances', data: data);
      if (response.data is Map) {
        final serverGrievance = PatientGrievance.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        _inMemoryGrievances.insert(0, serverGrievance);
        return serverGrievance;
      }
    } catch (_) {
      // Fallback local
    }

    final newGrievance = PatientGrievance.fromJson({
      'id': IdGenerator.grievanceId(),
      'grievanceCode': 'REC-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      'patientId': data['patientId'] ?? IdGenerator.patientId(),
      'patientName': data['patientName'] ?? 'Patient',
      'patientPhone': data['patientPhone'] ?? '+226 70 00 00 00',
      'doctorId': data['doctorId'] ?? IdGenerator.doctorId(),
      'doctorName': data['doctorName'] ?? 'Dr. Praticien',
      'tenantId': data['tenantId'] ?? IdGenerator.tenantId(),
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

    _inMemoryGrievances.insert(0, newGrievance);
    return newGrievance;
  }
}
