class Patient {
  final String id;
  final String nationalId;
  final String firstName;
  final String lastName;
  final String fullName;
  final DateTime? birthDate;
  final int? age;
  final String gender;
  final String bloodGroup;
  final String phone;
  final String emergencyContact;
  final List<String> allergies;
  final List<String> chronicConditions;
  final double? weightKg;
  final double? heightCm;
  final double? bmi;
  final String? bmiCategory;
  final Map<String, String> customFields;
  final String tenantId;
  final DateTime? createdAt;

  const Patient({
    required this.id,
    required this.nationalId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.birthDate,
    this.age,
    required this.gender,
    required this.bloodGroup,
    required this.phone,
    required this.emergencyContact,
    required this.allergies,
    required this.chronicConditions,
    this.weightKg,
    this.heightCm,
    this.bmi,
    this.bmiCategory,
    this.customFields = const {},
    required this.tenantId,
    required this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    final weight = (json['weightKg'] as num?)?.toDouble();
    final height = (json['heightCm'] as num?)?.toDouble();
    double? calculatedBmi = (json['bmi'] as num?)?.toDouble();
    if (calculatedBmi == null && weight != null && height != null && height > 0) {
      calculatedBmi = calculateBmi(weight, height);
    }

    String? category = json['bmiCategory'] as String?;
    if (category == null && calculatedBmi != null) {
      category = classifyBmi(calculatedBmi);
    }

    final rawCustom = json['customFields'];
    final Map<String, String> parsedCustom = {};
    if (rawCustom is Map) {
      rawCustom.forEach((k, v) {
        parsedCustom[k.toString()] = v.toString();
      });
    }

    return Patient(
      id: json['id'] as String? ?? '',
      nationalId: json['nationalId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      fullName: json['fullName'] as String? ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      birthDate: _parseDate(json['birthDate']),
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String? ?? '',
      bloodGroup: json['bloodGroup'] as String? ?? 'Inconnu',
      phone: json['phone'] as String? ?? '',
      emergencyContact: json['emergencyContact'] as String? ?? '',
      allergies: List<String>.from(json['allergies'] ?? const []),
      chronicConditions: List<String>.from(
        json['chronicConditions'] ?? const [],
      ),
      weightKg: weight,
      heightCm: height,
      bmi: calculatedBmi,
      bmiCategory: category,
      customFields: parsedCustom,
      tenantId: json['tenantId'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nationalId': nationalId,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'birthDate': birthDate?.toIso8601String(),
      'age': age,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'phone': phone,
      'emergencyContact': emergencyContact,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'customFields': customFields,
      'tenantId': tenantId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static double calculateBmi(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    final hMeter = heightCm / 100.0;
    final bmi = weightKg / (hMeter * hMeter);
    return double.parse(bmi.toStringAsFixed(1));
  }

  static String classifyBmi(double bmi) {
    if (bmi < 18.5) return 'Insuffisance pondérale';
    if (bmi < 25.0) return 'Poids normal / Idéal';
    if (bmi < 30.0) return 'Surpoids';
    return 'Obésité clinique';
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
