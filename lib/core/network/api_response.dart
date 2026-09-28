class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? meta;
  final dynamic rawData;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.code,
    this.statusCode,
    this.meta,
    this.rawData,
  });

  factory ApiResponse.success({
    T? data,
    String? message,
    String? code,
    int? statusCode,
    Map<String, dynamic>? meta,
    dynamic rawData,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      code: code,
      statusCode: statusCode,
      meta: meta,
      rawData: rawData,
    );
  }

  factory ApiResponse.failure({
    String? message,
    String? code,
    int? statusCode,
    Map<String, dynamic>? meta,
    dynamic rawData,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      code: code,
      statusCode: statusCode,
      meta: meta,
      rawData: rawData,
    );
  }

  factory ApiResponse.fromJson(
    dynamic json, {
    int? statusCode,
    T Function(dynamic json)? parser,
  }) {
    if (json is Map<String, dynamic>) {
      // Supporte une réponse avec wrapper {data: ...}
      final bool hasDataWrapper = json.containsKey('data');

      final dynamic rawData = hasDataWrapper ? json['data'] : json;

      T? parsedData;

      if (parser != null && rawData != null) {
        parsedData = parser(rawData);
      } else if (rawData is T) {
        parsedData = rawData;
      }

      Map<String, dynamic>? meta;

      if (json['meta'] is Map) {
        meta = Map<String, dynamic>.from(json['meta'] as Map);
      }

      return ApiResponse<T>(
        success: true,
        data: parsedData,
        message: json['message']?.toString(),
        code: json['code']?.toString(),
        statusCode: statusCode,
        meta: meta,
        rawData: rawData,
      );
    }

    T? parsedData;

    if (parser != null) {
      parsedData = parser(json);
    } else if (json is T) {
      parsedData = json;
    }

    return ApiResponse<T>(
      success: true,
      data: parsedData,
      statusCode: statusCode,
      rawData: json,
    );
  }

  bool get hasData => data != null;

  bool get isFailure => !success;

  bool get isSuccess => success;

  @override
  String toString() {
    return 'ApiResponse('
        'success: $success, '
        'statusCode: $statusCode, '
        'message: $message, '
        'code: $code'
        ')';
  }
}
