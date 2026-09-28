class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final String? type;
  final String? title;
  final String? detail;
  final String? instance;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.type,
    this.title,
    this.detail,
    this.instance,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException('
        'statusCode: $statusCode, '
        'code: $code, '
        'type: $type, '
        'title: $title, '
        'message: $message'
        ')';
  }
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Impossible de contacter le serveur.',
    super.statusCode,
    super.code,
    super.type,
    super.title,
    super.detail,
    super.instance,
    super.data,
  });
}

class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Le serveur met trop de temps à répondre.',
    super.statusCode,
    super.code,
    super.type,
    super.title,
    super.detail,
    super.instance,
    super.data,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Votre session a expiré.',
    super.statusCode = 401,
    super.code,
    super.type,
    super.title,
    super.detail,
    super.instance,
    super.data,
  });
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Vous n’avez pas l’autorisation nécessaire.',
    super.statusCode = 403,
    super.code,
    super.type,
    super.title,
    super.detail,
    super.instance,
    super.data,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'La ressource demandée est introuvable.',
    super.statusCode = 404,
    super.code,
    super.type,
    super.title,
    super.detail,
    super.instance,
    super.data,
  });
}

class BadRequestException extends ApiException {
  const BadRequestException({
    super.message = 'La requête est invalide.',
    super.statusCode = 400,
    super.code,
    super.type,
    super.title,
    super.detail,
    super.instance,
    super.data,
  });
}

class ConflictException extends ApiException {
  const ConflictException({
    super.message = 'Cette opération provoque un conflit.',
    super.statusCode = 409,
    super.code,
    super.type,
    super.title,
    super.detail,
    super.instance,
    super.data,
  });
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    super.message = 'Les données envoyées sont invalides.',
    super.statusCode = 422,
    super.code,
    super.type,
    super.title,
    super.detail,
    super.instance,
    super.data,
    this.errors,
  });
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Une erreur est survenue sur le serveur.',
    super.statusCode,
    super.code,
    super.type,
    super.title,
    super.detail,
    super.instance,
    super.data,
  });
}
