class ClinicalMessage {
  final String id;
  final String conversationId;
  final String tenantId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String recipientId;
  final String recipientName;
  final String recipientRole;
  final String patientId;
  final String subject;
  final String content;
  final String priority; // ROUTINE, URGENT, EMERGENCY
  final DateTime? readAt;
  final DateTime sentAt;

  const ClinicalMessage({
    required this.id,
    required this.conversationId,
    required this.tenantId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.recipientId,
    required this.recipientName,
    required this.recipientRole,
    required this.patientId,
    required this.subject,
    required this.content,
    required this.priority,
    this.readAt,
    required this.sentAt,
  });

  factory ClinicalMessage.fromJson(Map<String, dynamic> json) {
    return ClinicalMessage(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      senderRole: json['senderRole'] as String? ?? 'DOCTOR',
      recipientId: json['recipientId'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
      recipientRole: json['recipientRole'] as String? ?? 'PATIENT',
      patientId: json['patientId'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      content: json['content'] as String? ?? '',
      priority: json['priority'] as String? ?? 'ROUTINE',
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
      sentAt: DateTime.tryParse(json['sentAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'tenantId': tenantId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'recipientRole': recipientRole,
      'patientId': patientId,
      'subject': subject,
      'content': content,
      'priority': priority,
      'readAt': readAt?.toIso8601String(),
      'sentAt': sentAt.toIso8601String(),
    };
  }

  bool get isUrgent => priority == 'URGENT' || priority == 'EMERGENCY';
}

class ClinicalAlert {
  final String id;
  final String title;
  final String message;
  final String type; // LAB_CRITICAL, VITALS_ALERT, APPOINTMENT, SYSTEM
  final String severity; // INFO, WARNING, CRITICAL
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;
  final String? recipientUserId;

  const ClinicalAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
    this.recipientUserId,
  });

  factory ClinicalAlert.fromJson(Map<String, dynamic> json) {
    return ClinicalAlert(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'INFO',
      severity: json['severity'] as String? ?? 'INFO',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      actionRoute: json['actionRoute'] as String?,
      recipientUserId: json['recipientUserId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'actionRoute': actionRoute,
      'recipientUserId': recipientUserId,
    };
  }
}

