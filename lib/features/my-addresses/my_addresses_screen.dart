import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/data/models/saved_address.dart';

import 'address_controller.dart';
import 'address_form_screen.dart';

class MyAddressesScreen extends GetView<AddressController> {
  const MyAddressesScreen({super.key});

  static const Color _background = Color(0xFFF7F9FC);
  static const Color _primary = Color(0xFF315CDE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'My Addresses',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: controller.loadAddresses,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.addresses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.addresses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 72,
                    color: _primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No saved addresses yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add an address to make checkout easier.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _openForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add address'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadAddresses,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              const Text(
                'Manage your shipping and billing details.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ...controller.addresses.map(
                (address) => _addressCard(context, address),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add address'),
      ),
    );
  }

  Widget _addressCard(BuildContext context, SavedAddress address) {
    final isShipping = address.addressType == 'shipping';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isShipping
                      ? Icons.local_shipping_outlined
                      : Icons.receipt_long_outlined,
                  color: _primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${address.fullName}\n${address.formattedAddress}\n${address.phone}',
              style: const TextStyle(height: 1.55),
            ),
            const SizedBox(height: 8),
            Text(
              isShipping ? 'Shipping address' : 'Billing address',
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => _openForm(context, address: address),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                if (!address.isDefault)
                  TextButton(
                    onPressed: () => controller.setDefault(address),
                    child: const Text('Set default'),
                  ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(address),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {SavedAddress? address}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddressFormScreen(address: address),
      ),
    );
  }

  void _confirmDelete(SavedAddress address) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete address?'),
        content: const Text(
          'This address will be permanently removed from your saved addresses.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAddress(address);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
