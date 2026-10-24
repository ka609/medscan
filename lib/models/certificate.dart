class MedicalCertificate {
  final String id;
  final String certificateNumber;
  final String type; // SICK_LEAVE, STUDENT_DISPENSE, FITNESS_CERTIFICATE
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String tenantId;
  final String hospitalName;
  final String diagnosisOrReason;
  final int restDurationDays;
  final DateTime startDate;
  final DateTime endDate;
  final String employerOrInstitution;
  final bool allowPhysicalActivities;
  final String status;
  final String digitalSealHash;
  final String verificationUrl;
  final DateTime createdAt;

  const MedicalCertificate({
    required this.id,
    required this.certificateNumber,
    required this.type,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.tenantId,
    required this.hospitalName,
    required this.diagnosisOrReason,
    required this.restDurationDays,
    required this.startDate,
    required this.endDate,
    required this.employerOrInstitution,
    required this.allowPhysicalActivities,
    required this.status,
    required this.digitalSealHash,
    required this.verificationUrl,
    required this.createdAt,
  });

  factory MedicalCertificate.fromJson(Map<String, dynamic> json) {
    return MedicalCertificate(
      id: json['id'] as String? ?? '',
      certificateNumber: json['certificateNumber'] as String? ?? '',
      type: json['type'] as String? ?? 'SICK_LEAVE',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      hospitalName: json['hospitalName'] as String? ?? 'Hôpital Général MedScan',
      diagnosisOrReason: json['diagnosisOrReason'] as String? ?? '',
      restDurationDays: (json['restDurationDays'] as num?)?.toInt() ?? 3,
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 3)),
      employerOrInstitution: json['employerOrInstitution'] as String? ?? 'Employeur / Établissement',
      allowPhysicalActivities: json['allowPhysicalActivities'] as bool? ?? false,
      status: json['status'] as String? ?? 'ISSUED',
      digitalSealHash: json['digitalSealHash'] as String? ?? '',
      verificationUrl: json['verificationUrl'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'certificateNumber': certificateNumber,
      'type': type,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'tenantId': tenantId,
      'hospitalName': hospitalName,
      'diagnosisOrReason': diagnosisOrReason,
      'restDurationDays': restDurationDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'employerOrInstitution': employerOrInstitution,
      'allowPhysicalActivities': allowPhysicalActivities,
      'status': status,
      'digitalSealHash': digitalSealHash,
      'verificationUrl': verificationUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get typeLabel {
    switch (type) {
      case 'SICK_LEAVE':
        return 'Arrêt de Travail Médical (Employeur)';
      case 'STUDENT_DISPENSE':
        return 'Dispense d\'Assiduité Scolaire / Universitaire';
      case 'FITNESS_CERTIFICATE':
        return 'Certificat Médical d\'Aptitude Physique';
      default:
        return 'Certificat Médical Officiel';
    }
  }
}
