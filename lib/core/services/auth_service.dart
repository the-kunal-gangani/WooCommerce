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

  static const String _cookieKey = 'woo_auth_cookie';
  static const String _userKey = 'auth_user';

  final user = Rxn<AuthUser>();

  String? _cookie;

  Future<void>? _restoring;

  String? get cookie => _cookie;

  bool get isLoggedIn => _cookie != null && user.value != null;

  Future<void> restore() {
    return _restoring ??= _restore();
  }

  Future<void> _restore() async {
    try {
      _cookie = await _secure.read(_cookieKey);
      if (_cookie == null || _cookie!.isEmpty) {
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
      final response = await _wp.post<dynamic>(
        '/wp-json/api/flutter_user/generate_auth_cookie/',
        query: {'insecure': 'cool'},
        data: {
          'seconds': '120960000000',
          'username': username,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final cookie = _extractCookie(response.data);
      if (cookie == null || cookie.isEmpty) {
        throw const ApiException(
          type: ApiErrorType.unauthorized,
          message: 'Login failed. Please check your details.',
        );
      }
      _cookie = cookie;
      try {
        final currentUser = await _fetchCurrentUser();
        await _secure.write(_cookieKey, cookie);
        await _storage.write(_userKey, currentUser.toJson());
        user.value = currentUser;
        return currentUser;
      } catch (_) {
        _cookie = null;
        rethrow;
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      printLog('Login failed: $e');

      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Unable to sign in. Please try again.',
      );
    }
  }

  Future<AuthUser> _fetchCurrentUser() async {
    if (_cookie == null || _cookie!.isEmpty) {
      throw const ApiException(
        type: ApiErrorType.unauthorized,
        message: 'Authentication session not found.',
      );
    }

    final response = await _wp.get<dynamic>(
      '/wp-json/api/flutter_user/get_currentuserinfo',
      query: {'token': _encodeCookie(_cookie!)},
      options: Options(headers: {'User-Cookie': _cookie}),
    );
    
    final body = response.data;
    if (body is! Map) {
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: 'Could not load your profile.',
      );
    }
    final rawUser = body['user'];
    if (rawUser is Map) {
      return AuthUser.fromWooJson(Map<String, dynamic>.from(rawUser));
    }
    final message = body['message'];
    if (message != null) {
      throw ApiException(
        type: ApiErrorType.unauthorized,
        message: message.toString(),
      );
    }

    throw const ApiException(
      type: ApiErrorType.unknown,
      message: 'Could not load your profile.',
    );
  }

  Future<AuthUser> register({
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
    String username = '',
    String phone = '',
  }) async {
    final displayName = '$firstName $lastName'.trim();
    final response = await _wp.post<dynamic>(
      '/wp-json/api/flutter_user/sign_up/',
      data: {
        'user_email': email,
        'user_login': username.isNotEmpty ? username : email,
        'username': username.isNotEmpty ? username : email,
        'user_pass': password,
        'email': email,
        if (displayName.isNotEmpty) 'display_name': displayName,
        if (phone.isNotEmpty) 'phone': phone,
        if (firstName.isNotEmpty) 'first_name': firstName,
        if (lastName.isNotEmpty) 'last_name': lastName,
      },
      options: Options(contentType: Headers.jsonContentType),
    );
    final cookie = _extractCookie(response.data);
    if (cookie == null || cookie.isEmpty) {
      throw const ApiException(
        type: ApiErrorType.unknown,
        message: 'Account created, but we could not sign you in.',
      );
    }

    _cookie = cookie;
    final currentUser = await _fetchCurrentUser();
    await _secure.write(_cookieKey, cookie);
    await _storage.write(_userKey, currentUser.toJson());
    user.value = currentUser;
    return currentUser;
  }

  Future<void> requestPasswordReset(String email) async {
    await _wp.post<dynamic>(
      '/wp-json/api/flutter_user/reset-password',
      data: {'user_login': email},
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<void> logout() async {
    _cookie = null;
    user.value = null;
    await _secure.delete(_cookieKey);
    await _storage.remove(_userKey);
  }

  String? _extractCookie(dynamic body) {
    if (body is! Map) {
      return null;
    }
    if (body['cookie'] != null) {
      return body['cookie'].toString();
    }
    final data = body['data'];
    if (data is Map && data['cookie'] != null) {
      return data['cookie'].toString();
    }
    return null;
  }

  String _encodeCookie(String cookie) {
    // FluxStore uses EncodeUtils.encodeCookie().
    //
    // The exact EncodeUtils implementation was not available
    // in the extracted source, so do not invent an algorithm here.
    return cookie;
  }

  bool _isUnauthorized(ApiException e) {
    return e.type == ApiErrorType.unauthorized ||
        e.type == ApiErrorType.forbidden;
  }
}
