import 'dart:io';
import 'package:dio/dio.dart';
import 'failure.dart';

class ExceptionMapper {
  const ExceptionMapper._();

  static Failure map(Object exception) {
    if (exception is DioException) return _mapDio(exception);
    if (exception is SocketException) return const NetworkFailure();
    if (exception is Failure) return exception;
    return const UnexpectedFailure();
  }

  static Failure _mapDio(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          const TimeoutFailure(),
        DioExceptionType.connectionError => const NetworkFailure(),
        DioExceptionType.badResponse => _mapResponse(e.response),
        _ => const UnexpectedFailure(),
      };

  static Failure _mapResponse(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final message = _extractMessage(response?.data);

    return switch (statusCode) {
      401 => UnauthorizedFailure(message),
      404 => NotFoundFailure(message),
      400 || 422 => ValidationFailure(
          message,
          errors: response?.data is Map ? response?.data['errors'] : null,
        ),
      >= 500 => ServerFailure(message, statusCode: statusCode),
      _ => ServerFailure(message, statusCode: statusCode),
    };
  }

  static String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          'Server error';
    }
    return 'Server error';
  }
}
