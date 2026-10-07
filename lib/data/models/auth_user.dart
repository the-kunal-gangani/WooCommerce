import '../../core/utils/json_utils.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.nicename = '',
    this.avatar = '',
    this.url = '',
    this.phone = '',
    this.role = '',
    this.isAdmin = false,
    this.isVendor = false,
    this.isDeliveryBoy = false,
    this.shipping,
    this.billing,
  });

  final int id;
  final String email;

  final String displayName;
  final String firstName;
  final String lastName;

  final String username;
  final String nicename;
  final String avatar;
  final String url;
  final String phone;

  final String role;

  final bool isAdmin;
  final bool isVendor;
  final bool isDeliveryBoy;

  final Map<String, dynamic>? shipping;
  final Map<String, dynamic>? billing;

  /// Creates our user from the response returned by:
  ///
  /// /wp-json/api/flutter_user/get_currentuserinfo
  factory AuthUser.fromWooJson(Map<String, dynamic> json) {
    final roles = <String>[];

    final rawRole = json['role'];

    if (rawRole is Map) {
      roles.addAll(
        rawRole.values
            .map((value) => value.toString())
            .where((value) => value.isNotEmpty),
      );
    } else if (rawRole is List) {
      roles.addAll(
        rawRole
            .map((value) => value.toString())
            .where((value) => value.isNotEmpty),
      );
    }

    final isAdmin = roles.contains('administrator');

    final isVendor =
        roles.contains('seller') ||
        roles.contains('wcfm_vendor') ||
        roles.contains('administrator') ||
        roles.contains('shop_manager');

    final isDeliveryBoy =
        roles.contains('wcfm_delivery_boy') || roles.contains('driver');

    return AuthUser(
      id: asInt(json['id']),
      email: asString(json['email']),
      displayName: asString(json['displayname']),
      firstName: asString(json['firstname']),
      lastName: asString(json['lastname']),
      username: asString(json['username']),
      nicename: asString(json['nicename']),
      avatar: asString(json['avatar']),
      url: asString(json['url']),
      phone: asString(json['shipping']?['phone'] ?? json['billing']?['phone']),
      role: roles.isNotEmpty ? roles.first : '',
      isAdmin: isAdmin,
      isVendor: isVendor,
      isDeliveryBoy: isDeliveryBoy,
      shipping: json['shipping'] is Map
          ? Map<String, dynamic>.from(json['shipping'])
          : null,
      billing: json['billing'] is Map
          ? Map<String, dynamic>.from(json['billing'])
          : null,
    );
  }

  /// Used when restoring the locally stored user.
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: asInt(json['id']),
      email: asString(json['email']),
      displayName: asString(json['displayName'] ?? json['displayname']),
      firstName: asString(json['firstName'] ?? json['firstname']),
      lastName: asString(json['lastName'] ?? json['lastname']),
      username: asString(json['username']),
      nicename: asString(json['nicename']),
      avatar: asString(json['avatar'] ?? json['picture']),
      url: asString(json['url']),
      phone: asString(json['phone'] ?? json['phoneNumber']),
      role: asString(json['role']),
      isAdmin: json['isAdmin'] == true,
      isVendor: json['isVendor'] == true,
      isDeliveryBoy: json['isDeliveryBoy'] == true,
      shipping: json['shipping'] is Map
          ? Map<String, dynamic>.from(json['shipping'])
          : null,
      billing: json['billing'] is Map
          ? Map<String, dynamic>.from(json['billing'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'nicename': nicename,
      'avatar': avatar,
      'url': url,
      'phone': phone,
      'role': role,
      'isAdmin': isAdmin,
      'isVendor': isVendor,
      'isDeliveryBoy': isDeliveryBoy,
      'shipping': shipping,
      'billing': billing,
    };
  }

  String get fullName {
    final full = '$firstName $lastName'.trim();

    return full.isEmpty ? displayName : full;
  }

  bool get hasShippingAddress {
    return shipping != null && shipping!.isNotEmpty;
  }

  bool get hasBillingAddress {
    return billing != null && billing!.isNotEmpty;
  }
}
