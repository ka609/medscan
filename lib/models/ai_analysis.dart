class AiAnalysis {
  final String id;
  final DateTime? analyzedAt;
  final String modelName;
  final String modelVersion;
  final String primaryFinding;
  final double confidenceScore;
  final String riskLevel;
  final List<AiFinding> findings;
  final String heatmapOverlayUrl;
  final int executionTimeMs;
  final String disclaimer;

  const AiAnalysis({
    required this.id,
    required this.analyzedAt,
    required this.modelName,
    required this.modelVersion,
    required this.primaryFinding,
    required this.confidenceScore,
    required this.riskLevel,
    required this.findings,
    required this.heatmapOverlayUrl,
    required this.executionTimeMs,
    required this.disclaimer,
  });

  factory AiAnalysis.fromJson(Map<String, dynamic> json) {
    return AiAnalysis(
      id: json['id'] as String? ?? '',
      analyzedAt: _parseDate(json['analyzedAt']),
      modelName: json['modelName'] as String? ?? '',
      modelVersion: json['modelVersion'] as String? ?? '',
      primaryFinding: json['primaryFinding'] as String? ?? '',
      confidenceScore:
          (json['confidenceScore'] as num?)?.toDouble() ?? 0,
      riskLevel: json['riskLevel'] as String? ?? '',
      findings: (json['findings'] as List<dynamic>? ?? [])
          .map(
            (item) => AiFinding.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      heatmapOverlayUrl:
          json['heatmapOverlayUrl'] as String? ?? '',
      executionTimeMs:
          (json['executionTimeMs'] as num?)?.toInt() ?? 0,
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'analyzedAt': analyzedAt?.toIso8601String(),
      'modelName': modelName,
      'modelVersion': modelVersion,
      'primaryFinding': primaryFinding,
      'confidenceScore': confidenceScore,
      'riskLevel': riskLevel,
      'findings': findings.map((item) => item.toJson()).toList(),
      'heatmapOverlayUrl': heatmapOverlayUrl,
      'executionTimeMs': executionTimeMs,
      'disclaimer': disclaimer,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}

class AiFinding {
  final String label;
  final double probability;
  final String anatomicalRegion;
  final String severity;

  const AiFinding({
    required this.label,
    required this.probability,
    required this.anatomicalRegion,
    required this.severity,
  });

  factory AiFinding.fromJson(Map<String, dynamic> json) {
    return AiFinding(
      label: json['label'] as String? ?? '',
      probability:
          (json['probability'] as num?)?.toDouble() ?? 0,
      anatomicalRegion:
          json['anatomicalRegion'] as String? ?? '',
      severity: json['severity'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'probability': probability,
      'anatomicalRegion': anatomicalRegion,
      'severity': severity,
    };
  }
}