import 'package:dio/dio.dart';

import '../api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: _map(err)));
  }

  ApiException _map(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          type: ApiErrorType.timeout,
          message: 'The request timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          type: ApiErrorType.network,
          message: 'No internet connection.',
        );
      case DioExceptionType.cancel:
        return const ApiException(
          type: ApiErrorType.cancelled,
          message: 'Request cancelled.',
        );
      case DioExceptionType.badResponse:
        return _fromResponse(err.response);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiException(
          type: ApiErrorType.unknown,
          message: err.message ?? 'Something went wrong.',
        );
    }
  }

  ApiException _fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode;
    final data = response?.data;
    String? message;
    String? code;
    if (data is Map) {
      message = data['message']?.toString();
      code = data['code']?.toString();
    }
    final type = switch (status) {
      401 => ApiErrorType.unauthorized,
      403 => ApiErrorType.forbidden,
      404 => ApiErrorType.notFound,
      400 || 422 => ApiErrorType.validation,
      final s? when s >= 500 => ApiErrorType.server,
      _ => ApiErrorType.unknown,
    };
    return ApiException(
      type: type,
      message:
          message ?? 'Request failed${status == null ? '' : ' ($status)'}.',
      statusCode: status,
      code: code,
      data: data,
    );
  }
}
