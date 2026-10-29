/// Modèle représentant un résultat individuel au sein d'une analyse biologique
class LabResultItem {
  final String testCode;
  final String testName;
  final String? loincCode;
  final String? valueText;
  final double? valueNumeric;
  final String? unit;
  final double? referenceLow;
  final double? referenceHigh;
  final bool isAbnormal;
  final bool isCritical;
  final String? interpretation;

  const LabResultItem({
    required this.testCode,
    required this.testName,
    this.loincCode,
    this.valueText,
    this.valueNumeric,
    this.unit,
    this.referenceLow,
    this.referenceHigh,
    this.isAbnormal = false,
    this.isCritical = false,
    this.interpretation,
  });

  factory LabResultItem.fromJson(Map<String, dynamic> json) {
    return LabResultItem(
      testCode: json['testCode'] as String? ?? '',
      testName: json['testName'] as String? ?? '',
      loincCode: json['loincCode'] as String?,
      valueText: json['valueText'] as String?,
      valueNumeric: (json['valueNumeric'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      referenceLow: (json['referenceLow'] as num?)?.toDouble(),
      referenceHigh: (json['referenceHigh'] as num?)?.toDouble(),
      isAbnormal: json['isAbnormal'] as bool? ?? false,
      isCritical: json['isCritical'] as bool? ?? false,
      interpretation: json['interpretation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testCode': testCode,
      'testName': testName,
      'loincCode': loincCode,
      'valueText': valueText,
      'valueNumeric': valueNumeric,
      'unit': unit,
      'referenceLow': referenceLow,
      'referenceHigh': referenceHigh,
      'isAbnormal': isAbnormal,
      'isCritical': isCritical,
      'interpretation': interpretation,
    };
  }

  String get displayValue {
    if (valueNumeric != null) {
      return '$valueNumeric ${unit ?? ''}'.trim();
    }
    return valueText ?? '—';
  }
}

/// Modèle complet d'une prescription / dossier d'analyse biologique (MOD-13)
class LabOrder {
  final String id;
  final String orderCode;
  final String tenantId;
  final String patientId;
  final String patientName;
  final String prescriberId;
  final String prescriberName;
  final String? technicianId;
  final String? technicianName;
  final String testCategory; // PARASITOLOGY, BIOCHEMISTRY, HEMATOLOGY, etc.
  final String testName;
  final String priority; // ROUTINE, URGENT, EMERGENCY
  final String status; // ORDERED, IN_PROGRESS, VALIDATED
  final String? clinicalIndication;
  final DateTime? sampleCollectedAt;
  final DateTime? validatedAt;
  final List<LabResultItem> results;
  final bool isCriticalAlert;
  final DateTime createdAt;

  const LabOrder({
    required this.id,
    required this.orderCode,
    required this.tenantId,
    required this.patientId,
    required this.patientName,
    required this.prescriberId,
    required this.prescriberName,
    this.technicianId,
    this.technicianName,
    required this.testCategory,
    required this.testName,
    required this.priority,
    required this.status,
    this.clinicalIndication,
    this.sampleCollectedAt,
    this.validatedAt,
    this.results = const [],
    this.isCriticalAlert = false,
    required this.createdAt,
  });

  factory LabOrder.fromJson(Map<String, dynamic> json) {
    var rawResults = json['results'];
    List<LabResultItem> parsedResults = [];
    if (rawResults is List) {
      parsedResults = rawResults
          .whereType<Map>()
          .map((r) => LabResultItem.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }

    return LabOrder(
      id: json['id'] as String? ?? '',
      orderCode: json['orderCode'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? 'Patient Inconnu',
      prescriberId: json['prescriberId'] as String? ?? '',
      prescriberName: json['prescriberName'] as String? ?? 'Médecin Prescripteur',
      technicianId: json['technicianId'] as String?,
      technicianName: json['technicianName'] as String?,
      testCategory: json['testCategory'] as String? ?? 'BIOCHEMISTRY',
      testName: json['testName'] as String? ?? '',
      priority: json['priority'] as String? ?? 'ROUTINE',
      status: json['status'] as String? ?? 'ORDERED',
      clinicalIndication: json['clinicalIndication'] as String?,
      sampleCollectedAt: json['sampleCollectedAt'] != null
          ? DateTime.tryParse(json['sampleCollectedAt'].toString())
          : null,
      validatedAt: json['validatedAt'] != null
          ? DateTime.tryParse(json['validatedAt'].toString())
          : null,
      results: parsedResults,
      isCriticalAlert: json['isCriticalAlert'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderCode': orderCode,
      'tenantId': tenantId,
      'patientId': patientId,
      'patientName': patientName,
      'prescriberId': prescriberId,
      'prescriberName': prescriberName,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'testCategory': testCategory,
      'testName': testName,
      'priority': priority,
      'status': status,
      'clinicalIndication': clinicalIndication,
      'sampleCollectedAt': sampleCollectedAt?.toIso8601String(),
      'validatedAt': validatedAt?.toIso8601String(),
      'results': results.map((r) => r.toJson()).toList(),
      'isCriticalAlert': isCriticalAlert,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isValidated => status == 'VALIDATED';
  bool get isUrgent => priority == 'URGENT' || priority == 'EMERGENCY' || isCriticalAlert;

  LabOrder copyWith({
    String? status,
    DateTime? sampleCollectedAt,
    DateTime? validatedAt,
    List<LabResultItem>? results,
    bool? isCriticalAlert,
    String? technicianId,
    String? technicianName,
  }) {
    return LabOrder(
      id: id,
      orderCode: orderCode,
      tenantId: tenantId,
      patientId: patientId,
      patientName: patientName,
      prescriberId: prescriberId,
      prescriberName: prescriberName,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      testCategory: testCategory,
      testName: testName,
      priority: priority,
      status: status ?? this.status,
      clinicalIndication: clinicalIndication,
      sampleCollectedAt: sampleCollectedAt ?? this.sampleCollectedAt,
      validatedAt: validatedAt ?? this.validatedAt,
      results: results ?? this.results,
      isCriticalAlert: isCriticalAlert ?? this.isCriticalAlert,
      createdAt: createdAt,
    );
  }
}

