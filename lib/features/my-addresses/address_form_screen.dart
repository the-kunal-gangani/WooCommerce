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

  static const Color _background = Color(0xFFF7F9FC);
  static const Color _navy = Color(0xFF111827);
  static const Color _muted = Color(0xFF687386);
  static const Color _primary = Color(0xFF2563EB);
  static const Color _violet = Color(0xFF6D4AFF);
  static const Color _border = Color(0xFFE7EBF1);

  bool get _editing => widget.address != null;

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
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 24),

                    _buildFormSection(
                      title: 'Address details',
                      subtitle: 'Give this address a name and choose its type.',
                      icon: Icons.bookmark_outline_rounded,
                      children: [
                        _field(
                          label,
                          'Address label',
                          hint: 'Home, Work, etc.',
                          prefixIcon: Icons.label_outline_rounded,
                        ),
                        _buildAddressTypeSelector(),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _buildFormSection(
                      title: 'Contact information',
                      subtitle:
                          'Who should receive deliveries at this address?',
                      icon: Icons.person_outline_rounded,
                      children: [
                        _field(
                          firstName,
                          'First name',
                          prefixIcon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                        ),
                        _field(
                          lastName,
                          'Last name',
                          required: false,
                          prefixIcon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                        ),
                        _field(
                          phone,
                          'Phone number',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          textCapitalization: TextCapitalization.none,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _buildFormSection(
                      title: 'Delivery address',
                      subtitle:
                          'Enter the complete address for accurate delivery.',
                      icon: Icons.location_on_outlined,
                      children: [
                        _field(
                          address1,
                          'Address line 1',
                          hint: 'House number, street, area',
                          prefixIcon: Icons.home_outlined,
                        ),
                        _field(
                          address2,
                          'Address line 2',
                          hint: 'Landmark, apartment, etc.',
                          required: false,
                          prefixIcon: Icons.signpost_outlined,
                        ),
                        _field(
                          company,
                          'Company',
                          required: false,
                          prefixIcon: Icons.business_outlined,
                        ),
                        _field(
                          city,
                          'City',
                          prefixIcon: Icons.location_city_outlined,
                        ),
                        _field(state, 'State', prefixIcon: Icons.map_outlined),
                        _field(
                          postcode,
                          'Postal code',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.markunread_mailbox_outlined,
                        ),
                        _buildCountryTile(),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _buildDefaultSection(),

                    const SizedBox(height: 26),

                    Obx(
                      () => SizedBox(
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: controller.isSaving.value
                                ? null
                                : const LinearGradient(
                                    colors: [_primary, _violet],
                                  ),
                            color: controller.isSaving.value ? _primary : null,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (!controller.isSaving.value)
                                BoxShadow(
                                  color: _primary.withValues(alpha: 0.20),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                            ],
                          ),
                          child: FilledButton.icon(
                            onPressed: controller.isSaving.value ? null : _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor: _primary,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: controller.isSaving.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _editing
                                        ? Icons.check_rounded
                                        : Icons.add_location_alt_outlined,
                                    size: 20,
                                  ),
                            label: Text(
                              controller.isSaving.value
                                  ? 'Saving address...'
                                  : _editing
                                  ? 'Save changes'
                                  : 'Save address',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: _muted,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Your address details are used for order delivery.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _muted,
                              fontSize: 10,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: _navy,
                  size: 21,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editing ? 'Edit Address' : 'Add Address',
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your delivery, your destination',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_primary, _violet]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _violet],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editing ? 'Update your details' : 'Where should we deliver?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _editing
                      ? 'Keep your saved address accurate and up to date.'
                      : 'Add your address for a smoother checkout experience.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primary.withValues(alpha: 0.12),
                      _violet.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primary, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController textController,
    String title, {
    String? hint,
    bool required = true,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: textController,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: const TextStyle(
          color: _navy,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: title,
          hintText: hint,
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, size: 19, color: _muted),
          labelStyle: const TextStyle(color: _muted, fontSize: 12),
          floatingLabelStyle: const TextStyle(
            color: _primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: const TextStyle(color: Color(0xFF9AA4B2), fontSize: 12),
          filled: true,
          fillColor: _background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _primary, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
          ),
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

  Widget _buildAddressTypeSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address type',
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _typeOption(
                  label: 'Shipping',
                  subtitle: 'Deliver orders',
                  icon: Icons.local_shipping_outlined,
                  value: 'shipping',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _typeOption(
                  label: 'Billing',
                  subtitle: 'Billing details',
                  icon: Icons.receipt_long_outlined,
                  value: 'billing',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final selected = addressType == value;

    return Material(
      color: selected ? const Color(0xFFF1F5FF) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => setState(() => addressType = value),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _primary : _border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : icon,
                color: selected ? _primary : _muted,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: selected ? _primary : _navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryTile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: const Row(
          children: [
            Icon(Icons.public_rounded, color: _muted, size: 19),
            SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Country',
                    style: TextStyle(color: _muted, fontSize: 10),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'India',
                    style: TextStyle(
                      color: _navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.lock_outline_rounded, size: 16, color: _muted),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primary.withValues(alpha: 0.12),
                  _violet.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: _primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set as default',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Use this address by default for this address type.',
                  style: TextStyle(color: _muted, fontSize: 10, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: isDefault,
            activeTrackColor: _primary,
            onChanged: (value) {
              setState(() => isDefault = value);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

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
