import '../../core/utils/json_utils.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.firstName = '',
    this.lastName = '',
  });

  final int id;
  final String email;
  final String displayName;
  final String firstName;
  final String lastName;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: asInt(json['id']),
      email: asString(json['email']),
      displayName: asString(json['name'] ?? json['displayName']),
      firstName: asString(json['first_name'] ?? json['firstName']),
      lastName: asString(json['last_name'] ?? json['lastName']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'firstName': firstName,
    'lastName': lastName,
  };

  String get fullName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? displayName : full;
  }
}
