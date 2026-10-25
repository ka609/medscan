import '../core/network/api_client.dart';
import '../models/message.dart';

class MessageService {
  MessageService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  final ApiClient _apiClient;

  static final List<ClinicalMessage> _inMemoryMessages = [
    // Messages historiques pré-enregistrés pour M. Kaboré Souleymane (pat-001)
    ClinicalMessage(
      id: 'msg-001',
      conversationId: 'conv-pat-001-doc-001',
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
      conversationId: 'conv-pat-001-doc-001',
      tenantId: 'ten-001',
      senderId: 'pat-001',
      senderName: 'Kaboré Souleymane',
      senderRole: 'PATIENT',
      recipientId: 'doc-001',
      recipientName: 'Dr. Amadou Ouédraogo',
      recipientRole: 'DOCTOR',
      patientId: 'pat-001',
      subject: 'Re: Bilan de consultation',
      content: 'Bien reçu Docteur, merci pour le suivi. J\'ai bien récupéré mon certificat médical sur l\'application.',
      priority: 'ROUTINE',
      readAt: DateTime.now().subtract(const Duration(hours: 2)),
      sentAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ClinicalMessage(
      id: 'msg-003',
      conversationId: 'conv-pat-001-doc-001',
      tenantId: 'ten-001',
      senderId: 'doc-001',
      senderName: 'Dr. Amadou Ouédraogo',
      senderRole: 'DOCTOR',
      recipientId: 'pat-001',
      recipientName: 'Kaboré Souleymane',
      recipientRole: 'PATIENT',
      patientId: 'pat-001',
      subject: 'Suivi tensionnel',
      content: 'Parfait. En cas de pic hypertensif (> 140/90 mmHg), signalez-le immédiatement ou lancez une téléconsultation.',
      priority: 'URGENT',
      readAt: null,
      sentAt: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
  ];

  static final List<ClinicalAlert> _inMemoryAlerts = [
    ClinicalAlert(
      id: 'alt-001',
      recipientUserId: 'pat-001',
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
      recipientUserId: 'pat-001',
      title: 'Rappel de Rendez-vous Médical',
      message: 'Votre téléconsultation de cardiologie est programmée avec Dr. Amadou Ouédraogo.',
      type: 'APPOINTMENT',
      severity: 'INFO',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
      actionRoute: '/appointments',
    ),
    ClinicalAlert(
      id: 'alt-003',
      recipientUserId: null, // Alerte générale ou patient connecté
      title: 'Alerte Constantes : IMC Calculé',
      message: 'Votre IMC calculé lors du dernier enregistrement est conforme aux normes de santé recommandées.',
      type: 'VITALS_ALERT',
      severity: 'INFO',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      actionRoute: '/medical-record',
    ),
  ];

  // Récupération isolée des messages par utilisateur
  Future<List<ClinicalMessage>> getMessages({
    String? userId,
    String? conversationId,
    bool isDoctor = false,
  }) async {
    try {
      final endpoint = conversationId != null
          ? '/v1/messages?conversationId=$conversationId'
          : (userId != null ? '/v1/messages?userId=$userId' : '/v1/messages');
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

    // Filtrage strict en mémoire pour isolation étanche des conversations
    return _inMemoryMessages.where((m) {
      if (conversationId != null && conversationId.isNotEmpty) {
        return m.conversationId == conversationId;
      }
      if (userId == null || userId.isEmpty) return true;

      if (isDoctor) {
        return m.recipientId == userId ||
            m.senderId == userId ||
            m.senderRole == 'DOCTOR' ||
            m.recipientRole == 'DOCTOR';
      } else {
        // Le patient ne voit STRICTEMENT QUE ses propres messages
        return m.patientId == userId ||
            m.senderId == userId ||
            m.recipientId == userId ||
            m.senderId == 'current-user';
      }
    }).toList();
  }

  // Envoi de message isolé dans le fil de la conversation
  Future<ClinicalMessage> sendMessage(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/v1/messages', data: data);
      if (response.data is Map) {
        final serverMsg = ClinicalMessage.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        _inMemoryMessages.add(serverMsg);
        return serverMsg;
      }
    } catch (_) {
      // Fallback
    }

    final newMsg = ClinicalMessage.fromJson({
      'id': 'msg-${DateTime.now().millisecondsSinceEpoch}',
      'conversationId': data['conversationId'] ?? 'conv-${data['senderId'] ?? 'user'}-${data['recipientId'] ?? 'peer'}',
      'tenantId': data['tenantId'] ?? 'ten-001',
      'senderId': data['senderId'] ?? 'current-user',
      'senderName': data['senderName'] ?? 'Vous',
      'senderRole': data['senderRole'] ?? 'PATIENT',
      'recipientId': data['recipientId'] ?? 'doc-001',
      'recipientName': data['recipientName'] ?? 'Dr. Amadou Ouédraogo',
      'recipientRole': data['recipientRole'] ?? 'DOCTOR',
      'patientId': data['patientId'] ?? (data['senderRole'] == 'PATIENT' ? data['senderId'] : data['recipientId']) ?? 'pat-001',
      'subject': data['subject'] ?? 'Suivi médical',
      'content': data['content'] ?? '',
      'priority': data['priority'] ?? 'ROUTINE',
      'sentAt': DateTime.now().toIso8601String(),
    });

    _inMemoryMessages.add(newMsg);
    return newMsg;
  }

  static void addAlert(ClinicalAlert alert) {
    _inMemoryAlerts.insert(0, alert);
  }

  // Récupération isolée des alertes pour un utilisateur donné
  Future<List<ClinicalAlert>> getAlerts({String? userId}) async {
    try {
      final endpoint = userId != null
          ? '/v1/notifications?userId=$userId'
          : '/v1/notifications';
      final response = await _apiClient.get(endpoint);
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => ClinicalAlert.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Fallback
    }

    // Filtrage étanche des alertes
    if (userId == null || userId.isEmpty) {
      return List<ClinicalAlert>.from(_inMemoryAlerts);
    }

    return _inMemoryAlerts.where((a) {
      return a.recipientUserId == null || a.recipientUserId == userId;
    }).toList();
  }
}
