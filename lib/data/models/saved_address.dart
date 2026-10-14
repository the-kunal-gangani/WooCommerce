class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.addressType,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address1,
    this.address2,
    this.company,
    required this.city,
    required this.state,
    required this.postcode,
    this.country = 'IN',
    required this.isDefault,
  });

  final int id;
  final String label;
  final String addressType;
  final String firstName;
  final String lastName;
  final String phone;
  final String address1;
  final String? address2;
  final String? company;
  final String city;
  final String state;
  final String postcode;
  final String country;
  final bool isDefault;

  String get fullName => '$firstName $lastName'.trim();

  String get formattedAddress {
    return [
      address1,
      address2,
      city,
      state,
      postcode,
      country,
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');
  }

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] as int,
      label: json['label'] as String? ?? 'Home',
      addressType: json['address_type'] as String? ?? 'shipping',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address1: json['address1'] as String? ?? '',
      address2: json['address2'] as String?,
      company: json['company'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postcode: json['postcode'] as String? ?? '',
      country: json['country'] as String? ?? 'IN',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'address_type': addressType,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'address1': address1,
      'address2': address2,
      'company': company,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
      'is_default': isDefault,
    };
  }
}
