import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/data/models/saved_address.dart';

import 'address_controller.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, this.address});

  final SavedAddress? address;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final AddressController controller;

  late final TextEditingController label;
  late final TextEditingController firstName;
  late final TextEditingController lastName;
  late final TextEditingController phone;
  late final TextEditingController address1;
  late final TextEditingController address2;
  late final TextEditingController company;
  late final TextEditingController city;
  late final TextEditingController state;
  late final TextEditingController postcode;

  late String addressType;
  late bool isDefault;

  static const Color _primary = Color(0xFF315CDE);

  @override
  void initState() {
    super.initState();

    controller = Get.find<AddressController>();
    final address = widget.address;

    label = TextEditingController(text: address?.label ?? 'Home');
    firstName = TextEditingController(text: address?.firstName ?? '');
    lastName = TextEditingController(text: address?.lastName ?? '');
    phone = TextEditingController(text: address?.phone ?? '');
    address1 = TextEditingController(text: address?.address1 ?? '');
    address2 = TextEditingController(text: address?.address2 ?? '');
    company = TextEditingController(text: address?.company ?? '');
    city = TextEditingController(text: address?.city ?? '');
    state = TextEditingController(text: address?.state ?? '');
    postcode = TextEditingController(text: address?.postcode ?? '');

    addressType = address?.addressType ?? 'shipping';
    isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    label.dispose();
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
    address1.dispose();
    address2.dispose();
    company.dispose();
    city.dispose();
    state.dispose();
    postcode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.address != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(editing ? 'Edit Address' : 'Add Address'),
        backgroundColor: const Color(0xFFF7F9FC),
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _field(label, 'Address label', hint: 'Home, Work, etc.'),
            _field(firstName, 'First name'),
            _field(lastName, 'Last name', required: false),
            _field(phone, 'Phone number', keyboardType: TextInputType.phone),
            _field(address1, 'Address line 1'),
            _field(address2, 'Address line 2', required: false),
            _field(company, 'Company', required: false),
            _field(city, 'City'),
            _field(state, 'State'),
            _field(postcode, 'Postal code', keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: addressType,
              decoration: const InputDecoration(
                labelText: 'Address type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'shipping', child: Text('Shipping')),
                DropdownMenuItem(value: 'billing', child: Text('Billing')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => addressType = value);
                }
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Set as default'),
              subtitle: const Text(
                'Use as the default address for this address type.',
              ),
              value: isDefault,
              activeThumbColor: _primary,
              onChanged: (value) {
                setState(() => isDefault = value);
              },
            ),
            const SizedBox(height: 20),
            Obx(
              () => FilledButton(
                onPressed: controller.isSaving.value ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: controller.isSaving.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(editing ? 'Save changes' : 'Save address'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController textController,
    String title, {
    String? hint,
    bool required = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: textController,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: title,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return '$title is required';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'label': label.text.trim(),
      'address_type': addressType,
      'first_name': firstName.text.trim(),
      'last_name': lastName.text.trim(),
      'phone': phone.text.trim(),
      'address1': address1.text.trim(),
      'address2': address2.text.trim().isEmpty ? null : address2.text.trim(),
      'company': company.text.trim().isEmpty ? null : company.text.trim(),
      'city': city.text.trim(),
      'state': state.text.trim(),
      'postcode': postcode.text.trim(),
      'country': 'IN',
      'is_default': isDefault,
    };

    await controller.saveAddress(id: widget.address?.id, payload: payload);
  }
}
