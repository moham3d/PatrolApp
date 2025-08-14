import 'package:dio/dio.dart';
import '../../shared/models/api_response.dart';

class ApiException implements Exception {
  final String code;
  final String message;
  final List<ValidationError>? details;
  final int? statusCode;

  const ApiException({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
  });

  factory ApiException.fromDioError(DioException error) {
    if (error.response != null) {
      try {
        final data = error.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          final errorData = data['error'] as Map<String, dynamic>;
          return ApiException(
            code: errorData['code'] ?? 'UNKNOWN_ERROR',
            message: errorData['message'] ?? 'An error occurred',
            details: errorData['details']?.map<ValidationError>(
              (detail) => ValidationError.fromJson(detail),
            ).toList(),
            statusCode: error.response!.statusCode,
          );
        }
      } catch (e) {
        // If parsing fails, fall through to default handling
      }
      
      // Default handling for non-structured error responses
      return ApiException(
        code: 'HTTP_ERROR',
        message: _getHttpErrorMessage(error.response!.statusCode!),
        statusCode: error.response!.statusCode,
      );
    } else {
      // Network or other errors
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const ApiException(
            code: 'TIMEOUT_ERROR',
            message: 'Request timeout. Please check your connection.',
          );
        case DioExceptionType.connectionError:
          return const ApiException(
            code: 'NETWORK_ERROR',
            message: 'Network error. Please check your internet connection.',
          );
        case DioExceptionType.cancel:
          return const ApiException(
            code: 'REQUEST_CANCELLED',
            message: 'Request was cancelled.',
          );
        default:
          return const ApiException(
            code: 'UNKNOWN_ERROR',
            message: 'An unexpected error occurred.',
          );
      }
    }
  }

  static String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Forbidden. You don\'t have permission for this action.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. The server is taking too long to respond.';
      default:
        return 'An error occurred (HTTP $statusCode).';
    }
  }

  @override
  String toString() {
    if (details != null && details!.isNotEmpty) {
      final detailMessages = details!.map((d) => '${d.field}: ${d.message}').join(', ');
      return '$message ($detailMessages)';
    }
    return message;
  }
}

class AuthException extends ApiException {
  const AuthException({
    required super.code,
    required super.message,
    super.details,
    super.statusCode,
  });

  factory AuthException.fromDioError(DioException error) {
    final apiException = ApiException.fromDioError(error);
    return AuthException(
      code: apiException.code,
      message: apiException.message,
      details: apiException.details,
      statusCode: apiException.statusCode,
    );
  }
}

class UserException extends ApiException {
  const UserException({
    required super.code,
    required super.message,
    super.details,
    super.statusCode,
  });

  factory UserException.fromDioError(DioException error) {
    final apiException = ApiException.fromDioError(error);
    return UserException(
      code: apiException.code,
      message: apiException.message,
      details: apiException.details,
      statusCode: apiException.statusCode,
    );
  }
}

class SiteException extends ApiException {
  const SiteException({
    required super.code,
    required super.message,
    super.details,
    super.statusCode,
  });

  factory SiteException.fromDioError(DioException error) {
    final apiException = ApiException.fromDioError(error);
    return SiteException(
      code: apiException.code,
      message: apiException.message,
      details: apiException.details,
      statusCode: apiException.statusCode,
    );
  }
}

class PatrolException extends ApiException {
  const PatrolException({
    required super.code,
    required super.message,
    super.details,
    super.statusCode,
  });

  factory PatrolException.fromDioError(DioException error) {
    final apiException = ApiException.fromDioError(error);
    return PatrolException(
      code: apiException.code,
      message: apiException.message,
      details: apiException.details,
      statusCode: apiException.statusCode,
    );
  }
}

class CheckpointException extends ApiException {
  const CheckpointException({
    required super.code,
    required super.message,
    super.details,
    super.statusCode,
  });

  factory CheckpointException.fromDioError(DioException error) {
    final apiException = ApiException.fromDioError(error);
    return CheckpointException(
      code: apiException.code,
      message: apiException.message,
      details: apiException.details,
      statusCode: apiException.statusCode,
    );
  }
}