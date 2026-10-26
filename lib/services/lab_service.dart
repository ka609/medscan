import '../core/network/api_client.dart';
import '../core/utils/id_generator.dart';
import '../models/lab_order.dart';
import '../models/message.dart';
import 'message_service.dart';

class LabService {
  LabService({ApiClient? apiClient, MessageService? messageService})
      : _apiClient = apiClient ?? ApiClient.instance,
        _messageService = messageService ?? MessageService() {
    _ensureInitialized();
  }

  final ApiClient _apiClient;
  final MessageService _messageService;

  static final List<LabOrder> _inMemoryOrders = [];
  static bool _seeded = false;

  static void _ensureInitialized() {
    if (_seeded) return;
    _seeded = true;

    final docId = IdGenerator.doctorId();
    final patientId = IdGenerator.patientId();
    final tenantId = IdGenerator.tenantId();
    final labTechId = IdGenerator.generate('usr');

    _inMemoryOrders.addAll([
      LabOrder(
        id: IdGenerator.generate('ord'),
        orderCode: 'LAB-2026-0042',
        tenantId: tenantId,
        patientId: patientId,
        patientName: 'Fatou Ouédraogo',
        prescriberId: docId,
        prescriberName: 'Dr. Seydou Traoré',
        technicianId: labTechId,
        technicianName: 'Tech. Ousmane Sanou',
        testCategory: 'PARASITOLOGY',
        testName: 'Goutte Épaisse & Test Rapide Paludisme (TDR)',
        priority: 'URGENT',
        status: 'VALIDATED',
        clinicalIndication: 'Syndrome fébrile aigu avec frissons et céphalées',
        sampleCollectedAt: DateTime.now().subtract(const Duration(days: 1)),
        validatedAt: DateTime.now().subtract(const Duration(hours: 18)),
        isCriticalAlert: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        results: const [
          LabResultItem(
            testCode: 'PLASMODIUM_FALCIPARUM',
            testName: 'Goutte Épaisse',
            valueText: 'POSITIF (Présence de trophozoïtes)',
            isAbnormal: true,
            isCritical: true,
            interpretation: 'Paludisme à Plasmodium falciparum confirmé',
          ),
          LabResultItem(
            testCode: 'PARASITE_DENSITY',
            testName: 'Densité parasitaire',
            valueNumeric: 12500,
            unit: 'trophozoïtes/µL',
            isAbnormal: true,
            interpretation: 'Charge parasitaire modérée',
          ),
          LabResultItem(
            testCode: 'HEMOGLOBIN',
            testName: 'Taux d\'hémoglobine',
            valueNumeric: 11.4,
            unit: 'g/dL',
            referenceLow: 12.0,
            referenceHigh: 16.0,
            isAbnormal: true,
            interpretation: 'Légère anémie réactionnelle',
          ),
        ],
      ),
      LabOrder(
        id: IdGenerator.generate('ord'),
        orderCode: 'LAB-2026-0043',
        tenantId: tenantId,
        patientId: patientId,
        patientName: 'Fatou Ouédraogo',
        prescriberId: docId,
        prescriberName: 'Dr. Seydou Traoré',
        technicianId: labTechId,
        technicianName: 'Tech. Ousmane Sanou',
        testCategory: 'BIOCHEMISTRY',
        testName: 'Glycémie à jeun & Ionogramme complet',
        priority: 'ROUTINE',
        status: 'IN_PROGRESS',
        clinicalIndication: 'Bilan de surveillance métabolique régulier',
        sampleCollectedAt: DateTime.now().subtract(const Duration(hours: 3)),
        validatedAt: null,
        isCriticalAlert: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        results: const [
          LabResultItem(
            testCode: 'FASTING_GLUCOSE',
            testName: 'Glycémie à jeun',
            valueNumeric: 1.05,
            unit: 'g/L',
            referenceLow: 0.70,
            referenceHigh: 1.10,
            isAbnormal: false,
            interpretation: 'Normoglycémie',
          ),
          LabResultItem(
            testCode: 'CREATININE',
            testName: 'Créatininémie',
            valueNumeric: 9.5,
            unit: 'mg/L',
            referenceLow: 7.0,
            referenceHigh: 12.0,
            isAbnormal: false,
            interpretation: 'Fonction rénale normale',
          ),
        ],
      ),
    ]);
  }

