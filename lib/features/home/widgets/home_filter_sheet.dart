import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class HomeFilterSheet extends StatelessWidget {
  const HomeFilterSheet({super.key, required this.controller});

  final HomeController controller;

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);
  static const border = Color(0xFFE5EAF1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D7E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        color: navy,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: controller.resetFilters,
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _sectionTitle('Sort by'),

              const SizedBox(height: 10),

              Obx(() => _buildSortOptions()),

              const SizedBox(height: 24),

              _sectionTitle('Price range'),

              const SizedBox(height: 8),

              Obx(
                () => Column(
                  children: [
                    RangeSlider(
                      min: 0,
                      max: 100000,
                      divisions: 100,
                      values: RangeValues(
                        controller.minPrice.value,
                        controller.maxPrice.value,
                      ),
                      activeColor: primary,
                      inactiveColor: const Color(0xFFDDE5F1),
                      onChanged: (values) {
                        controller.minPrice.value = values.start;
                        controller.maxPrice.value = values.end;
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _priceLabel('₹${controller.minPrice.value.toInt()}'),
                        _priceLabel(
                          controller.maxPrice.value >= 100000
                              ? '₹100,000+'
                              : '₹${controller.maxPrice.value.toInt()}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _sectionTitle('Availability'),

              const SizedBox(height: 10),

              Obx(
                () => _buildToggle(
                  title: 'On sale',
                  subtitle: 'Show discounted products only',
                  icon: Icons.local_offer_outlined,
                  value: controller.saleOnly.value,
                  onChanged: (value) {
                    controller.saleOnly.value = value;
                  },
                ),
              ),

              const SizedBox(height: 10),

              Obx(
                () => _buildToggle(
                  title: 'In stock',
                  subtitle: 'Show currently available products',
                  icon: Icons.inventory_2_outlined,
                  value: controller.inStockOnly.value,
                  onChanged: (value) {
                    controller.inStockOnly.value = value;
                  },
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [primary, violet]),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.20),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();

                      await controller.applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: navy,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _priceLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: muted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSortOptions() {
    final options = [
      ('popularity', 'Most Popular'),
      ('date', 'Newest First'),
      ('price', 'Price: Low to High'),
      ('price-desc', 'Price: High to Low'),
      ('rating', 'Top Rated'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final value = option.$1;
        final label = option.$2;

        final selected = controller.selectedSort.value == value;

        return GestureDetector(
          onTap: () {
            if (value == 'price-desc') {
              controller.selectedSort.value = 'price';
              controller.selectedOrder.value = 'desc';
            } else {
              controller.selectedSort.value = value;
              controller.selectedOrder.value = value == 'price'
                  ? 'asc'
                  : 'desc';
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? primary : border),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: primary),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: primary,
          ),
        ],
      ),
    );
  }
}
