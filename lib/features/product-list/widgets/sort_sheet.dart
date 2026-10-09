import 'package:flutter/material.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_filter.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFD5DBE5),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class SortOptionTile extends StatelessWidget {
  const SortOptionTile({
    super.key,
    required this.sort,
    required this.selected,
    required this.onTap,
  });

  final ProductSort sort;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2563EB);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? primary : const Color(0xFF9AA4B2),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sort.label,
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SortSheet extends StatelessWidget {
  const SortSheet({super.key, required this.controller});

  final ProductListController controller;

  static Future<void> show(
    BuildContext context,
    ProductListController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SortSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = controller.filter.value.sort;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            const SizedBox(height: 14),
            const Text(
              'Sort by',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            for (final sort in ProductSort.values)
              SortOptionTile(
                sort: sort,
                selected: sort == current,
                onTap: () {
                  controller.applyFilter(
                    controller.filter.value.copyWith(sort: sort),
                  );
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
