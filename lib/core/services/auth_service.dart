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

  static const String _tokenKey = 'fastapi_access_token';
  static const String _userKey = 'auth_user';

  final user = Rxn<AuthUser>();

  String? _accessToken;
  Future<void>? _restoring;

  String? get accessToken => _accessToken;

  bool get isLoggedIn => _accessToken != null && user.value != null;

  Future<void> restore() {
    return _restoring ??= _restore();
  }

  Future<void> _restore() async {
    try {
      _accessToken = await _secure.read(_tokenKey);

      if (_accessToken == null || _accessToken!.isEmpty) {
        return;
      }

      final stored = _storage.read<Map>(_userKey);
      if (stored != null) {
        user.value = AuthUser.fromJson(Map<String, dynamic>.from(stored));
      }

      try {
        final currentUser = await _fetchCurrentUser();
        user.value = currentUser;
        await _storage.write(_userKey, currentUser.toJson());
      } on ApiException catch (e) {
        printLog('Session validation failed: $e');

        if (_isUnauthorized(e)) {
          await logout();
        }
      }
    } catch (e) {
      printLog('Auth restore failed: $e');
    }
  }

  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _api.post<dynamic>(
        '/auth/login',
        data: {'email': username.trim(), 'password': password},
      );

      final body = _asMap(response.data);
      final token = _extractToken(body);

      if (token == null || token.isEmpty) {
        throw const ApiException(
          type: ApiErrorType.unknown,
          message: 'Login response did not contain an access token.',
        );
      }

      _accessToken = token;
      await _secure.write(_tokenKey, token);

      try {
        final currentUser = await _fetchCurrentUser();

        user.value = currentUser;
        await _storage.write(_userKey, currentUser.toJson());

        return currentUser;
      } catch (_) {
        await _secure.delete(_tokenKey);
        _accessToken = null;
        user.value = null;
        rethrow;
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      printLog('Login failed: $e');
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
      final fullName = '$firstName $lastName'.trim();

      await _api.post<dynamic>(
        '/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          if (fullName.isNotEmpty) 'full_name': fullName,
        },
      );

      // Registration and login are separate operations.
      // Authenticate the new account to obtain an access token.
      return await login(username: email, password: password);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      printLog('Registration failed: $e');
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: 'Unable to create your account. Please try again.',
      );
    }
  }

  Future<AuthUser> _fetchCurrentUser() async {
    final token = _accessToken;

    if (token == null || token.isEmpty) {
      throw const ApiException(
        type: ApiErrorType.unauthorized,
        message: 'Authentication session not found.',
      );
    }

    try {
      final response = await _api.get<dynamic>(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final body = _asMap(response.data);
      final rawUser = body['user'] ?? body['data'] ?? body;

      if (rawUser is Map) {
        return AuthUser.fromApiJson(Map<String, dynamic>.from(rawUser));
      }

      throw const ApiException(
        type: ApiErrorType.unknown,
        message: 'Could not load your profile.',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<AuthUser> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final token = _accessToken;

    if (token == null || token.isEmpty) {
      throw const ApiException(
        type: ApiErrorType.unauthorized,
        message: 'Please sign in again to update your profile.',
      );
    }

    try {
      final response = await _api.patch<dynamic>(
        '/auth/me',
        data: {'full_name': fullName.trim(), 'phone': phone.trim()},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final body = _asMap(response.data);
      final rawUser = body['user'] ?? body['data'] ?? body;

      if (rawUser is! Map) {
        throw const ApiException(
          type: ApiErrorType.unknown,
          message: 'Could not read the updated profile.',
        );
      }

      final updatedUser = AuthUser.fromApiJson(
        Map<String, dynamic>.from(rawUser),
      );

      user.value = updatedUser;
      await _storage.write(_userKey, updatedUser.toJson());

      return updatedUser;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _toApiException(e);
    } catch (e) {
      printLog('Profile update failed: $e');

      throw const ApiException(
        type: ApiErrorType.unknown,
        message: 'Unable to update your profile. Please try again.',
      );
    }
  }

  Future<void> requestPasswordReset(String email) async {
    throw const ApiException(
      type: ApiErrorType.unknown,
      message: 'Password reset is not yet available through the new backend.',
    );
  }

  Future<void> logout() async {
    _accessToken = null;
    user.value = null;

    await _secure.delete(_tokenKey);
    await _storage.remove(_userKey);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String? _extractToken(Map<String, dynamic> body) {
    final data = body['data'];
    final nested = data is Map ? Map<String, dynamic>.from(data) : null;

    final value = body['access_token'] ?? nested?['access_token'];

    return value?.toString();
  }

  ApiException _toApiException(DioException error) {
    final statusCode = error.response?.statusCode;
    final body = error.response?.data;

    String message = 'Unable to connect to the server. Please try again.';

    if (body is Map) {
      final detail = body['detail'] ?? body['message'];

      if (detail is String && detail.isNotEmpty) {
        message = detail;
      } else if (detail is List && detail.isNotEmpty) {
        message = detail
            .map(
              (item) => item is Map
                  ? (item['msg'] ?? item.toString()).toString()
                  : item.toString(),
            )
            .join('\n');
      }
    }

    if (statusCode == 401) {
      return ApiException(type: ApiErrorType.unauthorized, message: message);
    }

    if (statusCode == 403) {
      return ApiException(type: ApiErrorType.forbidden, message: message);
    }

    return ApiException(type: ApiErrorType.unknown, message: message);
  }

  bool _isUnauthorized(ApiException e) {
    return e.type == ApiErrorType.unauthorized ||
        e.type == ApiErrorType.forbidden;
  }
}
