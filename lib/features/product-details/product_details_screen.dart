import 'package:cached_network_image/cached_network_image.dart';
import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/product-details/product_details_controller.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProductDetailsController>()
        ? Get.find<ProductDetailsController>()
        : Get.put(ProductDetailsController());

    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final List<String> productImages = [
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1000&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1484704849700-f032a568e944?q=80&w=1000&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1546435770-a3e426bf472b?q=80&w=1000&auto=format&fit=crop',
    ];

    final List<Color> colors = [
      Colors.black,
      Colors.blueAccent,
      Colors.grey.shade400,
    ];

    final List<String> sizes = ['S', 'M', 'L', 'XL'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Product Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Flexify.back(),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview Gallery
            Obx(
              () => Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey.shade100,
                child: CachedNetworkImage(
                  imageUrl: productImages[controller.selectedImageIndex.value],
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.image_not_supported_outlined, size: 50),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Thumbnail List
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: productImages.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final isSelected =
                        controller.selectedImageIndex.value == index;
                    return GestureDetector(
                      onTap: () => controller.selectImage(index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: productImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Main Product Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Wireless Noise-Canceling Headphones",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "4.8",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Obx(
                    () => Text(
                      "\$${controller.basePrice.value.toStringAsFixed(2)}",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Description",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Experience premium studio sound quality with ultra-clear treble and deep bass performance. Features active noise cancellation and up to 40 hours of continuous battery life.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Color Picker
                  Text(
                    "Color",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(colors.length, (index) {
                      return Obx(() {
                        final isSelected =
                            controller.selectedColorIndex.value == index;
                        return GestureDetector(
                          onTap: () => controller.selectColor(index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colors[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        );
                      });
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Size Picker
                  Text(
                    "Size",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(sizes.length, (index) {
                      return Obx(() {
                        final isSelected =
                            controller.selectedSizeIndex.value == index;
                        return GestureDetector(
                          onTap: () => controller.selectSize(index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              sizes[index],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      });
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Quantity",
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
                            Obx(
                              () => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  "${controller.quantity.value}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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

                  const SizedBox(height: 100), // Spacing for sticky bottom bar
                ],
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Navigation CTA
      bottomSheet: Container(
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
                  "Total Price",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Obx(
                  () => Text(
                    "\$${controller.totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      "Added to Cart",
                      "Item successfully added to your shopping cart",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: primaryColor,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Add to Cart",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
