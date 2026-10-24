class MedicalReferral {
  final String id;
  final String referralCode;
  final String patientId;
  final String patientName;
  final String referringDoctorId;
  final String referringDoctorName;
  final String sourceTenantId;
  final String sourceTenantName;
  final String targetTenantId;
  final String targetTenantName;
  final String targetService;
  final String requiredSpeciality;
  final String clinicalReason;
  final String medicalSummary;
  final String priority; // ROUTINE, URGENT, EMERGENCY
  final String status; // PENDING, ACCEPTED, REJECTED, COMPLETED
  final String? rejectionReason;
  final DateTime createdAt;

  const MedicalReferral({
    required this.id,
    required this.referralCode,
    required this.patientId,
    required this.patientName,
    required this.referringDoctorId,
    required this.referringDoctorName,
    required this.sourceTenantId,
    required this.sourceTenantName,
    required this.targetTenantId,
    required this.targetTenantName,
    required this.targetService,
    required this.requiredSpeciality,
    required this.clinicalReason,
    required this.medicalSummary,
    required this.priority,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  factory MedicalReferral.fromJson(Map<String, dynamic> json) {
    return MedicalReferral(
      id: json['id'] as String? ?? '',
      referralCode: json['referralCode'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      referringDoctorId: json['referringDoctorId'] as String? ?? '',
      referringDoctorName: json['referringDoctorName'] as String? ?? '',
      sourceTenantId: json['sourceTenantId'] as String? ?? '',
      sourceTenantName: json['sourceTenantName'] as String? ?? '',
      targetTenantId: json['targetTenantId'] as String? ?? '',
      targetTenantName: json['targetTenantName'] as String? ?? '',
      targetService: json['targetService'] as String? ?? '',
      requiredSpeciality: json['requiredSpeciality'] as String? ?? '',
      clinicalReason: json['clinicalReason'] as String? ?? '',
      medicalSummary: json['medicalSummary'] as String? ?? '',
      priority: json['priority'] as String? ?? 'ROUTINE',
      status: json['status'] as String? ?? 'PENDING',
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referralCode': referralCode,
      'patientId': patientId,
      'patientName': patientName,
      'referringDoctorId': referringDoctorId,
      'referringDoctorName': referringDoctorName,
      'sourceTenantId': sourceTenantId,
      'sourceTenantName': sourceTenantName,
      'targetTenantId': targetTenantId,
      'targetTenantName': targetTenantName,
      'targetService': targetService,
      'requiredSpeciality': requiredSpeciality,
      'clinicalReason': clinicalReason,
      'medicalSummary': medicalSummary,
      'priority': priority,
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
