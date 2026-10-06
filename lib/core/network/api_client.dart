import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:magna_data_ai_ecommerce/core/configs/app_config.dart';
import 'package:magna_data_ai_ecommerce/core/network/interceptors/auth_interceptors.dart';
import 'package:magna_data_ai_ecommerce/core/network/interceptors/error_interceptors.dart';
import 'package:magna_data_ai_ecommerce/core/network/interceptors/logging_interceptors.dart';

import 'api_exception.dart';

class ApiClient {
  ApiClient({String? baseUrl, String? Function()? tokenProvider})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? '${AppConfig.baseUrl}${AppConfig.storeApiPath}',
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          headers: const {'Accept': 'application/json'},
          responseType: ResponseType.json,
        ),
      ) {
    if (tokenProvider != null) {
      dio.interceptors.add(AuthInterceptor(tokenProvider));
    }
    dio.interceptors.add(ErrorInterceptor());
    if (kDebugMode) {
      dio.interceptors.add(LoggingInterceptor());
    }
  }

  final Dio dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) {
    return _run(
      () => dio.get<T>(path, queryParameters: query, cancelToken: cancelToken),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _run(
      () => dio.post<T>(
        path,
        data: data,
        queryParameters: query,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) {
    return _run(
      () => dio.delete<T>(
        path,
        data: data,
        queryParameters: query,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> _run<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final error = e.error;
      if (error is ApiException) throw error;
      throw ApiException(
        type: ApiErrorType.unknown,
        message: e.message ?? 'Something went wrong.',
      );
    }
  }
}
