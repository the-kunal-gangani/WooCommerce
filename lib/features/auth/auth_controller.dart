import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/core/network/api_exception.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/auth_user.dart';

class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthService _authService;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  AuthUser? get user => _authService.user.value;

  bool get isLoggedIn => _authService.isLoggedIn;

  Future<void> restoreSession() async {
    await _authService.restore();
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      await _authService.login(username: username, password: password);

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Unable to sign in. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
    String username = '',
    String phone = '',
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        username: username,
        phone: phone,
      );

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Unable to create your account.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      await _authService.requestPasswordReset(email);

      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Unable to send the password reset request.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    errorMessage.value = null;
  }

  void clearError() {
    errorMessage.value = null;
  }
}
