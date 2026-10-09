import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/data/models/product_filter.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/widgets/sort_sheet.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.controller});

  final ProductListController controller;

  static Future<void> show(
    BuildContext context,
    ProductListController controller,
  ) async {
    controller.loadFilterOptions();
    final result = await showModalBottomSheet<ProductFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(controller: controller),
    );
    if (result != null) {
      controller.applyFilter(result);
    }
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  static const navy = Color(0xFF111827);
  // static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const border = Color(0xFFE6EAF0);

  late ProductFilter _draft;

  ProductListController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _draft = _controller.filter.value;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Obx(_buildContent),
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
      child: Column(
        children: [
          const SheetHandle(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filters',
                  style: TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: navy),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final bounds = _controller.priceBounds.value;
    final categories = _controller.categories.toList();
    final attributes = _controller.attributes.toList();
    final loading = _controller.isLoadingOptions.value;
    final failed = _controller.optionsFailed.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Section(
          title: 'Sort by',
          child: Column(
            children: [
              for (final sort in ProductSort.values)
                SortOptionTile(
                  sort: sort,
                  selected: _draft.sort == sort,
                  onTap: () =>
                      setState(() => _draft = _draft.copyWith(sort: sort)),
                ),
            ],
          ),
        ),
        if (bounds != null && bounds.isUsable)
          _Section(title: 'Price range', child: _buildPriceSlider(bounds)),
        _Section(
          title: 'Availability',
          child: Column(
            children: [
              CheckboxListTile(
                value: _draft.onSale,
                onChanged: (value) => setState(
                  () => _draft = _draft.copyWith(onSale: value ?? false),
                ),
                title: const Text('On Sale'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: primary,
              ),
              CheckboxListTile(
                value: _draft.featured,
                onChanged: (value) => setState(
                  () => _draft = _draft.copyWith(featured: value ?? false),
                ),
                title: const Text('Featured'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: primary,
              ),
            ],
          ),
        ),
        if (categories.isNotEmpty)
          _Section(
            title: 'Categories',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in categories)
                  _OptionChip(
                    label: category.name,
                    selected: _draft.categoryIds.contains(category.id),
                    onTap: () => _toggleCategory(category.id),
                  ),
              ],
            ),
          ),
        for (final attribute in attributes)
          _Section(
            title: attribute.name,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final term in attribute.terms)
                  _OptionChip(
                    label: term.name,
                    selected:
                        _draft.attributeTerms[attribute.taxonomy]?.contains(
                          term.id,
                        ) ??
                        false,
                    onTap: () => _toggleTerm(attribute.taxonomy, term.id),
                  ),
              ],
            ),
          ),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (failed && !loading)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton(
              onPressed: () => _controller.loadFilterOptions(force: true),
              child: const Text('Could not load all options. Tap to retry'),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSlider(PriceBounds bounds) {
    final currency = bounds.currency;
    final unit = math.pow(10, currency.minorUnit).toInt();
    final sliderMin = (bounds.min / unit).floorToDouble();
    final sliderMax = (bounds.max / unit).ceilToDouble();
    final low = _draft.minPrice == null
        ? sliderMin
        : (_draft.minPrice! / unit).clamp(sliderMin, sliderMax).toDouble();
    final high = _draft.maxPrice == null
        ? sliderMax
        : (_draft.maxPrice! / unit).clamp(sliderMin, sliderMax).toDouble();
    final values = RangeValues(math.min(low, high), math.max(low, high));

    return Column(
      children: [
        RangeSlider(
          values: values,
          min: sliderMin,
          max: sliderMax,
          onChanged: (next) {
            final lo = next.start.round();
            final hi = next.end.round();
            setState(() {
              _draft = _draft.copyWith(
                minPrice: lo <= sliderMin ? null : lo * unit,
                maxPrice: hi >= sliderMax ? null : hi * unit,
              );
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PriceTag(label: currency.format(values.start.round() * unit)),
            _PriceTag(label: currency.format(values.end.round() * unit)),
          ],
        ),
      ],
    );
  }

  void _toggleCategory(int id) {
    final next = {..._draft.categoryIds};
    if (!next.add(id)) {
      next.remove(id);
    }
    setState(() => _draft = _draft.copyWith(categoryIds: next));
  }

  void _toggleTerm(String taxonomy, int termId) {
    final terms = {
      for (final e in _draft.attributeTerms.entries) e.key: {...e.value},
    };
    final set = terms.putIfAbsent(taxonomy, () => <int>{});
    if (!set.add(termId)) {
      set.remove(termId);
    }
    if (set.isEmpty) {
      terms.remove(taxonomy);
    }
    setState(() => _draft = _draft.copyWith(attributeTerms: terms));
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    setState(() => _draft = _controller.baseFilter),
                style: OutlinedButton.styleFrom(
                  foregroundColor: navy,
                  side: const BorderSide(color: border),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Clear All',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_draft),
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _FilterSheetState.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _FilterSheetState.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? _FilterSheetState.primary
                : _FilterSheetState.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF536075),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _FilterSheetState.primary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}