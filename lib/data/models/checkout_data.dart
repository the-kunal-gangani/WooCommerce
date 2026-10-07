import 'cart_item.dart';
import 'checkout_address.dart';

class CheckoutData {
  const CheckoutData({
    required this.address,
    required this.items,
    required this.paymentMethod,
    required this.shippingMethod,
    this.couponCode,
    this.customerNote,
  });

  final CheckoutAddress address;
  final List<CartItem> items;
  final String paymentMethod;
  final String shippingMethod;
  final String? couponCode;
  final String? customerNote;

  Map<String, dynamic> toJson() {
    return {
      'billing': address.toJson(),
      'shipping': address.toJson(),
      'payment_method': paymentMethod,
      'shipping_method': shippingMethod,
      'coupon_code': couponCode,
      'customer_note': customerNote,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
