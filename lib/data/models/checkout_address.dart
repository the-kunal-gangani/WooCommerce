class CheckoutAddress {
  const CheckoutAddress({
    required this.fullName,
    required this.phone,
    required this.address1,
    required this.city,
    required this.state,
    required this.postcode,
    this.country = 'IN',
  });

  final String fullName;
  final String phone;
  final String address1;
  final String city;
  final String state;
  final String postcode;
  final String country;

  Map<String, dynamic> toJson() {
    final nameParts = fullName.trim().split(RegExp(r'\s+'));

    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return {
      'first_name': firstName,
      'last_name': lastName,
      'address_1': address1,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
      'phone': phone,
    };
  }
}
