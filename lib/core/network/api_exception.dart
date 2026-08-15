class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
    this.requestId,
    this.retryAfterSeconds,
  });

  final String code;
  final String message;
  final dynamic details;
  final int? statusCode;
  final String? requestId;
  final int? retryAfterSeconds;

  bool get canRetry => switch (statusCode) {
    408 || 425 || 429 || 502 || 503 || 504 => true,
    _ => code == 'network_error' || code == 'request_timeout',
  };

  @override
  String toString() =>
      'ApiException(code: $code, message: $message, '
      'requestId: $requestId, statusCode: $statusCode)';
}
