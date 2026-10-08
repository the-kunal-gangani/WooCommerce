import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/cart_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/app_network_image.dart';
import 'package:magna_data_ai_ecommerce/core/widgets/state_views.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/features/favourites/favourites_controller.dart';
import 'package:magna_data_ai_ecommerce/features/product-details/product_details_controller.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late final ProductDetailsController controller;
  late final FavouriteController favController;

  bool _isOpeningProduct = false;
  bool _isDescriptionExpanded = false;

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);
  static const border = Color(0xFFE6EAF0);

  @override
  void initState() {
    super.initState();

    controller = Get.find<ProductDetailsController>();
    favController = Get.find<FavouriteController>();
  }

  Future<void> _openRelatedProduct(Product product) async {
    if (_isOpeningProduct) return;
    _isOpeningProduct = true;
    await Get.toNamed(
      AppRoutes.productDetails,
      arguments: product,
      preventDuplicates: false,
    );
    _isOpeningProduct = false;
  }

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
        final product = controller.product.value;
        if (product == null) {
          return const SizedBox.shrink();
        }
        return _buildBottomBar(product);
      }),
    );
  }

  Widget _buildBody(BuildContext context, Product product) {
    final active = controller.activeProduct ?? product;
    final images = controller.images;
    final imageIndex = images.isEmpty
        ? 0
        : controller.selectedImageIndex.value.clamp(0, images.length - 1);
    final selection = Map<String, String>.from(controller.selection);
    final attributes = controller.variationAttributes;
    final priceLabel = controller.unitPriceLabel;
    final stockLabel = controller.stockLabel;
    final description = product.plainDescription.isNotEmpty
        ? product.plainDescription
        : product.plainShortDescription;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildProductHero(product, images, imageIndex),
        ),
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
        if (product.categories.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
              child: _buildCategories(product),
            ),
          ),
        if (attributes.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
              child: _buildVariations(context, attributes, selection),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
            child: Obx(() => _buildQuantity(controller.quantity.value)),
          ),
        ),
        if (product.attributes.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: _buildSpecifications(product),
            ),
          ),
        if (product.tags.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: _buildTags(product),
            ),
          ),
        if (product.reviewCount > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: _buildReviews(product),
            ),
          ),
        Obx(() {
          final products = controller.relatedProducts.toList();
          if (products.isEmpty) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          return SliverToBoxAdapter(child: _buildRecommendedProducts(products));
        }),
        const SliverToBoxAdapter(child: SizedBox(height: 130)),
      ],
    );
  }

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
                    padding: const EdgeInsets.fromLTRB(30, 70, 30, 55),
                    child: _ZoomableProductImage(
                      url: images.isEmpty ? null : images[imageIndex].src,
                    ),
                  ),
                ),
                if (images.isNotEmpty)
                  Positioned(
                    right: 18,
                    bottom: images.length > 1 ? 82 : 20,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: border),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in_rounded, size: 15, color: muted),
                            SizedBox(width: 5),
                            Text(
                              'Pinch to zoom',
                              style: TextStyle(
                                color: muted,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
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
        ),
        Positioned(
          left: 18,
          top: 50,
          child: _HeroActionButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Get.back(),
          ),
        ),
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
              onTap: () => favController.toggleFavourite(product),
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 58,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final isSelected = imageIndex == index;
                  return GestureDetector(
                    onTap: () {
                      controller.selectImage(index);
                    },
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
            _stockPill(stockLabel),
          ],
        ),
        const SizedBox(height: 14),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_downward, size: 18, color: primary),
                  SizedBox(width: 3),
                  Text(
                    '${active.prices.discountPercent}%',
                    style: const TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (active.hasDiscount) ...[
              Text(
                active.prices.formattedRegular,
                style: const TextStyle(
                  color: Color.fromARGB(255, 88, 97, 111),
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                priceLabel,
                style: const TextStyle(
                  color: primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
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
          const _SectionTitle(
            icon: Icons.description_outlined,
            title: 'About this product',
          ),
          const SizedBox(height: 9),
          _buildDescription(description),
        ],
      ],
    );
  }

  Widget _stockPill(String stockLabel) {
    final canBuy = controller.canBuy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: canBuy ? const Color(0xFFEAF9F0) : const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            canBuy
                ? Icons.check_circle_outline_rounded
                : Icons.remove_circle_outline_rounded,
            size: 13,
            color: canBuy ? const Color(0xFF15803D) : const Color(0xFFD92D20),
          ),
          const SizedBox(width: 4),
          Text(
            stockLabel,
            style: TextStyle(
              color: canBuy ? const Color(0xFF15803D) : const Color(0xFFD92D20),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            maxLines: _isDescriptionExpanded ? null : 3,
            overflow: _isDescriptionExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(
              color: muted,
              fontSize: 13,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isDescriptionExpanded ? 'Show less' : 'Read more',
                  style: const TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  _isDescriptionExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: primary,
                  size: 17,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(Product product) {
    return _ProductSectionCard(
      icon: Icons.category_outlined,
      title: 'Categories',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: product.categories.map((category) {
          return _SoftChip(label: category.name, icon: Icons.folder_outlined);
        }).toList(),
      ),
    );
  }

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
                onTap: () {
                  debugPrint('BEFORE DECREMENT: ${controller.quantity.value}');
                  controller.decrementQuantity();
                  debugPrint('AFTER DECREMENT: ${controller.quantity.value}');
                },
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
                onTap: () {
                  debugPrint('BEFORE INCREMENT: ${controller.quantity.value}');
                  controller.incrementQuantity();
                  debugPrint('AFTER INCREMENT: ${controller.quantity.value}');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecifications(Product product) {
    return _ProductSectionCard(
      icon: Icons.tune_rounded,
      title: 'Specifications',
      child: Column(
        children: [
          for (int i = 0; i < product.attributes.length; i++)
            _SpecificationRow(
              name: product.attributes[i].name,
              value: _attributeValue(product.attributes[i]),
              isLast: i == product.attributes.length - 1,
            ),
        ],
      ),
    );
  }

  String _attributeValue(dynamic attribute) {
    try {
      final terms = attribute.terms as List;
      if (terms.isEmpty) {
        return 'Not specified';
      }
      return terms.map((term) => term.name.toString()).join(', ');
    } catch (_) {
      return 'Not specified';
    }
  }

  Widget _buildTags(Product product) {
    return _ProductSectionCard(
      icon: Icons.sell_outlined,
      title: 'Tags',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: product.tags.map((tag) {
          return _SoftChip(label: tag.name, icon: Icons.local_offer_outlined);
        }).toList(),
      ),
    );
  }

  Widget _buildReviews(Product product) {
    final rating = product.averageRating.clamp(0, 5);
    return _ProductSectionCard(
      icon: Icons.rate_review_outlined,
      title: 'Customer Reviews',
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 17,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        final filled = index < rating.round();
                        return Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${product.reviewCount} customer reviews',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_outlined, color: primary, size: 17),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ratings and review count are provided by the store.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProducts(List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 20),
          child: _SectionTitle(
            icon: Icons.auto_awesome_rounded,
            title: 'You might also like',
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 292,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 20),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 185,
                child: _RecommendedProductCard(
                  product: product,
                  onTap: () {
                    debugPrint(
                      'OPENING PRODUCT: ${product.name} | ID: ${product.id}',
                    );
                    Get.toNamed(
                      AppRoutes.productDetails,
                      arguments: product,
                      preventDuplicates: false,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(Product product) {
    final canBuy = controller.canBuy;
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
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    canBuy ? 'Total' : 'Availability',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    canBuy ? controller.totalPriceLabel : 'Out of stock',
                    style: TextStyle(
                      color: canBuy ? navy : const Color(0xFFD92D20),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: canBuy
                      ? const LinearGradient(colors: [primary, violet])
                      : null,
                  color: canBuy ? null : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: canBuy
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.16),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: canBuy ? controller.addToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF9AA4B2),
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        canBuy
                            ? Icons.shopping_bag_outlined
                            : Icons.remove_shopping_cart_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        canBuy ? 'Add to Cart' : 'Out of Stock',
                        style: const TextStyle(
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

class _RecommendedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _RecommendedProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: _ProductDetailsScreenState.primary.withValues(alpha: 0.08),
        highlightColor: _ProductDetailsScreenState.primary.withValues(
          alpha: 0.04,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _ProductDetailsScreenState.border),
            boxShadow: [
              BoxShadow(
                color: _ProductDetailsScreenState.navy.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: const Color(0xFFF7F9FC),
                    child: AppNetworkImage(
                      url: product.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ProductDetailsScreenState.navy,
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.priceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _ProductDetailsScreenState.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (product.reviewCount > 0)
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  product.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: _ProductDetailsScreenState.muted,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _ProductSectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _ProductDetailsScreenState.border),
        boxShadow: [
          BoxShadow(
            color: _ProductDetailsScreenState.navy.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: icon, title: title),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SpecificationRow extends StatelessWidget {
  final String name;
  final String value;
  final bool isLast;

  const _SpecificationRow({
    required this.name,
    required this.value,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  name,
                  style: const TextStyle(
                    color: _ProductDetailsScreenState.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: _ProductDetailsScreenState.navy,
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: _ProductDetailsScreenState.border),
          ],
        ],
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SoftChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _ProductDetailsScreenState.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _ProductDetailsScreenState.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _ProductDetailsScreenState.navy,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _HeroActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor = _ProductDetailsScreenState.navy,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _ProductDetailsScreenState.border),
            boxShadow: [
              BoxShadow(
                color: _ProductDetailsScreenState.navy.withValues(alpha: 0.06),
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
}

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
          child: Icon(
            icon,
            color: _ProductDetailsScreenState.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: _ProductDetailsScreenState.navy,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

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

class _ZoomableProductImage extends StatefulWidget {
  final String? url;

  const _ZoomableProductImage({required this.url});

  @override
  State<_ZoomableProductImage> createState() => _ZoomableProductImageState();
}

class _ZoomableProductImageState extends State<_ZoomableProductImage> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 1.01) {
      _transformationController.value = Matrix4.identity();
      return;
    }
    final position = _doubleTapDetails?.localPosition;
    if (position == null) {
      _transformationController.value = Matrix4.identity()..scale(2.5);
      return;
    }
    final zoomed = Matrix4.identity()
      ..translate(-position.dx * 1.5, -position.dy * 1.5)
      ..scale(2.5);
    _transformationController.value = zoomed;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) {
        _doubleTapDetails = details;
      },
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1,
        maxScale: 4,
        panEnabled: true,
        scaleEnabled: true,
        boundaryMargin: const EdgeInsets.all(100),
        clipBehavior: Clip.none,
        child: AppNetworkImage(url: widget.url, fit: BoxFit.contain),
      ),
    );
  }
}
