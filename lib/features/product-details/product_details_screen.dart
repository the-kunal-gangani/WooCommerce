import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/app_network_image.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/state_views.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/features/product-details/product_details_controller.dart';

class ProductDetailsScreen extends GetView<ProductDetailsController> {
  const ProductDetailsScreen({super.key});

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);
  static const border = Color(0xFFE6EAF0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
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
      bottomNavigationBar: Obx(() {
        if (controller.product.value == null) {
          return const SizedBox.shrink();
        }
        return _buildBottomBar(controller.product.value!);
      }),
    );
  }

  // ===========================================================================
  // BODY
  // ===========================================================================

  Widget _buildBody(BuildContext context, Product product) {
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

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ---------------------------------------------------------------------
        // PRODUCT HERO
        // ---------------------------------------------------------------------

        SliverToBoxAdapter(
          child: _buildProductHero(product, images, imageIndex),
        ),

        // ---------------------------------------------------------------------
        // PRODUCT INFORMATION
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _buildProductInfo(
              context,
              product,
              active,
              priceLabel,
              stockLabel,
              description,
            ),
          ),
        ),

        // ---------------------------------------------------------------------
        // VARIATIONS
        // ---------------------------------------------------------------------
        if (attributes.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
              child: _buildVariations(context, attributes, selection),
            ),
          ),

        // ---------------------------------------------------------------------
        // QUANTITY
        // ---------------------------------------------------------------------
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
            child: _buildQuantity(quantity),
          ),
        ),

        // ---------------------------------------------------------------------
        // BOTTOM SPACE
        // ---------------------------------------------------------------------
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  // ===========================================================================
  // PRODUCT HERO
  // ===========================================================================

  Widget _buildProductHero(
    Product product,
    List<dynamic> images,
    int imageIndex,
  ) {
    return Stack(
      children: [
        Container(
          height: 380,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            child: Stack(
              children: [
                // Soft background glow
                Positioned(
                  top: -100,
                  right: -80,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primary.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -100,
                  left: -80,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          violet.withValues(alpha: 0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 70, 30, 40),
                    child: AppNetworkImage(
                      url: images.isEmpty ? null : images[imageIndex].src,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Back button
        Positioned(
          left: 18,
          top: 50,
          child: _HeroActionButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Get.back(),
          ),
        ),

        // Favorite button
        Positioned(
          right: 18,
          top: 50,
          child: Obx(
            () => _HeroActionButton(
              icon: controller.isFavorite.value
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: controller.isFavorite.value
                  ? const Color(0xFFE5484D)
                  : navy,
              onTap: controller.toggleFavorite,
            ),
          ),
        ),

        // Image thumbnails
        if (images.length > 1)
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 58,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final isSelected = imageIndex == index;

                  return GestureDetector(
                    onTap: () => controller.selectImage(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 58,
                      height: 58,
                      margin: const EdgeInsets.only(right: 9),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: isSelected ? primary : border,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: navy.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: AppNetworkImage(
                          url: images[index].thumbnail,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // HERO ACTION BUTTON
  // ===========================================================================

  Widget _HeroActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = navy,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }

  // ===========================================================================
  // PRODUCT INFO
  // ===========================================================================

  Widget _buildProductInfo(
    BuildContext context,
    Product product,
    Product active,
    String priceLabel,
    String stockLabel,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating + stock
        Row(
          children: [
            if (product.reviewCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Color(0xFF7A5A00),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

            if (product.reviewCount > 0) const SizedBox(width: 8),

            if (product.reviewCount > 0)
              Text(
                '${product.reviewCount} reviews',
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: controller.canBuy
                    ? const Color(0xFFEAF9F0)
                    : const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                stockLabel,
                style: TextStyle(
                  color: controller.canBuy
                      ? const Color(0xFF15803D)
                      : const Color(0xFFD92D20),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Product name
        Text(
          product.name,
          style: const TextStyle(
            color: navy,
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        // Price
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              priceLabel,
              style: const TextStyle(
                color: primary,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),

            if (active.hasDiscount) ...[
              const SizedBox(width: 10),
              Text(
                active.prices.formattedRegular,
                style: const TextStyle(
                  color: Color(0xFF929BA8),
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '${active.prices.discountPercent}% OFF',
                  style: const TextStyle(
                    color: primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),

        if (product.sku.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'SKU ${product.sku}',
            style: const TextStyle(
              color: Color(0xFF9AA4B2),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],

        if (description.isNotEmpty) ...[
          const SizedBox(height: 22),

          _SectionTitle(
            icon: Icons.description_outlined,
            title: 'About this product',
          ),

          const SizedBox(height: 9),

          Text(
            description,
            style: const TextStyle(
              color: muted,
              fontSize: 13,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // VARIATIONS
  // ===========================================================================

  Widget _buildVariations(
    BuildContext context,
    List<dynamic> attributes,
    Map<String, String> selection,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.tune_rounded,
          title: 'Choose your options',
        ),

        const SizedBox(height: 18),

        for (final attribute in attributes) ...[
          Text(
            attribute.name,
            style: const TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: attribute.terms.map<Widget>((term) {
              final isSelected = selection[attribute.name] == term.slug;

              return GestureDetector(
                onTap: () {
                  controller.selectOption(attribute.name, term.slug);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? primary : border),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    term.name,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF536075),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),
        ],
      ],
    );
  }

  // ===========================================================================
  // QUANTITY
  // ===========================================================================

  Widget _buildQuantity(int quantity) {
    return Row(
      children: [
        const Expanded(
          child: _SectionTitle(
            icon: Icons.shopping_cart_outlined,
            title: 'Quantity',
          ),
        ),

        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              _QuantityButton(
                icon: Icons.remove_rounded,
                onTap: controller.decrementQuantity,
              ),

              SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      color: navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              _QuantityButton(
                icon: Icons.add_rounded,
                onTap: controller.incrementQuantity,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BOTTOM BAR
  // ===========================================================================

  Widget _buildBottomBar(Product product) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 9, 18, 9),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: navy.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ---------------------------------------------------------------
            // TOTAL
            // ---------------------------------------------------------------
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${product.priceLabel}',
                    style: const TextStyle(
                      color: navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ---------------------------------------------------------------
            // ADD TO CART
            // ---------------------------------------------------------------
            SizedBox(
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [primary, violet]),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: controller.addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 18),
                      SizedBox(width: 7),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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

// =============================================================================
// SECTION TITLE
// =============================================================================

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: ProductDetailsScreen.primary, size: 16),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: ProductDetailsScreen.navy,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// QUANTITY BUTTON
// =============================================================================

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 42,
          child: Icon(icon, size: 17, color: const Color(0xFF536075)),
        ),
      ),
    );
  }
}
