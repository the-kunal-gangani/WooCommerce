import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._cookieProvider);

  final String? Function() _cookieProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final cookie = _cookieProvider();

    if (cookie != null &&
        cookie.isNotEmpty &&
        !options.headers.containsKey('User-Cookie')) {
      options.headers['User-Cookie'] = cookie;
    }

    handler.next(options);
  }
}
