import 'ai_analysis.dart';
import 'radiology_report.dart';

class ImagingStudy {
  final String id;
  final String patientId;
  final String patientName;
  final String modality;
  final String bodyPart;
  final String title;
  final String imageUrl;
  final DateTime? studyDate;
  final String status;
  final AiAnalysis? aiAnalysis;
  final RadiologyReport? report;

  const ImagingStudy({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.modality,
    required this.bodyPart,
    required this.title,
    required this.imageUrl,
    required this.studyDate,
    required this.status,
    this.aiAnalysis,
    this.report,
  });

  factory ImagingStudy.fromJson(Map<String, dynamic> json) {
    return ImagingStudy(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      modality: json['modality'] as String? ?? '',
      bodyPart: json['bodyPart'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      studyDate: _parseDate(json['studyDate']),
      status: json['status'] as String? ?? '',
      aiAnalysis: json['aiAnalysis'] is Map<String, dynamic>
          ? AiAnalysis.fromJson(
              json['aiAnalysis'] as Map<String, dynamic>,
            )
          : null,
      report: json['report'] is Map<String, dynamic>
          ? RadiologyReport.fromJson(
              json['report'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'modality': modality,
      'bodyPart': bodyPart,
      'title': title,
      'imageUrl': imageUrl,
      'studyDate': studyDate?.toIso8601String(),
      'status': status,
      'aiAnalysis': aiAnalysis?.toJson(),
      'report': report?.toJson(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}