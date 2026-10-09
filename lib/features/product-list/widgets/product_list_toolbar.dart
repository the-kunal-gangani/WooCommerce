import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/widgets/filter_sheet.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/widgets/sort_sheet.dart';

class ProductListToolbar extends StatelessWidget {
  const ProductListToolbar({super.key, required this.controller});

  final ProductListController controller;

  static const navy = Color(0xFF111827);
  static const primary = Color(0xFF2563EB);
  static const border = Color(0xFFE6EAF0);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sort = controller.filter.value.sort;
      final chips = controller.activeChips;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _ToolbarButton(
                    icon: Icons.tune_rounded,
                    label: 'Filters',
                    badge: chips.length,
                    onTap: () => FilterSheet.show(context, controller),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ToolbarButton(
                    icon: Icons.swap_vert_rounded,
                    label: 'Sort: ${sort.shortLabel}',
                    onTap: () => SortSheet.show(context, controller),
                  ),
                ),
              ],
            ),
          ),
          if (chips.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final chip in chips)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InputChip(
                        label: Text(chip.label),
                        onDeleted: chip.onRemove,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: border),
                        labelStyle: const TextStyle(
                          color: navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        deleteIconColor: const Color(0xFF687386),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: controller.clearFilters,
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
        ],
      );
    });
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ProductListToolbar.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: ProductListToolbar.navy),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ProductListToolbar.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (badge > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: ProductListToolbar.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}