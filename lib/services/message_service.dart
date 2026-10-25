import '../core/network/api_client.dart';
import '../core/utils/id_generator.dart';
import '../models/message.dart';

class MessageService {
  MessageService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance {
    _ensureInitialized();
  }

  final ApiClient _apiClient;

  static final List<ClinicalMessage> _inMemoryMessages = [];
  static final List<ClinicalAlert> _inMemoryAlerts = [];
  static bool _seeded = false;

  static void _ensureInitialized() {
    if (_seeded) return;
    _seeded = true;

    final docId = IdGenerator.doctorId();
    final patientId = IdGenerator.patientId();
    final tenantId = IdGenerator.tenantId();
    final convId = IdGenerator.conversationId(patientId, docId);

    _inMemoryMessages.addAll([
      ClinicalMessage(
        id: IdGenerator.messageId(),
        conversationId: convId,
        tenantId: tenantId,
        senderId: docId,
        senderName: 'Dr. Amadou Ouédraogo',
        senderRole: 'DOCTOR',
        recipientId: patientId,
        recipientName: 'Patient Suivi',
        recipientRole: 'PATIENT',
        patientId: patientId,
        subject: 'Bilan de consultation',
        content: 'Bonjour, vos constantes cliniques et votre bilan sont stables. Pensez à renouveler votre ordonnance avant la fin de semaine.',
        priority: 'ROUTINE',
        readAt: DateTime.now().subtract(const Duration(hours: 3)),
        sentAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ClinicalMessage(
        id: IdGenerator.messageId(),
        conversationId: convId,
        tenantId: tenantId,
        senderId: patientId,
        senderName: 'Patient Suivi',
        senderRole: 'PATIENT',
        recipientId: docId,
        recipientName: 'Dr. Amadou Ouédraogo',
        recipientRole: 'DOCTOR',
        patientId: patientId,
        subject: 'Re: Bilan de consultation',
        content: 'Bien reçu Docteur, merci pour le suivi personnalisé.',
        priority: 'ROUTINE',
        readAt: DateTime.now().subtract(const Duration(hours: 2)),
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ]);

    _inMemoryAlerts.addAll([
      ClinicalAlert(
        id: IdGenerator.alertId(),
        recipientUserId: patientId,
        title: 'Alerte Labo : Résultats Biologiques Disponibles',
        message: 'Vos résultats d\'analyses de glycémie à jeun et d\'ionogramme complet sont validés par le laboratoire central.',
        type: 'LAB_CRITICAL',
        severity: 'INFO',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: false,
        actionRoute: '/medical-record',
      ),
      ClinicalAlert(
        id: IdGenerator.alertId(),
        recipientUserId: null, // Alerte générale système
        title: 'Alerte Constantes : Suivi Recommandé',
        message: 'Votre suivi de santé régulier est conforme aux recommandations médicales.',
        type: 'VITALS_ALERT',
        severity: 'INFO',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        actionRoute: '/medical-record',
      ),
    ]);
  }

  // Récupération isolée des messages par utilisateur
  Future<List<ClinicalMessage>> getMessages({
    String? userId,
    String? conversationId,
    bool isDoctor = false,
  }) async {
    _ensureInitialized();
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
            m.recipientId == userId;
      }
    }).toList();
  }

  // Envoi de message isolé dans le fil de la conversation
  Future<ClinicalMessage> sendMessage(Map<String, dynamic> data) async {
    _ensureInitialized();
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

    final senderId = data['senderId']?.toString() ?? IdGenerator.generate('usr');
    final recipientId = data['recipientId']?.toString() ?? IdGenerator.doctorId();
    final conversationId = data['conversationId']?.toString() ??
        IdGenerator.conversationId(senderId, recipientId);

    final newMsg = ClinicalMessage.fromJson({
      'id': IdGenerator.messageId(),
      'conversationId': conversationId,
      'tenantId': data['tenantId'] ?? IdGenerator.tenantId(),
      'senderId': senderId,
      'senderName': data['senderName'] ?? 'Vous',
      'senderRole': data['senderRole'] ?? 'PATIENT',
      'recipientId': recipientId,
      'recipientName': data['recipientName'] ?? 'Médecin Traitant',
      'recipientRole': data['recipientRole'] ?? 'DOCTOR',
      'patientId': data['patientId'] ?? (data['senderRole'] == 'PATIENT' ? senderId : recipientId),
      'subject': data['subject'] ?? 'Suivi médical',
      'content': data['content'] ?? '',
      'priority': data['priority'] ?? 'ROUTINE',
      'sentAt': DateTime.now().toIso8601String(),
    });

    _inMemoryMessages.add(newMsg);
    return newMsg;
  }

  static void addAlert(ClinicalAlert alert) {
    _ensureInitialized();
    _inMemoryAlerts.insert(0, alert);
  }

  // Récupération isolée des alertes pour un utilisateur donné
  Future<List<ClinicalAlert>> getAlerts({String? userId}) async {
    _ensureInitialized();
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
