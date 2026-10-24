import '../core/network/api_client.dart';
import '../models/message.dart';

class MessageService {
  MessageService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  Future<List<ClinicalMessage>> getMessages({String? conversationId}) async {
    try {
      final endpoint = conversationId != null
          ? '/v1/messages?conversationId=$conversationId'
          : '/v1/messages';
      final response = await _apiClient.get(endpoint);

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => ClinicalMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    return _getDemoMessages();
  }

  Future<ClinicalMessage> sendMessage(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/v1/messages', data: data);
      if (response.data is Map) {
        return ClinicalMessage.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (_) {
      // Fallback
    }

    return ClinicalMessage.fromJson({
      'id': 'msg-${DateTime.now().millisecondsSinceEpoch}',
      'conversationId': data['conversationId'] ?? 'conv-001',
      'tenantId': data['tenantId'] ?? 'ten-001',
      'senderId': data['senderId'] ?? 'current-user',
      'senderName': data['senderName'] ?? 'Vous (Patient)',
      'senderRole': data['senderRole'] ?? 'PATIENT',
      'recipientId': data['recipientId'] ?? 'doc-001',
      'recipientName': data['recipientName'] ?? 'Dr. Amadou Ouédraogo',
      'recipientRole': data['recipientRole'] ?? 'DOCTOR',
      'patientId': data['patientId'] ?? 'pat-001',
      'subject': data['subject'] ?? 'Suivi médical',
      'content': data['content'] ?? '',
      'priority': data['priority'] ?? 'ROUTINE',
      'sentAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<ClinicalAlert>> getAlerts() async {
    try {
      final response = await _apiClient.get('/v1/notifications');
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => ClinicalAlert.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    return _getDemoAlerts();
  }

  List<ClinicalMessage> _getDemoMessages() {
    return [
      ClinicalMessage(
        id: 'msg-001',
        conversationId: 'conv-001',
        tenantId: 'ten-001',
        senderId: 'doc-001',
        senderName: 'Dr. Amadou Ouédraogo',
        senderRole: 'DOCTOR',
        recipientId: 'pat-001',
        recipientName: 'Kaboré Souleymane',
        recipientRole: 'PATIENT',
        patientId: 'pat-001',
        subject: 'Bilan de consultation',
        content: 'Bonjour M. Kaboré, vos constantes et votre IMC calculé sont stables. Pensez à renouveler votre ordonnance de bêta-bloquants avant vendredi.',
        priority: 'ROUTINE',
        readAt: DateTime.now().subtract(const Duration(hours: 3)),
        sentAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ClinicalMessage(
        id: 'msg-002',
        conversationId: 'conv-001',
        tenantId: 'ten-001',
        senderId: 'current-user',
        senderName: 'Vous (Patient)',
        senderRole: 'PATIENT',
        recipientId: 'doc-001',
        recipientName: 'Dr. Amadou Ouédraogo',
        recipientRole: 'DOCTOR',
        patientId: 'pat-001',
        subject: 'Re: Bilan de consultation',
        content: 'Bien reçu Docteur, merci pour le suivi. J\'ai bien récupéré mon certificat d\'arrêt de travail sur l\'application.',
        priority: 'ROUTINE',
        readAt: DateTime.now().subtract(const Duration(hours: 2)),
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ClinicalMessage(
        id: 'msg-003',
        conversationId: 'conv-001',
        tenantId: 'ten-001',
        senderId: 'doc-001',
        senderName: 'Dr. Amadou Ouédraogo',
        senderRole: 'DOCTOR',
        recipientId: 'pat-001',
        recipientName: 'Kaboré Souleymane',
        recipientRole: 'PATIENT',
        patientId: 'pat-001',
        subject: 'Suivi tensionnel',
        content: 'Parfait. En cas de céphalées ou de pic hypertensif (> 140/90 mmHg), signalez-le immédiatement sur l\'application ou lancez une téléconsultation.',
        priority: 'URGENT',
        readAt: null,
        sentAt: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
    ];
  }

  List<ClinicalAlert> _getDemoAlerts() {
    return [
      ClinicalAlert(
        id: 'alt-001',
        title: 'Alerte Labo : Résultats Biologiques Disponibles',
        message: 'Vos résultats d\'analyses de glycémie à jeun et d\'ionogramme complet sont validés par le laboratoire central.',
        type: 'LAB_CRITICAL',
        severity: 'INFO',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: false,
        actionRoute: '/medical-record',
      ),
      ClinicalAlert(
        id: 'alt-002',
        title: 'Rappel de Rendez-vous Médical',
        message: 'Votre téléconsultation de cardiologie est programmée demain à 10:30 avec Dr. Amadou Ouédraogo.',
        type: 'APPOINTMENT',
        severity: 'INFO',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
        actionRoute: '/appointments',
      ),
      ClinicalAlert(
        id: 'alt-003',
        title: 'Alerte Constantes : IMC Calculé',
        message: 'Votre IMC calculé lors du dernier enregistrement est de 24.2 kg/m² (Corpulence normale). Continuer l\'activité physique régulière.',
        type: 'VITALS_ALERT',
        severity: 'INFO',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        actionRoute: '/medical-record',
      ),
    ];
  }
}
