import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/core/network/api_client.dart';
import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/services/secure_storage_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/storage_services.dart';
import 'package:magna_data_ai_ecommerce/core/utils/logger.dart';
import 'package:magna_data_ai_ecommerce/data/models/auth_user.dart';

class AuthService extends GetxService {
  AuthService(this._api, this._secure, this._storage);

  final ApiClient _api;
  final SecureStorageService _secure;
  final StorageService _storage;

  static const String _tokenKey = 'wordpress_session_token';
  static const String _userKey = 'auth_user';
  static const String _rememberMeKey = 'remember_me_enabled';

  final user = Rxn<AuthUser>();
  String? _accessToken;
  Future<void>? _restoring;

  String? get accessToken => _accessToken;
  bool get isLoggedIn => _accessToken != null && user.value != null;

  Future<bool> getRememberMePreference() async =>
      _storage.read<bool>(_rememberMeKey) ?? false;

  Future<void> restore() => _restoring ??= _restore();

  Future<void> _restore() async {
    try {
      if (!await getRememberMePreference()) {
        await logout();
        return;
      }
      _accessToken = await _secure.read(_tokenKey);
      final stored = _storage.read<Map>(_userKey);
      if (stored != null) {
        user.value = AuthUser.fromJson(Map<String, dynamic>.from(stored));
      }
      if (_accessToken == null || _accessToken!.isEmpty) return;

      final currentUser = await _fetchCurrentUser();
      user.value = currentUser;
      await _storage.write(_userKey, currentUser.toJson());
    } on ApiException catch (error) {
      printLog('Session validation failed: $error');
      if (_isUnauthorized(error)) await logout();
    } catch (error) {
      printLog('Auth restore failed: $error');
    }
  }

  Future<AuthUser> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    final previousToken = _accessToken;
    final previousUser = user.value;
    try {
      final response = await _api.post<dynamic>(
        '/auth/login',
        data: {'email': username.trim(), 'password': password},
      );
      final body = _asMap(response.data);
      final token = body['access_token']?.toString();
      if (token == null || token.isEmpty) {
        throw const ApiException(
          type: ApiErrorType.unknown,
          message: 'Login response did not contain a session token.',
        );
      }

      _accessToken = token;
      final currentUser = await _fetchCurrentUser();
      user.value = currentUser;
      await _storage.write(_rememberMeKey, rememberMe);
      if (rememberMe) {
        await _secure.write(_tokenKey, token);
      } else {
        await _secure.delete(_tokenKey);
      }
      if (rememberMe) {
        await _storage.write(_userKey, currentUser.toJson());
      } else {
        await _storage.remove(_userKey);
      }
      return currentUser;
    } on ApiException {
      _accessToken = previousToken;
      user.value = previousUser;
      rethrow;
    } on DioException catch (error) {
      _accessToken = previousToken;
      user.value = previousUser;
      throw _toApiException(error);
    } catch (error) {
      _accessToken = previousToken;
      user.value = previousUser;
      printLog('Login failed: $error');
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: 'Unable to sign in. Please try again.',
      );
    }
  }

  Future<AuthUser> register({
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
    String username = '',
    String phone = '',
  }) async {
    try {
      await _api.post<dynamic>(
        '/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'full_name': '$firstName $lastName'.trim(),
          if (phone.isNotEmpty) 'phone': phone.trim(),
        },
      );
      return await login(username: email, password: password);
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<AuthUser> _fetchCurrentUser() async {
    try {
      final response = await _api.get<dynamic>('/auth/me');
      return AuthUser.fromApiJson(_asMap(response.data));
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<AuthUser> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    try {
      final response = await _api.patch<dynamic>(
        '/auth/me',
        data: {'full_name': fullName.trim(), 'phone': phone.trim()},
      );
      final updatedUser = AuthUser.fromApiJson(_asMap(response.data));
      user.value = updatedUser;
      await _storage.write(_userKey, updatedUser.toJson());
      return updatedUser;
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await _api.post<dynamic>(
        '/auth/forgot-password',
        data: {'email': email.trim()},
      );
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String key,
    required String password,
  }) async {
    try {
      await _api.post<dynamic>(
        '/auth/reset-password',
        data: {'login': email.trim(), 'key': key.trim(), 'password': password},
      );
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<void> logout() async {
    if (_accessToken != null) {
      try {
        await _api.post<dynamic>('/auth/logout');
      } catch (_) {
        // Local session cleanup must still complete if the remote token expired.
      }
    }
    _accessToken = null;
    user.value = null;
    await _secure.delete(_tokenKey);
    await _storage.remove(_userKey);
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  ApiException _toApiException(DioException error) {
    final statusCode = error.response?.statusCode;
    final body = error.response?.data;
    final detail = body is Map
        ? (body['detail'] ?? body['message'] ?? body['error'])
        : null;
    final message = detail?.toString() ?? 'Unable to connect to the server.';
    final type = switch (statusCode) {
      401 => ApiErrorType.unauthorized,
      403 => ApiErrorType.forbidden,
      404 => ApiErrorType.notFound,
      400 || 409 || 422 => ApiErrorType.validation,
      final code when code != null && code >= 500 => ApiErrorType.server,
      _ => ApiErrorType.unknown,
    };
    return ApiException(type: type, message: message, statusCode: statusCode);
  }

  bool _isUnauthorized(ApiException error) =>
      error.type == ApiErrorType.unauthorized ||
      error.type == ApiErrorType.forbidden;
}
