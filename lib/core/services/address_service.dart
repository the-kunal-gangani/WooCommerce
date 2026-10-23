import 'package:magna_data_ai_ecommerce/core/network/api_client.dart';
import 'package:magna_data_ai_ecommerce/core/services/auth_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/saved_address.dart';

class AddressService {
  AddressService(this._apiClient, this._authService);

  final ApiClient _apiClient;
  final AuthService _authService;

  void _requireAuthentication() {
    if (!_authService.isLoggedIn) {
      throw Exception('Please log in to manage your addresses.');
    }
  }

  Future<List<SavedAddress>> getAddresses({String? addressType}) async {
    _requireAuthentication();
    final response = await _apiClient.get(
      '/addresses',
      query: {'address_type': ?addressType},
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final items = data['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map>()
        .map((item) => SavedAddress.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<SavedAddress> createAddress(Map<String, dynamic> payload) async {
    _requireAuthentication();
    final response = await _apiClient.post('/addresses', data: payload);
    return SavedAddress.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<SavedAddress> updateAddress(
    int id,
    Map<String, dynamic> payload,
  ) async {
    _requireAuthentication();
    final response = await _apiClient.patch('/addresses/$id', data: payload);
    return SavedAddress.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> deleteAddress(int id) async {
    _requireAuthentication();
    await _apiClient.delete('/addresses/$id');
  }

  Future<SavedAddress> setDefaultAddress(int id) async {
    _requireAuthentication();
    final response = await _apiClient.put('/addresses/$id/default');
    return SavedAddress.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
