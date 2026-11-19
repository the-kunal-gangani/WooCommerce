import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/product_card.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'search_discovery_controller.dart';

class SearchDiscoveryScreen extends GetView<SearchDiscoveryController> {
  const SearchDiscoveryScreen({super.key});

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const primary = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: navy,
            size: 20,
          ),
        ),
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: controller.onQueryChanged,
          onSubmitted: controller.submitSearch,
          style: const TextStyle(
            color: navy,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            hintText: 'Search products, brands & more',
            hintStyle: TextStyle(color: Color(0xFF9AA4B2)),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
      body: Obx(() {
        final query = controller.query.value.trim();
        if (query.isNotEmpty) {
          return _buildSearchResults(context);
        }
        return _buildDiscovery();
      }),
    );
  }

  Widget _buildDiscovery() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const Text(
          'Popular Searches',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SearchDiscoveryController.popularSearches.map((term) {
            return ActionChip(
              label: Text(term),
              onPressed: () => controller.submitSearch(term),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE7EBF1)),
              labelStyle: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Recommended for You',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isRecommendationsLoading.value) {
            return _RecommendationSkeleton();
          }
          if (controller.recommendationsFailed.value) {
            return _SearchMessage(
              icon: Icons.cloud_off_outlined,
              message: 'Recommended products could not be loaded.',
              actionLabel: 'Try again',
              onAction: controller.loadRecommendations,
            );
          }
          if (controller.recommendations.isEmpty) {
            return const _SearchMessage(
              icon: Icons.inbox_outlined,
              message: 'No recommendations available right now.',
            );
          }
          return _ProductGrid(
            products: controller.recommendations,
            onProductTap: controller.openProduct,
          );
        }),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (controller.isSearchLoading.value) {
      return const _RecommendationSkeleton();
    }
    if (controller.searchResults.isEmpty) {
      return _SearchMessage(
        icon: Icons.search_off_rounded,
        message: controller.searchError.value ??
            'Start typing to find products.',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: controller.searchResults.length,
      itemBuilder: (_, index) {
        final product = controller.searchResults[index];
        return ProductCard(
          product: product,
          onTap: () => controller.openProduct(product),
        );
      },
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.onProductTap,
  });

  final RxList<Product> products;
  final void Function(Product) onProductTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => onProductTap(product),
        );
      },
    );
  }
}

class _RecommendationSkeleton extends StatelessWidget {
  const _RecommendationSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: 6,
      itemBuilder: (_, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: const Color(0xFFE8EDF4),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 80,
                        color: const Color(0xFFE8EDF4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: const Color(0xFF9AA4B2)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF687386),
                fontSize: 14,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: SearchDiscoveryScreen.primary,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
