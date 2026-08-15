sealed class TreeRegistrationFailure implements Exception {
  const TreeRegistrationFailure(this.message);
  final String message;
}

class PermissionDeniedFailure extends TreeRegistrationFailure {
  const PermissionDeniedFailure([super.message = 'Permission is required.']);
}

class LocationServicesDisabledFailure extends TreeRegistrationFailure {
  const LocationServicesDisabledFailure([
    super.message = 'Location services are disabled.',
  ]);
}

class LocationAccuracyFailure extends TreeRegistrationFailure {
  const LocationAccuracyFailure([
    super.message = 'A reliable location could not be calculated.',
  ]);
}

class InvalidImageFailure extends TreeRegistrationFailure {
  const InvalidImageFailure([super.message = 'One of the photos is invalid.']);
}

class NetworkUnavailableFailure extends TreeRegistrationFailure {
  const NetworkUnavailableFailure([
    super.message = 'No connection. Your draft is safe.',
  ]);
}

class RequestTimeoutFailure extends TreeRegistrationFailure {
  const RequestTimeoutFailure([
    super.message = 'The request timed out. Your draft is safe.',
  ]);
}

class AiProviderUnavailableFailure extends TreeRegistrationFailure {
  const AiProviderUnavailableFailure([
    super.message = 'Tree analysis is temporarily unavailable.',
  ]);
}

class AiQuotaExceededFailure extends TreeRegistrationFailure {
  const AiQuotaExceededFailure([
    super.message = 'Tree analysis capacity has been reached.',
  ]);
}

class LowConfidenceFailure extends TreeRegistrationFailure {
  const LowConfidenceFailure([
    super.message = 'No confident identification was found.',
  ]);
}

class UnauthorizedFailure extends TreeRegistrationFailure {
  const UnauthorizedFailure([super.message = 'Please sign in again.']);
}

class UnexpectedTreeRegistrationFailure extends TreeRegistrationFailure {
  const UnexpectedTreeRegistrationFailure([
    super.message = 'Something went wrong. Your draft is safe.',
  ]);
}
