import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/core/services/cart_service.dart';
import 'package:magna_data_ai_ecommerce/data/models/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);
  static const border = Color(0xFFE6EAF0);

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartService>();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shopping Cart',
              style: TextStyle(
                color: navy,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Review your selected items',
              style: TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        final items = cart.items.toList();
        final subtotal = cart.subtotal;

        if (items.isEmpty) {
          return _buildEmptyCart();
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            _buildCartHeader(cart),

            const SizedBox(height: 18),

            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCartItem(cart, item),
              ),
            ),

            const SizedBox(height: 8),

            _buildOrderSummary(subtotal),

            const SizedBox(height: 20),

            _buildSmartHint(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final subtotal = cart.subtotal;
        final isEmpty = cart.isEmpty;

        return SafeArea(
          top: false,
          child: _buildCheckoutBar(
            subtotal: subtotal,
            enabled: !isEmpty,
            onCheckout: () {
              if (isEmpty) return;

              Get.toNamed(AppRoutes.checkout);
            },
          ),
        );
      }),
    );
  }

  // ===========================================================================
  // CART HEADER
  // ===========================================================================

  Widget _buildCartHeader(CartService cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: primary,
              size: 17,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            '${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'} in your cart',
            style: const TextStyle(
              color: navy,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          const Icon(Icons.auto_awesome_rounded, color: violet, size: 17),
        ],
      ),
    );
  }

  // ===========================================================================
  // CART ITEM
  // ===========================================================================

  Widget _buildCartItem(CartService cart, CartItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProductImage(item),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                if (item.sku.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    'SKU: ${item.sku}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                Text(
                  _formatPrice(item.price.toDouble()),
                  style: const TextStyle(
                    color: primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            children: [
              _QuantityButton(
                icon: Icons.add_rounded,
                onTap: () => cart.increaseQuantity(item),
              ),

              const SizedBox(height: 3),

              Text(
                '${item.quantity}',
                style: const TextStyle(
                  color: navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              _QuantityButton(
                icon: Icons.remove_rounded,
                onTap: () => cart.decreaseQuantity(item),
              ),
            ],
          ),

          const SizedBox(width: 4),

          IconButton(
            onPressed: () => cart.removeItem(item),
            splashRadius: 18,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: muted,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PRODUCT IMAGE
  // ===========================================================================

  Widget _buildProductImage(CartItem item) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
          ? Image.network(
              item.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return const Icon(
                  Icons.image_not_supported_outlined,
                  color: muted,
                  size: 28,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primary,
                    ),
                  ),
                );
              },
            )
          : const Icon(Icons.shopping_bag_outlined, color: primary, size: 30),
    );
  }

  // ===========================================================================
  // ORDER SUMMARY
  // ===========================================================================

  Widget _buildOrderSummary(double subtotal) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Order Summary',
                style: TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _SummaryRow(label: 'Subtotal', value: _formatPrice(subtotal)),

          const SizedBox(height: 9),

          const _SummaryRow(
            label: 'Delivery',
            value: 'Free',
            valueColor: Color(0xFF15803D),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: border),
          ),

          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),

              Text(
                _formatPrice(subtotal),
                style: const TextStyle(
                  color: primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SMART HINT
  // ===========================================================================

  Widget _buildSmartHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.06),
            violet.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: violet,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Your selected items are ready for checkout.',
              style: TextStyle(
                color: Color(0xFF4B5565),
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CHECKOUT BAR
  // ===========================================================================

  Widget _buildCheckoutBar({
    required double subtotal,
    required bool enabled,
    required VoidCallback onCheckout,
  }) {
    return Container(
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
                  _formatPrice(subtotal),
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

          SizedBox(
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: enabled
                      ? const [primary, violet]
                      : [const Color(0xFFD1D5DB), const Color(0xFFE5E7EB)],
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: enabled
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
                onPressed: enabled ? onCheckout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      enabled
                          ? Icons.lock_outline_rounded
                          : Icons.shopping_cart_outlined,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      enabled ? 'Checkout' : 'Cart Empty',
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
    );
  }

  // ===========================================================================
  // EMPTY CART
  // ===========================================================================

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: primary,
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: navy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Looks like you haven’t added anything yet.\n'
              'Explore products and find something you like.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 22),

            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [primary, violet]),
                borderRadius: BorderRadius.circular(13),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatPrice(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }
}

// ============================================================================
// SUMMARY ROW
// ============================================================================

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = CartScreen.navy,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CartScreen.muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// QUANTITY BUTTON
// ============================================================================

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F6F9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          width: 28,
          height: 28,
          child: Icon(Icons.add_rounded, size: 15, color: CartScreen.muted),
        ),
      ),
    );
  }
}
