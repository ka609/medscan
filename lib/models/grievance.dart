class PatientGrievance {
  final String id;
  final String grievanceCode;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String doctorId;
  final String doctorName;
  final String tenantId;
  final String hospitalName;
  final String? consultationId;
  final String grievanceType; // COMPLAINT, INCIDENT, FEEDBACK, COMMENDATION
  final String category; // BEHAVIOR_ETIQUETTE, DELAY_WAIT_TIME, CARE_QUALITY, PRESCRIPTION_ISSUE, ETHICAL_CONCERN, OTHER
  final int rating; // 1 to 5
  final String severity; // LOW, MEDIUM, HIGH, CRITICAL
  final String title;
  final String description;
  final String status; // SUBMITTED, UNDER_REVIEW, RESOLVED, DISMISSED
  final String? adminNotes;
  final String? adminActionTaken;
  final String? reviewedByAdminId;
  final String? reviewedByAdminName;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const PatientGrievance({
    required this.id,
    required this.grievanceCode,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.tenantId,
    required this.hospitalName,
    this.consultationId,
    required this.grievanceType,
    required this.category,
    required this.rating,
    required this.severity,
    required this.title,
    required this.description,
    required this.status,
    this.adminNotes,
    this.adminActionTaken,
    this.reviewedByAdminId,
    this.reviewedByAdminName,
    this.reviewedAt,
    required this.createdAt,
  });

  factory PatientGrievance.fromJson(Map<String, dynamic> json) {
    return PatientGrievance(
      id: json['id'] as String? ?? '',
      grievanceCode: json['grievanceCode'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      patientPhone: json['patientPhone'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      hospitalName: json['hospitalName'] as String? ?? 'Hôpital Général MedScan',
      consultationId: json['consultationId'] as String?,
      grievanceType: json['grievanceType'] as String? ?? 'COMPLAINT',
      category: json['category'] as String? ?? 'CARE_QUALITY',
      rating: (json['rating'] as num?)?.toInt() ?? 3,
      severity: json['severity'] as String? ?? 'MEDIUM',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'SUBMITTED',
      adminNotes: json['adminNotes'] as String?,
      adminActionTaken: json['adminActionTaken'] as String?,
      reviewedByAdminId: json['reviewedByAdminId'] as String?,
      reviewedByAdminName: json['reviewedByAdminName'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grievanceCode': grievanceCode,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'tenantId': tenantId,
      'hospitalName': hospitalName,
      'consultationId': consultationId,
      'grievanceType': grievanceType,
      'category': category,
      'rating': rating,
      'severity': severity,
      'title': title,
      'description': description,
      'status': status,
      'adminNotes': adminNotes,
      'adminActionTaken': adminActionTaken,
      'reviewedByAdminId': reviewedByAdminId,
      'reviewedByAdminName': reviewedByAdminName,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get categoryLabel {
    switch (category) {
      case 'BEHAVIOR_ETIQUETTE':
        return 'Comportement & Accueil';
      case 'DELAY_WAIT_TIME':
        return 'Délai d\'attente excessif';
      case 'CARE_QUALITY':
        return 'Qualité des soins dispensés';
      case 'PRESCRIPTION_ISSUE':
        return 'Problème de prescription / ordonnance';
      case 'ETHICAL_CONCERN':
        return 'Déontologie & Confidentialité';
      case 'OTHER':
      default:
        return 'Autre motif';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'SUBMITTED':
        return 'Soumise à la Direction';
      case 'UNDER_REVIEW':
        return 'En cours d\'examen';
      case 'RESOLVED':
        return 'Résolue avec mesures';
      case 'DISMISSED':
        return 'Classée sans suite';
      default:
        return status;
    }
  }

  String get severityLabel {
    switch (severity) {
      case 'LOW':
        return 'Basse';
      case 'MEDIUM':
        return 'Moyenne';
      case 'HIGH':
        return 'Élevée';
      case 'CRITICAL':
        return 'Critique';
      default:
        return severity;
    }
  }
}

