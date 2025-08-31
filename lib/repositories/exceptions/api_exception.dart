class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Code: $errorCode)';
  }
}

class NetworkException extends ApiException {
  NetworkException({required super.message});
}

class TimeoutException extends ApiException {
  TimeoutException({required super.message});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({required super.message}) : super(statusCode: 401);
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException({
    required super.message,
    this.errors,
  }) : super(statusCode: 400);
}

class ServerException extends ApiException {
  ServerException({required super.message}) : super(statusCode: 500);
}
