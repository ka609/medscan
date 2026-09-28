class VitalSign {
  final String id;
  final DateTime? recordedAt;
  final int systolicBp;
  final int diastolicBp;
  final int heartRate;
  final double temperature;
  final double weightKg;
  final double bloodGlucose;
  final String recordedBy;
  final String recordedByRole;

  const VitalSign({
    required this.id,
    required this.recordedAt,
    required this.systolicBp,
    required this.diastolicBp,
    required this.heartRate,
    required this.temperature,
    required this.weightKg,
    required this.bloodGlucose,
    required this.recordedBy,
    required this.recordedByRole,
  });

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    return VitalSign(
      id: json['id'] as String? ?? '',
      recordedAt: _parseDate(json['recordedAt']),
      systolicBp: (json['systolicBp'] as num?)?.toInt() ?? 0,
      diastolicBp: (json['diastolicBp'] as num?)?.toInt() ?? 0,
      heartRate: (json['heartRate'] as num?)?.toInt() ?? 0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      bloodGlucose: (json['bloodGlucose'] as num?)?.toDouble() ?? 0,
      recordedBy: json['recordedBy'] as String? ?? '',
      recordedByRole: json['recordedByRole'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordedAt': recordedAt?.toIso8601String(),
      'systolicBp': systolicBp,
      'diastolicBp': diastolicBp,
      'heartRate': heartRate,
      'temperature': temperature,
      'weightKg': weightKg,
      'bloodGlucose': bloodGlucose,
      'recordedBy': recordedBy,
      'recordedByRole': recordedByRole,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}