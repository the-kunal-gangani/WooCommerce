import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/app_network_image.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/state_views.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/features/product-details/product_details_controller.dart';

class ProductDetailsScreen extends GetView<ProductDetailsController> {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isFavorite.value
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: controller.isFavorite.value ? Colors.red : null,
              ),
              onPressed: controller.toggleFavorite,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final product = controller.product.value;
        if (product == null) {
          final error = controller.errorMessage.value;
          if (error != null) {
            return ErrorView(message: error, onRetry: controller.reload);
          }
          return const LoadingView();
        }
        return _buildBody(context, product);
      }),
      bottomSheet: Obx(() {
        if (controller.product.value == null) return const SizedBox.shrink();
        return _buildBottomBar(context);
      }),
    );
  }

  Widget _buildBody(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final active = controller.activeProduct ?? product;
    final images = controller.images;
    final imageIndex = images.isEmpty
        ? 0
        : controller.selectedImageIndex.value.clamp(0, images.length - 1);
    final selection = Map<String, String>.from(controller.selection);
    final quantity = controller.quantity.value;
    final attributes = controller.variationAttributes;
    final priceLabel = controller.unitPriceLabel;
    final stockLabel = controller.stockLabel;
    final description = product.plainDescription.isNotEmpty
        ? product.plainDescription
        : product.plainShortDescription;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: AppNetworkImage(
              url: images.isEmpty ? null : images[imageIndex].src,
              fit: BoxFit.contain,
            ),
          ),
          if (images.length > 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final isSelected = imageIndex == index;
                  return GestureDetector(
                    onTap: () => controller.selectImage(index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: AppNetworkImage(
                        url: images[index].thumbnail,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (product.reviewCount > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      priceLabel,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (active.hasDiscount)
                      Text(
                        active.prices.formattedRegular,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  stockLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: controller.canBuy
                        ? Colors.green.shade700
                        : theme.colorScheme.error,
                  ),
                ),
                if (product.sku.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${product.sku}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
                for (final attribute in attributes) ...[
                  const SizedBox(height: 20),
                  Text(
                    attribute.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: attribute.terms.map((term) {
                      final isSelected = selection[attribute.name] == term.slug;
                      return GestureDetector(
                        onTap: () =>
                            controller.selectOption(attribute.name, term.slug),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            term.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: controller.decrementQuantity,
                            icon: const Icon(Icons.remove, size: 18),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: controller.incrementQuantity,
                            icon: const Icon(Icons.add, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final canBuy = controller.canBuy;
    final total = controller.totalLabel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                total,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: canBuy ? controller.addToCart : null,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(
                  canBuy ? 'Add to Cart' : 'Out of stock',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
