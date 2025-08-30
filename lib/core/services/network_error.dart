abstract class NetworkError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const NetworkError({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory NetworkError.unknown(String message, {int? statusCode, dynamic data}) =>
      NetworkErrorUnknown(message: message, statusCode: statusCode, data: data);
  factory NetworkError.badRequest(String message, {int? statusCode, dynamic data}) =>
      NetworkErrorBadRequest(message: message, statusCode: statusCode, data: data);
  factory NetworkError.unauthorized(String message, {int? statusCode, dynamic data}) =>
      NetworkErrorUnauthorized(message: message, statusCode: statusCode, data: data);
  factory NetworkError.forbidden(String message, {int? statusCode, dynamic data}) =>
      NetworkErrorForbidden(message: message, statusCode: statusCode, data: data);
  factory NetworkError.notFound(String message, {int? statusCode, dynamic data}) =>
      NetworkErrorNotFound(message: message, statusCode: statusCode, data: data);
  factory NetworkError.serverError(String message, {int? statusCode, dynamic data}) =>
      NetworkErrorServerError(message: message, statusCode: statusCode, data: data);
  factory NetworkError.timeout(String message, {int? statusCode, dynamic data}) =>
      NetworkErrorTimeout(message: message, statusCode: statusCode, data: data);
  factory NetworkError.noInternet(String message) =>
      NetworkErrorNoInternet(message: message);

  @override
  String toString() => 'NetworkError: $message';
}

class NetworkErrorUnknown extends NetworkError {
  const NetworkErrorUnknown({required super.message, super.statusCode, super.data});
}

class NetworkErrorBadRequest extends NetworkError {
  const NetworkErrorBadRequest({required super.message, super.statusCode, super.data});
}

class NetworkErrorUnauthorized extends NetworkError {
  const NetworkErrorUnauthorized({required super.message, super.statusCode, super.data});
}

class NetworkErrorForbidden extends NetworkError {
  const NetworkErrorForbidden({required super.message, super.statusCode, super.data});
}

class NetworkErrorNotFound extends NetworkError {
  const NetworkErrorNotFound({required super.message, super.statusCode, super.data});
}

class NetworkErrorServerError extends NetworkError {
  const NetworkErrorServerError({required super.message, super.statusCode, super.data});
}

class NetworkErrorTimeout extends NetworkError {
  const NetworkErrorTimeout({required super.message, super.statusCode, super.data});
}

class NetworkErrorNoInternet extends NetworkError {
  const NetworkErrorNoInternet({required super.message});
}
