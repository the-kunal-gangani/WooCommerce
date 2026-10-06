import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_client.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/services/secure_storage_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/storage_services.dart';
import 'package:magna_data_ai_ecommerce/core/utils/logger.dart';
import 'package:magna_data_ai_ecommerce/data/models/auth_user.dart';

class AuthService extends GetxService {
  AuthService(this._wp, this._secure, this._storage);

  final ApiClient _wp;
  final SecureStorageService _secure;
  final StorageService _storage;

  static const String _tokenKey = 'auth_jwt';
  static const String _userKey = 'auth_user';

  final user = Rxn<AuthUser>();
  String? _token;
  Future<void>? _restoring;

  String? get token => _token;

  bool get isLoggedIn => _token != null && user.value != null;

  Future<void> restore() => _restoring ??= _restore();

  Future<T> _guardAuth<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      if (e.type == ApiErrorType.notFound) {
        throw const ApiException(
          type: ApiErrorType.server,
          message:
              'Sign in is temporarily unavailable. Please try again later.',
        );
      }
      rethrow;
    }
  }

  Future<void> _restore() async {
    _token = await _secure.read(_tokenKey);
    if (_token == null) return;

    final stored = _storage.read<Map>(_userKey);
    if (stored != null) {
      user.value = AuthUser.fromJson(Map<String, dynamic>.from(stored));
    }

    try {
      user.value = await _fetchProfile();
      await _storage.write(_userKey, user.value!.toJson());
    } on ApiException catch (e) {
      printLog('session check failed: $e');
      if (e.type == ApiErrorType.unauthorized ||
          e.type == ApiErrorType.forbidden) {
        await logout();
      }
    }
  }

  Future<AuthUser> login({required String email, required String password}) {
    return _guardAuth(() async {
      {
        final response = await _wp.post<dynamic>(
          '/simple-jwt-login/v1/auth',
          data: {'email': email, 'password': password},
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );

        final jwt = _extractJwt(response.data);
        if (jwt == null) {
          throw const ApiException(
            type: ApiErrorType.unauthorized,
            message: 'Login failed. Please check your details.',
          );
        }

        _token = jwt;
        try {
          final profile = await _fetchProfile();
          await _secure.write(_tokenKey, jwt);
          await _storage.write(_userKey, profile.toJson());
          user.value = profile;
          return profile;
        } on ApiException {
          _token = null;
          rethrow;
        }
      }
    });
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _guardAuth(() async {
      {
        final response = await _wp.put<dynamic>(
          '/simple-jwt-login/v1/user/reset_password',
          data: {'email': email, 'code': code, 'new_password': newPassword},
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );
        final body = response.data;
        if (body is Map && body['success'] == false) {
          final nested = body['data'];
          final message =
              body['message'] ??
              (nested is Map ? nested['message'] : null) ??
              'Could not reset the password.';
          throw ApiException(
            type: ApiErrorType.validation,
            message: '$message',
          );
        }
      }
    });
  }

  Future<AuthUser> register({
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
  }) {
    return _guardAuth(() async {
      {
        final displayName = '$firstName $lastName'.trim();
        await _wp.post<dynamic>(
          '/simple-jwt-login/v1/users',
          data: {
            'email': email,
            'password': password,
            if (firstName.isNotEmpty) 'first_name': firstName,
            if (lastName.isNotEmpty) 'last_name': lastName,
            if (displayName.isNotEmpty) 'display_name': displayName,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );
        return login(email: email, password: password);
      }
    });
  }

  Future<void> requestPasswordReset(String email) {
    return _guardAuth(() async {
      {
        await _wp.post<dynamic>(
          '/simple-jwt-login/v1/user/reset_password',
          data: {'email': email},
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );
      }
    });
  }

  Future<void> logout() async {
    _token = null;
    user.value = null;
    await _secure.delete(_tokenKey);
    await _storage.remove(_userKey);
  }

  Future<AuthUser> _fetchProfile() async {
    final response = await _wp.get<dynamic>(
      '/wp/v2/users/me',
      query: {'context': 'edit'},
    );
    final data = response.data;
    if (data is! Map) {
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: 'Could not load your profile.',
      );
    }
    return AuthUser.fromJson(Map<String, dynamic>.from(data));
  }

  String? _extractJwt(dynamic body) {
    if (body is! Map) return null;
    if (body['success'] == false) return null;
    final data = body['data'];
    if (data is Map && data['jwt'] != null) return '${data['jwt']}';
    if (body['jwt'] != null) return '${body['jwt']}';
    return null;
  }
}
