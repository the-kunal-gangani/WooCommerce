import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/product_card.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/state_views.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/widgets/product_list_toolbar.dart';

class ProductListScreen extends GetView<ProductListController> {
  const ProductListScreen({super.key});

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const borderColor = Color(0xFFE7EBF1);

  @override
  Widget build(BuildContext context) {
    final args = controller.args;

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
        title: args.searchMode
            ? TextField(
                controller: controller.searchField,
                autofocus: true,
                textInputAction: TextInputAction.search,
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
                onChanged: (value) => controller.query.value = value,
              )
            : Text(
                args.title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
        actions: [
          if (!args.searchMode)
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.productList),
              tooltip: 'Search',
              icon: const Icon(
                Icons.search_rounded,
                color: navy,
                size: 23,
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          if (!args.searchMode)
            ProductListToolbar(controller: controller)
          else
            Obx(() {
              if (controller.query.value.trim().isEmpty) {
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
                color: primary,
                backgroundColor: Colors.white,
                onRefresh: controller.refreshList,
                child: CustomScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    if (loading)
                      const SliverToBoxAdapter(
                        child: LinearProgressIndicator(
                          minHeight: 2,
                          color: primary,
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    args.searchMode
                                        ? 'Search results'
                                        : 'Explore products',
                                    style: const TextStyle(
                                      color: navy,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${products.length} ${products.length == 1 ? 'product' : 'products'} available',
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.grid_view_rounded,
                                    size: 16,
                                    color: primary,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Grid',
                                    style: TextStyle(
                                      color: navy,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];

                            return ProductCard(
                              product: product,
                              onTap: () => Get.toNamed(
                                AppRoutes.productDetails,
                                arguments: product,
                              ),
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                    if (loadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 24, top: 8),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: primary,
                            ),
                          ),
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
  const _NoResults({
    required this.hasFilters,
    required this.onClear,
  });

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
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: ProductListScreen.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No products found',
              style: TextStyle(
                color: ProductListScreen.navy,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              hasFilters
                  ? 'Try adjusting your filters to find more products.'
                  : 'Try another search to discover more products.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ProductListScreen.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onClear,
                style: FilledButton.styleFrom(
                  backgroundColor: ProductListScreen.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
