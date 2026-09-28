class Consultation {
  final String id;
  final DateTime? date;
  final String doctorName;
  final String chiefComplaint;
  final String diagnosis;
  final String treatmentPlan;
  final String? examinationNotes;

  const Consultation({
    required this.id,
    required this.date,
    required this.doctorName,
    required this.chiefComplaint,
    required this.diagnosis,
    required this.treatmentPlan,
    this.examinationNotes,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as String? ?? '',
      date: _parseDate(json['date']),
      doctorName: json['doctorName'] as String? ?? '',
      chiefComplaint: json['chiefComplaint'] as String? ?? '',
      diagnosis: json['diagnosis'] as String? ?? '',
      treatmentPlan: json['treatmentPlan'] as String? ?? '',
      examinationNotes: json['examinationNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'doctorName': doctorName,
      'chiefComplaint': chiefComplaint,
      'diagnosis': diagnosis,
      'treatmentPlan': treatmentPlan,
      'examinationNotes': examinationNotes,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}