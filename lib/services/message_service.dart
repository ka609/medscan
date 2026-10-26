import '../core/network/api_client.dart';
import '../core/utils/id_generator.dart';
import '../models/conversation.dart';
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

  static String? _seedDoctorId;
  static String? _seedPatientId;
  static String? _seedConversationId;

  static String get seedDoctorId {
    _ensureInitialized();
    return _seedDoctorId!;
  }

  static String get seedPatientId {
    _ensureInitialized();
    return _seedPatientId!;
  }

  static String get seedConversationId {
    _ensureInitialized();
    return _seedConversationId!;
  }

  /// Initialise les données factices médicales une seule fois
  static void _ensureInitialized() {
    if (_seeded) return;
    _seeded = true;

    final docId = IdGenerator.doctorId();
    final patientId = IdGenerator.patientId();
    final tenantId = IdGenerator.tenantId();
    final convId = IdGenerator.conversationId(patientId, docId);

    _seedDoctorId = docId;
    _seedPatientId = patientId;
    _seedConversationId = convId;

    _inMemoryMessages.addAll([
      ClinicalMessage(
        id: IdGenerator.messageId(),
        conversationId: convId,
        tenantId: tenantId,
        senderId: docId,
        senderName: 'Dr. Amadou Ouédraogo',
        senderRole: 'DOCTOR',
        recipientId: patientId,
        recipientName: 'Fatou Ouédraogo',
        recipientRole: 'PATIENT',
        patientId: patientId,
        subject: 'Bilan de consultation',
        content:
            'Bonjour Mme Ouédraogo, vos constantes cliniques et votre bilan sont stables. Pensez à renouveler votre traitement avant la fin de semaine.',
        priority: 'ROUTINE',
        readAt: DateTime.now().subtract(const Duration(hours: 3)),
        sentAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ClinicalMessage(
        id: IdGenerator.messageId(),
        conversationId: convId,
        tenantId: tenantId,
        senderId: patientId,
        senderName: 'Fatou Ouédraogo',
        senderRole: 'PATIENT',
        recipientId: docId,
        recipientName: 'Dr. Amadou Ouédraogo',
        recipientRole: 'DOCTOR',
        patientId: patientId,
        subject: 'Re: Bilan de consultation',
        content:
            'Bien reçu Docteur, merci pour le suivi et les recommandations.',
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
        message:
            'Vos résultats d\'analyses de glycémie à jeun et d\'ionogramme complet sont validés par le laboratoire central.',
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
        message:
            'Votre suivi de santé régulier est conforme aux recommandations médicales.',
        type: 'VITALS_ALERT',
        severity: 'INFO',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        actionRoute: '/medical-record',
      ),
    ]);
  }

  /// Réinitialise les messages pour les scénarios de test
  static void resetForTesting() {
    _inMemoryMessages.clear();
    _inMemoryAlerts.clear();
    _seeded = false;
    _seedDoctorId = null;
    _seedPatientId = null;
    _seedConversationId = null;
  }

  // ---------------------------------------------------------------------------
  // Liste des conversations de l'utilisateur (avec résumé & dernier message)
  // ---------------------------------------------------------------------------
  Future<List<Conversation>> getConversations({
    String? userId,
    bool isDoctor = false,
  }) async {
    _ensureInitialized();
    try {
      final endpoint = userId != null && userId.isNotEmpty
          ? '/v1/messages/conversations?userId=$userId'
          : '/v1/messages/conversations';
      final response = await _apiClient.get(endpoint);

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => Conversation.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Ignorer l'erreur réseau et basculer sur le groupement en mémoire
    }

    // Fallback : groupement en mémoire par conversationId
    final Map<String, List<ClinicalMessage>> convMap = {};
    for (final m in _inMemoryMessages) {
      if (userId == null || userId.isEmpty) {
        convMap.putIfAbsent(m.conversationId, () => []).add(m);
      } else if (isDoctor) {
        if (m.recipientId == userId || m.senderId == userId) {
          convMap.putIfAbsent(m.conversationId, () => []).add(m);
        }
      } else {
        if (m.patientId == userId || m.recipientId == userId || m.senderId == userId) {
          convMap.putIfAbsent(m.conversationId, () => []).add(m);
        }
      }
    }

    final List<Conversation> conversations = [];
    for (final entry in convMap.entries) {
      final cId = entry.key;
      final msgs = List<ClinicalMessage>.from(entry.value);
      if (msgs.isEmpty) continue;

      msgs.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      final lastMsg = msgs.last;

      final isMe = (userId != null && userId.isNotEmpty) && (lastMsg.senderId == userId);
      final partnerId = isMe ? lastMsg.recipientId : lastMsg.senderId;
      final partnerName = isMe ? lastMsg.recipientName : lastMsg.senderName;
      final partnerRole = isMe ? lastMsg.recipientRole : lastMsg.senderRole;

      final unreadCount = msgs.where((m) {
        if (userId == null || userId.isEmpty) return false;
        return m.recipientId == userId && m.readAt == null;
      }).length;

      conversations.add(Conversation(
        id: cId,
        participantId: partnerId,
        participantName: partnerName,
        participantRole: partnerRole,
        lastMessage: lastMsg,
        unreadCount: unreadCount,
      ));
    }

    conversations.sort((a, b) {
      final aDate = a.lastMessage?.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.lastMessage?.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return conversations;
  }

  // ---------------------------------------------------------------------------
  // Liste des contacts éligibles pour une nouvelle discussion (Isolation clinique)
  // Seuls les docteurs consultés (pour un patient) ou les patients suivis (pour un docteur)
  // ---------------------------------------------------------------------------
  Future<List<MessagingContact>> getEligibleContacts({
    String? userId,
    bool isDoctor = false,
  }) async {
    _ensureInitialized();
    try {
      final response = await _apiClient.get('/v1/messages/contacts');
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => MessagingContact.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Ignorer l'erreur réseau et basculer sur les contacts déontologiques
    }

    // Fallback : isolation stricte en mémoire
    final List<MessagingContact> contacts = [];
    final Set<String> seenIds = {};

    if (isDoctor) {
      // Le médecin ne peut contacter que les patients qu'il a consultés
      for (final m in _inMemoryMessages) {
        if (userId == null || userId.isEmpty || m.senderId == userId || m.recipientId == userId) {
          final pId = m.patientId;
          final pName = m.senderRole == 'PATIENT' ? m.senderName : m.recipientName;
          if (pId.isNotEmpty && seenIds.add(pId)) {
            contacts.add(MessagingContact(
              id: pId,
              name: pName,
              role: 'PATIENT',
              details: 'Patient suivi / dossier clinique actif',
            ));
          }
        }
      }
      if (contacts.isEmpty) {
        contacts.add(MessagingContact(
          id: _seedPatientId ?? IdGenerator.patientId(),
          name: 'Fatou Ouédraogo',
          role: 'PATIENT',
          details: 'Patiente suivie - CH Ouagadougou',
        ));
      }
    } else {
      // Le patient ne peut contacter que les praticiens avec qui il a eu consultation
      for (final m in _inMemoryMessages) {
        if (userId == null || userId.isEmpty || m.patientId == userId || m.senderId == userId || m.recipientId == userId) {
          final isDocSender = m.senderRole == 'DOCTOR';
          final docId = isDocSender ? m.senderId : m.recipientId;
          final docName = isDocSender ? m.senderName : m.recipientName;
          if (docId.isNotEmpty && seenIds.add(docId)) {
            contacts.add(MessagingContact(
              id: docId,
              name: docName,
              role: 'DOCTOR',
              details: 'Praticien consulté',
            ));
          }
        }
      }
      if (contacts.isEmpty) {
        contacts.add(MessagingContact(
          id: _seedDoctorId ?? IdGenerator.doctorId(),
          name: 'Dr. Amadou Ouédraogo',
          role: 'DOCTOR',
          details: 'Médecin Référent - Médecine Générale',
        ));
        contacts.add(MessagingContact(
          id: IdGenerator.doctorId(),
          name: 'Dr. Seydou Traoré',
          role: 'DOCTOR',
          details: 'Praticien Hospitalier - CH Ouagadougou',
        ));
      }
    }

    return contacts;
  }

  // ---------------------------------------------------------------------------
  // Récupération des messages détaillés (filtrage strict par conversation ou utilisateur)
  // ---------------------------------------------------------------------------
  Future<List<ClinicalMessage>> getMessages({
    String? userId,
    String? conversationId,
    bool isDoctor = false,
  }) async {
    _ensureInitialized();
    try {
      final endpoint = conversationId != null && conversationId.isNotEmpty
          ? '/v1/messages/conversation/$conversationId'
          : (userId != null && userId.isNotEmpty
              ? '/v1/messages?userId=$userId'
              : '/v1/messages');
      final response = await _apiClient.get(endpoint);

      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => ClinicalMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // Ignore errors – fallback to in‑memory data.
    }

    // Fallback : filtrage strict en mémoire
    return _inMemoryMessages.where((m) {
      if (conversationId != null && conversationId.isNotEmpty) {
        return m.conversationId == conversationId;
      }
      if (userId == null || userId.isEmpty) return true;

      if (isDoctor) {
        // Le médecin ne voit que les messages où il est expéditeur ou destinataire
        return m.recipientId == userId || m.senderId == userId;
      } else {
        // Le patient ne voit que ses propres messages
        return m.patientId == userId ||
            m.senderId == userId ||
            m.recipientId == userId;
      }
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Envoi d'un message
  // ---------------------------------------------------------------------------
  Future<ClinicalMessage> sendMessage(Map<String, dynamic> data) async {
    _ensureInitialized();
    try {
      final response = await _apiClient.post('/v1/messages', data: data);
      if (response.data is Map) {
        final serverMsg = ClinicalMessage.fromJson(
            Map<String, dynamic>.from(response.data as Map));
        _inMemoryMessages.add(serverMsg);
        return serverMsg;
      }
    } catch (_) {
      // Fallback local creation
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
      'patientId': data['patientId'] ??
          (data['senderRole'] == 'PATIENT' ? senderId : recipientId),
      'subject': data['subject'] ?? 'Suivi médical',
      'content': data['content'] ?? '',
      'priority': data['priority'] ?? 'ROUTINE',
      'sentAt': DateTime.now().toIso8601String(),
    });
    _inMemoryMessages.add(newMsg);
    return newMsg;
  }

  // ---------------------------------------------------------------------------
  // Gestion des alertes
  // ---------------------------------------------------------------------------
  static void addAlert(ClinicalAlert alert) {
    _ensureInitialized();
    _inMemoryAlerts.insert(0, alert);
  }

  Future<List<ClinicalAlert>> getAlerts({String? userId}) async {
    _ensureInitialized();
    try {
      final endpoint = userId != null && userId.isNotEmpty
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
      // Ignore errors – fallback to in‑memory data
    }

    if (userId == null || userId.isEmpty) {
      return List<ClinicalAlert>.from(_inMemoryAlerts);
    }
    return _inMemoryAlerts
        .where((a) => a.recipientUserId == null || a.recipientUserId == userId)
        .toList();
  }
}
