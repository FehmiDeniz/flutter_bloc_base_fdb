import 'package:dio/dio.dart';
import 'network_error.dart';

class NetworkErrorHandler {
  static NetworkError handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkError.timeout(
          'Request timeout',
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.connectionError:
        return NetworkError.noInternet('No internet connection');

      case DioExceptionType.cancel:
        return NetworkError.unknown('Request cancelled');

      case DioExceptionType.unknown:
      default:
        return NetworkError.unknown(
          error.message ?? 'Unknown error occurred',
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
    }
  }

  static NetworkError _handleResponseError(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    final message = _extractErrorMessage(data);

    switch (statusCode) {
      case 400:
        return NetworkError.badRequest(
          message,
          statusCode: statusCode,
          data: data,
        );

      case 401:
        return NetworkError.unauthorized(
          message,
          statusCode: statusCode,
          data: data,
        );

      case 403:
        return NetworkError.forbidden(
          message,
          statusCode: statusCode,
          data: data,
        );

      case 404:
        return NetworkError.notFound(
          message,
          statusCode: statusCode,
          data: data,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return NetworkError.serverError(
          message,
          statusCode: statusCode,
          data: data,
        );

      default:
        return NetworkError.unknown(
          message,
          statusCode: statusCode,
          data: data,
        );
    }
  }

  static String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Unknown error';

    if (data is Map<String, dynamic>) {
      // Try to extract error message from common response formats
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data.containsKey('error')) {
        return data['error'].toString();
      }
      if (data.containsKey('detail')) {
        return data['detail'].toString();
      }
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
        if (errors is Map<String, dynamic>) {
          return errors.values.first.toString();
        }
      }
    }

    return data.toString();
  }

  static bool isNetworkError(dynamic error) {
    return error is NetworkError;
  }

  static bool isUnauthorized(dynamic error) {
    return error is NetworkErrorUnauthorized;
  }

  static bool isServerError(dynamic error) {
    return error is NetworkErrorServerError;
  }

  static bool isTimeout(dynamic error) {
    return error is NetworkErrorTimeout;
  }

  static bool isNoInternet(dynamic error) {
    return error is NetworkErrorNoInternet;
  }
}
