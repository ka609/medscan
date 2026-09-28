class RadiologyReport {
  final String? id;
  final String conclusion;
  final String aiAgreementStatus;
  final String? recommendedActions;

  const RadiologyReport({
    this.id,
    required this.conclusion,
    required this.aiAgreementStatus,
    this.recommendedActions,
  });

  factory RadiologyReport.fromJson(Map<String, dynamic> json) {
    return RadiologyReport(
      id: json['id'] as String?,
      conclusion: json['conclusion'] as String? ?? '',
      aiAgreementStatus:
          json['aiAgreementStatus'] as String? ?? '',
      recommendedActions:
          json['recommendedActions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conclusion': conclusion,
      'aiAgreementStatus': aiAgreementStatus,
      'recommendedActions': recommendedActions,
    };
  }
}