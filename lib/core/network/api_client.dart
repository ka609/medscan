import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final SecureStorage _secureStorage = SecureStorage.instance;

  late final Dio _dio = _createDio();

  bool _refreshingToken = false;

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
        },
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );

    return dio;
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicEndpoint(options.path)) {
      final token = await _secureStorage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = error.response?.statusCode;

    if (statusCode != 401 ||
        _isAuthEndpoint(error.requestOptions.path) ||
        _isRefreshRequest(error.requestOptions)) {
      handler.next(error);
      return;
    }

    final refreshed = await _tryRefreshToken();

    if (!refreshed) {
      await _secureStorage.clearSession();
      handler.next(error);
      return;
    }

    try {
      final requestOptions = error.requestOptions;
      final token = await _secureStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        await _secureStorage.clearSession();
        handler.next(error);
        return;
      }

      requestOptions.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.fetch(requestOptions);

      handler.resolve(response);
    } catch (_) {
      await _secureStorage.clearSession();
      handler.next(error);
    }
  }

  bool _isPublicEndpoint(String path) {
    return _isAuthEndpoint(path) || path.endsWith('/health');
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') || path.contains('/auth/refresh');
  }

  bool _isRefreshRequest(RequestOptions request) {
    return request.path.contains('/auth/refresh');
  }

  Future<bool> _tryRefreshToken() async {
    if (_refreshingToken) {
      return false;
    }

    _refreshingToken = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          sendTimeout: ApiConstants.sendTimeout,
          headers: {
            'Content-Type': ApiConstants.contentType,
            'Accept': ApiConstants.accept,
          },
        ),
      );

      final response = await dio.post(
        '/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        return false;
      }

      final newAccessToken = data['accessToken'] ?? data['access_token'];

      final newRefreshToken = data['refreshToken'] ?? data['refresh_token'];

      if (newAccessToken == null || newAccessToken.toString().isEmpty) {
        return false;
      }

      await _secureStorage.saveAccessToken(newAccessToken.toString());

      if (newRefreshToken != null && newRefreshToken.toString().isNotEmpty) {
        await _secureStorage.saveRefreshToken(newRefreshToken.toString());
      }

      return true;
    } catch (_) {
      await _secureStorage.clearSession();
      return false;
    } finally {
      _refreshingToken = false;
    }
  }

  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return _buildResponse(response);
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<ApiResponse<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _buildResponse(response);
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<ApiResponse<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _buildResponse(response);
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<ApiResponse<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _buildResponse(response);
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<ApiResponse<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _buildResponse(response);
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<ApiResponse<dynamic>> upload(
    String path, {
    required FormData data,
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: options,
        onSendProgress: onSendProgress,
      );

      return _buildResponse(response);
    } catch (error) {
      throw _handleError(error);
    }
  }

  ApiResponse<dynamic> _buildResponse(Response response) {
    final statusCode = response.statusCode ?? 200;

    return ApiResponse<dynamic>.fromJson(response.data, statusCode: statusCode);
  }

  ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout) {
        return const TimeoutException();
      }

      if (error.type == DioExceptionType.sendTimeout) {
        return const TimeoutException(
          message: 'L’envoi de la requête a expiré.',
        );
      }

      if (error.type == DioExceptionType.receiveTimeout) {
        return const TimeoutException();
      }

      if (error.type == DioExceptionType.connectionError) {
        return const NetworkException();
      }

      if (error.type == DioExceptionType.cancel) {
        return const NetworkException(message: 'La requête a été annulée.');
      }

      final response = error.response;

      if (response != null) {
        return _exceptionFromStatus(response.statusCode ?? 500, response.data);
      }

      return NetworkException(message: error.message ?? 'Erreur réseau.');
    }

    return ApiException(message: error.toString());
  }

  ApiException _exceptionFromStatus(int statusCode, dynamic data) {
    final type = _extractString(data, 'type');
    final title = _extractString(data, 'title');
    final detail = _extractString(data, 'detail');
    final instance = _extractString(data, 'instance');
    final code = _extractString(data, 'code');

    final message = detail ?? title ?? 'Une erreur est survenue.';

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: message,
          code: code,
          type: type,
          title: title,
          detail: detail,
          instance: instance,
          data: data,
        );

      case 401:
        return UnauthorizedException(
          message: message,
          code: code,
          type: type,
          title: title,
          detail: detail,
          instance: instance,
          data: data,
        );

      case 403:
        return ForbiddenException(
          message: message,
          code: code,
          type: type,
          title: title,
          detail: detail,
          instance: instance,
          data: data,
        );

      case 404:
        return NotFoundException(
          message: message,
          code: code,
          type: type,
          title: title,
          detail: detail,
          instance: instance,
          data: data,
        );

      case 409:
        return ConflictException(
          message: message,
          code: code,
          type: type,
          title: title,
          detail: detail,
          instance: instance,
          data: data,
        );

      case 422:
        return ValidationException(
          message: message,
          code: code,
          type: type,
          title: title,
          detail: detail,
          instance: instance,
          data: data,
          errors: _extractValidationErrors(data),
        );

      default:
        if (statusCode >= 500) {
          return ServerException(
            message: message,
            statusCode: statusCode,
            code: code,
            type: type,
            title: title,
            detail: detail,
            instance: instance,
            data: data,
          );
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          code: code,
          type: type,
          title: title,
          detail: detail,
          instance: instance,
          data: data,
        );
    }
  }

  String? _extractString(dynamic data, String key) {
    if (data is Map && data[key] != null) {
      return data[key].toString();
    }

    return null;
  }

  Map<String, dynamic>? _extractValidationErrors(dynamic data) {
    if (data is Map) {
      final errors = data['errors'];

      if (errors is Map) {
        return Map<String, dynamic>.from(errors);
      }
    }

    return null;
  }

  Future<bool> hasAuthentication() async {
    final token = await _secureStorage.getAccessToken();

    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _secureStorage.clearSession();
  }

  String get baseUrl => ApiConstants.baseUrl;

  Dio get dio => _dio;
}
