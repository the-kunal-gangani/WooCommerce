import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/product_card.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/state_views.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/widgets/product_list_toolbar.dart';

class ProductListScreen extends GetView<ProductListController> {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = controller.args;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: args.searchMode
            ? TextField(
                controller: controller.searchField,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search products',
                  border: InputBorder.none,
                ),
                onChanged: (value) => controller.query.value = value,
              )
            : Text(
                args.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
      body: Column(
        children: [
          Obx(() {
            final hidden =
                args.searchMode && controller.query.value.trim().isEmpty;
            if (hidden) {
              return const SizedBox.shrink();
            }
            return ProductListToolbar(controller: controller);
          }),
          Expanded(
            child: Obx(() {
              final products = controller.products.toList();
              final loading = controller.isLoading.value;
              final loadingMore = controller.isLoadingMore.value;
              final error = controller.errorMessage.value;
              final query = controller.query.value.trim();
              final hasFilters = controller.activeChips.isNotEmpty;

              if (loading && products.isEmpty) {
                return const LoadingView();
              }

              if (error != null && products.isEmpty) {
                return ErrorView(
                  message: error,
                  onRetry: controller.refreshList,
                );
              }

              if (products.isEmpty) {
                if (args.searchMode && query.isEmpty) {
                  return const EmptyView(
                    message: 'Type to search products',
                    icon: Icons.search_rounded,
                  );
                }
                return _NoResults(
                  hasFilters: hasFilters,
                  onClear: controller.clearFilters,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshList,
                child: CustomScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (loading)
                      const SliverToBoxAdapter(
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            onTap: () => Get.toNamed(
                              AppRoutes.productDetails,
                              arguments: product,
                            ),
                          );
                        }, childCount: products.length),
                      ),
                    ),
                    if (loadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.hasFilters, required this.onClear});

  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Color(0xFF9AA4B2),
            ),
            const SizedBox(height: 12),
            const Text(
              'No products found',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 6),
              const Text(
                'Try removing some filters.',
                style: TextStyle(color: Color(0xFF687386)),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onClear,
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
