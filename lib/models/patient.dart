class Patient {
  final String id;
  final String nationalId;
  final String firstName;
  final String lastName;
  final String fullName;
  final DateTime? birthDate;
  final String gender;
  final String bloodGroup;
  final String phone;
  final String emergencyContact;
  final List<String> allergies;
  final List<String> chronicConditions;
  final String tenantId;
  final DateTime? createdAt;

  const Patient({
    required this.id,
    required this.nationalId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.birthDate,
    required this.gender,
    required this.bloodGroup,
    required this.phone,
    required this.emergencyContact,
    required this.allergies,
    required this.chronicConditions,
    required this.tenantId,
    required this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String? ?? '',
      nationalId: json['nationalId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      birthDate: _parseDate(json['birthDate']),
      gender: json['gender'] as String? ?? '',
      bloodGroup: json['bloodGroup'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      emergencyContact: json['emergencyContact'] as String? ?? '',
      allergies: List<String>.from(json['allergies'] ?? const []),
      chronicConditions: List<String>.from(
        json['chronicConditions'] ?? const [],
      ),
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
      'gender': gender,
      'bloodGroup': bloodGroup,
      'phone': phone,
      'emergencyContact': emergencyContact,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'tenantId': tenantId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}