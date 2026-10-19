import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../configs/app_config.dart';
import 'interceptors/error_interceptors.dart';
import 'interceptors/logging_interceptors.dart';

class ApiClient {
  ApiClient({String? baseUrl, this.tokenProvider, this._cookieProvider})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(ErrorInterceptor());
    if (kDebugMode) {
      dio.interceptors.add(LoggingInterceptor());
    }
    if (tokenProvider != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            try {
              final token = await tokenProvider!();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] ??= 'Bearer $token';
              }
              handler.next(options);
            } catch (e) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  error: e,
                  message: 'Unable to retrieve authentication token.',
                ),
              );
            }
          },
        ),
      );
    }
    if (_cookieProvider != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final cookie = _cookieProvider();
            if (cookie != null && cookie.isNotEmpty) {
              options.headers['User-Cookie'] = cookie;
            }
            handler.next(options);
          },
        ),
      );
    }
  }

  final Dio dio;
  final Future<String?> Function()? tokenProvider;
  final String? Function()? _cookieProvider;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.get<T>(
      path,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.patch<T>(
      path,
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: query,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
