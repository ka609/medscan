import 'message.dart';

/// Modèle représentatif d'une conversation clinique entre deux participants
class Conversation {
  final String id;
  final String participantId;
  final String participantName;
  final String participantRole; // 'DOCTOR' ou 'PATIENT'
  final ClinicalMessage? lastMessage;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantRole,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    ClinicalMessage? last;
    if (json['lastMessage'] is Map) {
      last = ClinicalMessage.fromJson(
        Map<String, dynamic>.from(json['lastMessage'] as Map),
      );
    }
    return Conversation(
      id: json['id'] as String? ?? '',
      participantId: json['participantId'] as String? ?? '',
      participantName: json['participantName'] as String? ?? '',
      participantRole: json['participantRole'] as String? ?? 'DOCTOR',
      lastMessage: last,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'participantRole': participantRole,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
    };
  }

  Conversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantRole,
    ClinicalMessage? lastMessage,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantRole: participantRole ?? this.participantRole,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Contact médical éligible pour initier une nouvelle conversation (isolation déontologique)
class MessagingContact {
  final String id;
  final String name;
  final String role; // 'DOCTOR' ou 'PATIENT'
  final String details; // Ex: 'Médecin Référent - Consulté le 24/10'

  const MessagingContact({
    required this.id,
    required this.name,
    required this.role,
    required this.details,
  });

  factory MessagingContact.fromJson(Map<String, dynamic> json) {
    return MessagingContact(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'DOCTOR',
      details: json['details'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'details': details,
  };
}
