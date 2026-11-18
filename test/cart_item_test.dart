import 'package:flutter_test/flutter_test.dart';
import 'package:magna_data_ai_ecommerce/data/models/cart_item.dart';

void main() {
  test('cart item unit and line totals convert minor currency units', () {
    const item = CartItem(
      productId: 1,
      name: 'Test product',
      price: 10000,
      quantity: 2,
      imageUrl: null,
      sku: 'TEST',
      currencySymbol: '₹',
      minorUnit: 2,
    );

    expect(item.unitPrice, 100);
    expect(item.totalPrice, 200);
  });
}
