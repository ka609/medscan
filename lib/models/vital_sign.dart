class VitalSign {
  final String id;
  final String? patientId;
  final DateTime? recordedAt;
  final int systolicBp;
  final int diastolicBp;
  final int heartRate;
  final double temperature;
  final double weightKg;
  final double? heightCm;
  final double? bmi;
  final String? bmiCategory;
  final double bloodGlucose;
  final double? oxygenSaturation;
  final int? respiratoryRate;
  final int? painScale;
  final String bloodGroup;
  final List<String> allergies;
  final List<String> chronicConditions;
  final String? emergencyContact;
  final String triageLevel;
  final String? notes;
  final Map<String, String> customFields;
  final String recordedBy;
  final String recordedByRole;

  const VitalSign({
    required this.id,
    this.patientId,
    required this.recordedAt,
    required this.systolicBp,
    required this.diastolicBp,
    required this.heartRate,
    required this.temperature,
    required this.weightKg,
    this.heightCm,
    this.bmi,
    this.bmiCategory,
    required this.bloodGlucose,
    this.oxygenSaturation,
    this.respiratoryRate,
    this.painScale,
    this.bloodGroup = 'Inconnu',
    this.allergies = const [],
    this.chronicConditions = const [],
    this.emergencyContact,
    this.triageLevel = 'NORMAL',
    this.notes,
    this.customFields = const {},
    required this.recordedBy,
    required this.recordedByRole,
  });

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    final weight = (json['weightKg'] as num?)?.toDouble() ?? 0.0;
    final height = (json['heightCm'] as num?)?.toDouble();
    double? calculatedBmi = (json['bmi'] as num?)?.toDouble();
    if (calculatedBmi == null && height != null && height > 0 && weight > 0) {
      final hMeter = height / 100.0;
      calculatedBmi = double.parse((weight / (hMeter * hMeter)).toStringAsFixed(1));
    }

    final rawCustom = json['customFields'];
    final Map<String, String> parsedCustom = {};
    if (rawCustom is Map) {
      rawCustom.forEach((k, v) {
        parsedCustom[k.toString()] = v.toString();
      });
    }

    return VitalSign(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String?,
      recordedAt: _parseDate(json['recordedAt']),
      systolicBp: (json['systolicBp'] as num?)?.toInt() ?? 0,
      diastolicBp: (json['diastolicBp'] as num?)?.toInt() ?? 0,
      heartRate: (json['heartRate'] as num?)?.toInt() ?? 0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      weightKg: weight,
      heightCm: height,
      bmi: calculatedBmi,
      bmiCategory: json['bmiCategory'] as String?,
      bloodGlucose: (json['bloodGlucose'] as num?)?.toDouble() ?? 0.0,
      oxygenSaturation: (json['oxygenSaturation'] as num?)?.toDouble(),
      respiratoryRate: (json['respiratoryRate'] as num?)?.toInt(),
      painScale: (json['painScale'] as num?)?.toInt(),
      bloodGroup: json['bloodGroup'] as String? ?? 'Inconnu',
      allergies: List<String>.from(json['allergies'] ?? const []),
      chronicConditions: List<String>.from(json['chronicConditions'] ?? const []),
      emergencyContact: json['emergencyContact'] as String?,
      triageLevel: json['triageLevel'] as String? ?? 'NORMAL',
      notes: json['notes'] as String?,
      customFields: parsedCustom,
      recordedBy: json['recordedBy'] as String? ?? '',
      recordedByRole: json['recordedByRole'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'recordedAt': recordedAt?.toIso8601String(),
      'systolicBp': systolicBp,
      'diastolicBp': diastolicBp,
      'heartRate': heartRate,
      'temperature': temperature,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'bloodGlucose': bloodGlucose,
      'oxygenSaturation': oxygenSaturation,
      'respiratoryRate': respiratoryRate,
      'painScale': painScale,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'emergencyContact': emergencyContact,
      'triageLevel': triageLevel,
      'notes': notes,
      'customFields': customFields,
      'recordedBy': recordedBy,
      'recordedByRole': recordedByRole,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
