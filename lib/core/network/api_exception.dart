enum ApiErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  cancelled,
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.code,
    this.data,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final String? code;
  final dynamic data;

  @override
  String toString() => 'ApiException($type, $statusCode, $code): $message';
}
