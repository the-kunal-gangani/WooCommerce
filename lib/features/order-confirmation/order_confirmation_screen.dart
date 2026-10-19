import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:magna_data_ai_ecommerce/core/routes/app_routes.dart';
import 'package:magna_data_ai_ecommerce/data/models/checkout_data.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({
    super.key,
    required this.checkoutData,
    required this.createdOrder,
    required this.paymentResult,
  });

  final CheckoutData checkoutData;
  final Map<String, dynamic> createdOrder;
  final Map<String, dynamic> paymentResult;

  static const background = Color(0xFFF7F9FC);
  static const navy = Color(0xFF111827);
  static const muted = Color(0xFF687386);
  static const primary = Color(0xFF2563EB);
  static const violet = Color(0xFF6D4AFF);
  static const success = Color(0xFF16A34A);
  static const border = Color(0xFFE5EAF1);

  String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final result = value.toString().trim();
    return result.isEmpty ? fallback : result;
  }

  double? _numberValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString().replaceAll(',', '').trim());
  }

  // Supports responses that wrap their result in "data".
  Map<String, dynamic> get _order {
    final data = createdOrder['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return createdOrder;
  }

  Map<String, dynamic> get _payment {
    final data = paymentResult['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return paymentResult;
  }

  String get _paymentStatus {
    final status = _stringValue(
      _payment['status'],
      fallback: _stringValue(paymentResult['status']),
    ).toLowerCase();

    if (status == 'paid' || status == 'captured') return 'paid';
    if (status == 'pending' || status == 'created') return 'pending';

    if (checkoutData.paymentMethod == 'cod') {
      return 'pending';
    }

    return status.isEmpty ? 'pending' : status;
  }

  bool get _isPaid => _paymentStatus == 'paid';

  bool get _isCod => checkoutData.paymentMethod == 'cod';

  String get _orderNumber {
    final id =
        _order['woocommerce_order_id'] ??
        _order['order_number'] ??
        _order['orderNumber'] ??
        _order['order_id'] ??
        _order['id'];

    if (id == null || id.toString().trim().isEmpty) {
      return 'Available in your order history';
    }

    return '#$id';
  }

  String get _currency {
    return _stringValue(
      _order['currency'],
      fallback: _stringValue(createdOrder['currency'], fallback: 'INR'),
    ).toUpperCase();
  }

  String get _currencySymbol {
    switch (_currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '$_currency ';
    }
  }

  String _formatAmount(double value) {
    return '$_currencySymbol${value.toStringAsFixed(2)}';
  }

  // WooCommerce commonly returns monetary amounts as decimal strings.
  // Never use Flutter's estimated total as the amount actually paid.
  double? get _orderTotal {
    return _numberValue(
      _order['total'] ?? _order['total_amount'] ?? _order['amount_total'],
    );
  }

  double? get _subtotal {
    return _numberValue(
      _order['subtotal'] ??
          _order['subtotal_amount'] ??
          _order['line_items_subtotal'],
    );
  }

  double? get _shippingTotal {
    return _numberValue(
      _order['shipping_total'] ??
          _order['shipping'] ??
          _order['shipping_amount'],
    );
  }

  double? get _discountTotal {
    return _numberValue(
      _order['discount_total'] ??
          _order['discount'] ??
          _order['discount_amount'],
    );
  }

  double? get _taxTotal {
    return _numberValue(
      _order['total_tax'] ?? _order['tax'] ?? _order['tax_total'],
    );
  }

  String get _paymentMethodLabel {
    if (_isCod) return 'Cash on delivery';
    return _isPaid ? 'Razorpay · Paid' : 'Razorpay · Pending';
  }

  String get _statusTitle {
    if (_isCod) return 'Order placed successfully!';
    if (_isPaid) return 'Payment successful!';
    return 'Order received';
  }

  String get _statusDescription {
    if (_isCod) {
      return 'Your order has been placed. Payment is due on delivery.';
    }

    if (_isPaid) {
      return 'Thank you for shopping with Magna Data Store.';
    }

    return 'Your order details are available, but payment confirmation '
        'is still pending. Please do not pay again until you check the status.';
  }

  String get _shippingAddress {
    final address = checkoutData.address;

    return [
      address.fullName,
      address.address1,
      address.city,
      address.state,
      address.postcode,
    ].where((part) => part.trim().isNotEmpty).join(', ');
  }

  List<dynamic> get _items => checkoutData.items;

  String _itemName(dynamic item) {
    try {
      final value = item.name;
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final value = item.productName;
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    } catch (_) {}

    try {
      if (item is Map) {
        return _stringValue(
          item['name'] ?? item['product_name'] ?? item['productName'],
          fallback: 'Product',
        );
      }
    } catch (_) {}

    return 'Product';
  }

  int _itemQuantity(dynamic item) {
    try {
      final value = item.quantity;
      if (value is num) return value.toInt();
    } catch (_) {}

    try {
      if (item is Map) {
        final value = item['quantity'];
        if (value is num) return value.toInt();
        return int.tryParse(value.toString()) ?? 1;
      }
    } catch (_) {}

    return 1;
  }

  double? _itemPrice(dynamic item) {
    try {
      final value = item.price;
      if (value is num) return value.toDouble();
    } catch (_) {}

    try {
      final value = item.priceAmount;
      if (value is num) return value.toDouble();
    } catch (_) {}

    try {
      if (item is Map) {
        return _numberValue(
          item['price'] ?? item['unit_price'] ?? item['regular_price'],
        );
      }
    } catch (_) {}

    return null;
  }

  String _itemDetails(dynamic item) {
    final parts = <String>[];

    try {
      final value = item.color;
      if (value != null && value.toString().trim().isNotEmpty) {
        parts.add(value.toString());
      }
    } catch (_) {}

    try {
      if (item is Map) {
        final value = item['color'] ?? item['variation_name'];
        if (value != null && value.toString().trim().isNotEmpty) {
          parts.add(value.toString());
        }
      }
    } catch (_) {}

    return parts.isEmpty ? 'Selected product' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          _buildAmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      _buildSuccessHeader(),
                      const SizedBox(height: 24),
                      _buildOrderInfo(),
                      const SizedBox(height: 14),
                      _buildShippingCard(),
                      const SizedBox(height: 22),
                      _buildItemsSection(),
                      const SizedBox(height: 14),
                      _buildPaymentSummary(),
                      const SizedBox(height: 20),
                      _buildTrustMessage(),
                    ],
                  ),
                ),
                _buildBottomActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBackground() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -90,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withValues(alpha: 0.10),
                    primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 240,
            left: -120,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    violet.withValues(alpha: 0.07),
                    violet.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 4),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Order Confirmation',
              style: TextStyle(
                color: navy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: border),
            ),
            child: Icon(
              _isPaid
                  ? Icons.receipt_long_outlined
                  : Icons.shopping_bag_outlined,
              color: primary,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader() {
    final Color statusColor = _isPaid || _isCod
        ? success
        : const Color(0xFFD97706);

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                statusColor.withValues(alpha: 0.14),
                primary.withValues(alpha: 0.10),
              ],
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              _isPaid || _isCod
                  ? Icons.check_rounded
                  : Icons.hourglass_top_rounded,
              color: statusColor,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 17),
        Text(
          _statusTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: navy,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          _statusDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: muted,
            fontSize: 12,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            _isPaid
                ? 'PAYMENT VERIFIED'
                : _isCod
                ? 'CASH ON DELIVERY'
                : 'PAYMENT PENDING',
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.receipt_long_outlined,
            label: 'Order number',
            value: _orderNumber,
            iconColor: primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.local_shipping_outlined,
            label: 'Delivery',
            value: _stringValue(
              _order['estimated_delivery'] ?? _order['delivery_estimate'],
              fallback: 'To be announced',
            ),
            iconColor: violet,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 11),
          Text(
            label,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: navy,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shipping address',
                  style: TextStyle(
                    color: navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _shippingAddress.isEmpty
                      ? 'No shipping address provided'
                      : _shippingAddress,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (checkoutData.address.phone.trim().isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          checkoutData.address.phone,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: 0.11),
                      violet.withValues(alpha: 0.09),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Items ordered (${_items.length})',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Order item details are unavailable.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            )
          else
            ..._items.map(_buildItem),
        ],
      ),
    );
  }

  Widget _buildItem(dynamic item) {
    final quantity = _itemQuantity(item);
    final price = _itemPrice(item);
    final lineTotal = price == null ? null : price * quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: border),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF8A94A6),
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _itemName(item),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty $quantity · ${_itemDetails(item)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            lineTotal == null ? '—' : _formatAmount(lineTotal),
            style: const TextStyle(
              color: navy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final total = _orderTotal;
    final subtotal = _subtotal;
    final shipping = _shippingTotal;
    final discount = _discountTotal;
    final tax = _taxTotal;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: primary,
                size: 19,
              ),
              SizedBox(width: 9),
              Text(
                'Payment summary',
                style: TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _summaryRow(
            'Subtotal',
            subtotal == null ? '—' : _formatAmount(subtotal),
          ),
          const SizedBox(height: 8),
          _summaryRow(
            'Shipping',
            shipping == null ? '—' : _formatAmount(shipping),
          ),
          if (discount != null && discount > 0) ...[
            const SizedBox(height: 8),
            _summaryRow('Discount', '-${_formatAmount(discount)}'),
          ],
          const SizedBox(height: 8),
          _summaryRow('Tax', tax == null ? '—' : _formatAmount(tax)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(height: 1, color: border),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Order total',
                  style: TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                total == null ? 'Unavailable' : _formatAmount(total),
                style: const TextStyle(
                  color: primary,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryRow('Payment method', _paymentMethodLabel),
          const SizedBox(height: 8),
          _summaryRow(
            'Payment status',
            _isPaid
                ? 'Paid'
                : _isCod
                ? 'Pay on delivery'
                : 'Pending confirmation',
          ),
          if (total == null) ...[
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'The store has not returned its full order totals. '
                'Check your order details for the final amount.',
                style: TextStyle(color: muted, fontSize: 10, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: navy,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrustMessage() {
    final message = _isPaid
        ? 'Payment was confirmed by the server.'
        : _isCod
        ? 'Pay for your order when it is delivered.'
        : 'Check your order status before making another payment.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            _isPaid || _isCod
                ? Icons.verified_outlined
                : Icons.info_outline_rounded,
            color: primary,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF40516B),
                fontSize: 10,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: border)),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -7),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'Track Order',
                    'Order tracking will be available once connected '
                        'to your order history API.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: const Text('Track Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: Color(0xFFD7E2FF)),
                  backgroundColor: const Color(0xFFF8FAFF),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.offAllNamed(AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Continue Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
