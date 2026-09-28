class Prescription {
  final String id;
  final String code;
  final String medicationName;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String instructions;
  final String? status;
  final DateTime? issuedAt;
  final DateTime? dispensedAt;
  final String? pharmacistName;

  const Prescription({
    required this.id,
    required this.code,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    required this.instructions,
    this.status,
    this.issuedAt,
    this.dispensedAt,
    this.pharmacistName,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      medicationName: json['medicationName'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
      instructions: json['instructions'] as String? ?? '',
      status: json['status'] as String?,
      issuedAt: _parseDate(json['issuedAt']),
      dispensedAt: _parseDate(json['dispensedAt']),
      pharmacistName: json['pharmacistName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'durationDays': durationDays,
      'instructions': instructions,
      'status': status,
      'issuedAt': issuedAt?.toIso8601String(),
      'dispensedAt': dispensedAt?.toIso8601String(),
      'pharmacistName': pharmacistName,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}