import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/features/recently-viewed/recently_viewed_controller.dart';

class RecentlyViewedScreen extends GetView<RecentlyViewedController> {
  const RecentlyViewedScreen({super.key});

  static const Color _background = Color(0xFFF7F9FC);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF687386);
  static const Color _primary = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Recently Viewed',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          Obx(() {
            if (controller.products.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              tooltip: 'Clear history',
              onPressed: _showClearConfirmation,
              icon: const Icon(Icons.delete_outline_rounded),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildMessageState(
            icon: Icons.cloud_off_rounded,
            title: 'Unable to load products',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Try Again',
            onAction: controller.loadRecentlyViewed,
          );
        }

        if (controller.products.isEmpty) {
          return _buildMessageState(
            icon: Icons.history_rounded,
            title: 'Nothing here yet',
            subtitle: 'Products you explore will appear here, so you can find them again easily.',
          );
        }

        return RefreshIndicator(
          color: _primary,
          onRefresh: controller.loadRecentlyViewed,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Pick up where you left off',
                          style: TextStyle(fontSize: 14, color: _textSecondary),
                        ),
                      ),
                      Text(
                        '${controller.products.length} products',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = controller.products[index];

                    return _ProductTile(
                      product: product,
                      onTap: () {
                        Get.toNamed('/product-details', arguments: product);
                      },
                    );
                  }, childCount: controller.products.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.62,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 84,
              width: 84,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 38, color: _primary),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: _textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 22),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear recently viewed?'),
        content: const Text(
          'This will remove all products from your recently viewed history.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.clearRecentlyViewed();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF687386);
  static const Color _primary = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF1F5F9),
                padding: const EdgeInsets.all(12),
                child: imageUrl == null || imageUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 42,
                          color: Color(0xFF94A3B8),
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 42,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;

                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _primary,
                            ),
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.priceLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.averageRating > 0
                            ? product.averageRating.toStringAsFixed(1)
                            : 'No ratings',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: _textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