  /// Récupération des analyses biologiques (avec fallback en mémoire)
  Future<List<LabOrder>> getOrders({
    String? patientId,
    String? prescriberId,
    String? status,
  }) async {
    _ensureInitialized();
    try {
      final endpoint = patientId != null
          ? '/v1/lab/orders?patientId=$patientId'
          : '/v1/lab/orders';
      final response = await _apiClient.get(endpoint);

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => LabOrder.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Fallback mémoire
    }

    return _inMemoryOrders.where((o) {
      if (patientId != null && patientId.isNotEmpty && o.patientId != patientId) {
        return false;
      }
      if (prescriberId != null && prescriberId.isNotEmpty && o.prescriberId != prescriberId) {
        return false;
      }
      if (status != null && status.isNotEmpty && o.status != status) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Validation et saisie des résultats par le laborantin
  Future<LabOrder> validateResults({
    required String orderId,
    required List<LabResultItem> results,
    required String technicianId,
    required String technicianName,
    bool isCritical = false,
  }) async {
    _ensureInitialized();
    try {
      final response = await _apiClient.post(
        '/v1/lab/orders/$orderId/validate',
        data: {
          'technicianId': technicianId,
          'technicianName': technicianName,
          'isCritical': isCritical,
          'results': results.map((r) => r.toJson()).toList(),
        },
      );
      if (response.data is Map) {
        final validated = LabOrder.fromJson(Map<String, dynamic>.from(response.data as Map));
        final index = _inMemoryOrders.indexWhere((o) => o.id == orderId || o.orderCode == orderId);
        if (index >= 0) {
          _inMemoryOrders[index] = validated;
        } else {
          _inMemoryOrders.add(validated);
        }
        return validated;
      }
    } catch (_) {
      // Fallback local
    }

    final index = _inMemoryOrders.indexWhere((o) => o.id == orderId || o.orderCode == orderId);
    if (index >= 0) {
      final existing = _inMemoryOrders[index];
      final updated = existing.copyWith(
        status: 'VALIDATED',
        validatedAt: DateTime.now(),
        technicianId: technicianId,
        technicianName: technicianName,
        results: results,
        isCriticalAlert: isCritical,
      );
      _inMemoryOrders[index] = updated;
      return updated;
    }

    throw Exception('Dossier d\'analyse introuvable : $orderId');
  }

  /// Déclencher l'envoi officiel des résultats depuis l'application vers le Docteur et le Patient
  Future<void> dispatchResultsToDoctorAndPatient(LabOrder order) async {
    _ensureInitialized();

    // 1. Notification & Message pour le médecin traitant
    if (order.prescriberId.isNotEmpty) {
      MessageService.addAlert(
        ClinicalAlert(
          id: IdGenerator.alertId(),
          recipientUserId: order.prescriberId,
          title: order.isCriticalAlert
              ? 'Alerte Biologique Critique : ${order.testName}'
              : 'Résultats Labo Disponibles : ${order.testName}',
          message:
              'Les analyses de ${order.patientName} sont validées. Consulter le compte-rendu biologique (${order.orderCode}).',
          type: 'LAB_CRITICAL',
          severity: order.isCriticalAlert ? 'CRITICAL' : 'INFO',
          timestamp: DateTime.now(),
          actionRoute: '/medical-record',
        ),
      );

      await _messageService.sendMessage({
        'senderId': order.technicianId ?? IdGenerator.generate('usr'),
        'senderName': order.technicianName ?? 'Laboratoire d\'analyses',
        'senderRole': 'LAB_TECH',
        'recipientId': order.prescriberId,
        'recipientName': order.prescriberName,
        'recipientRole': 'DOCTOR',
        'patientId': order.patientId,
        'subject': 'Résultats d\'analyse : ${order.testName} (${order.orderCode})',
        'content':
            'Bonjour Docteur, nous vous transmettons les résultats d\'analyses validés pour votre patient(e) ${order.patientName}. '
            'Réf dossier : ${order.orderCode}. Statut : ${order.isCriticalAlert ? 'URGENT - Valeurs critiques détectées.' : 'Conforme.'}',
        'priority': order.isCriticalAlert ? 'URGENT' : 'ROUTINE',
      });
    }

    // 2. Notification & Message pour le patient
    if (order.patientId.isNotEmpty) {
      MessageService.addAlert(
        ClinicalAlert(
          id: IdGenerator.alertId(),
          recipientUserId: order.patientId,
          title: 'Résultats de Laboratoire Disponibles : ${order.testName}',
          message:
              'Vos résultats d\'analyses (${order.testName}) ont été validés et transmis à votre médecin.',
          type: 'LAB_RESULT',
          severity: 'INFO',
          timestamp: DateTime.now(),
          actionRoute: '/medical-record',
        ),
      );

      await _messageService.sendMessage({
        'senderId': order.technicianId ?? IdGenerator.generate('usr'),
        'senderName': order.technicianName ?? 'Laboratoire d\'analyses',
        'senderRole': 'LAB_TECH',
        'recipientId': order.patientId,
        'recipientName': order.patientName,
        'recipientRole': 'PATIENT',
        'patientId': order.patientId,
        'subject': 'Vos résultats d\'analyses : ${order.testName}',
        'content':
            'Bonjour ${order.patientName}, vos résultats d\'analyses biologiques (${order.testName}) sont prêts et disponibles dans votre e-Carnet. '
            'Votre médecin traitant en a été automatiquement notifié.',
        'priority': 'ROUTINE',
      });
    }
  }

  /// Fixer un rendez-vous d'analyse pour un patient
  Future<void> bookLabAppointment({
    required String patientId,
    required String patientName,
    required String testName,
    required DateTime date,
    required String slot,
  }) async {
    _ensureInitialized();

    final newOrder = LabOrder(
      id: IdGenerator.generate('ord'),
      orderCode: 'LAB-2026-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
      tenantId: IdGenerator.tenantId(),
      patientId: patientId,
      patientName: patientName,
      prescriberId: '',
      prescriberName: 'Laboratoire Central',
      testCategory: 'SAMPLE_COLLECTION',
      testName: testName,
      priority: 'ROUTINE',
      status: 'PENDING',
      sampleCollectedAt: date,
      results: const [],
      createdAt: DateTime.now(),
    );
    _inMemoryOrders.insert(0, newOrder);

    // Notifier le patient du créneau fixé
    MessageService.addAlert(
      ClinicalAlert(
        id: IdGenerator.alertId(),
        recipientUserId: patientId,
        title: 'Rendez-vous de prélèvement fixé',
        message:
            'Votre rendez-vous pour votre analyse ($testName) est programmé le ${date.day}/${date.month}/${date.year} à $slot au laboratoire central.',
        type: 'APPOINTMENT',
        severity: 'INFO',
        timestamp: DateTime.now(),
        actionRoute: '/appointments',
      ),
    );
  }
}
