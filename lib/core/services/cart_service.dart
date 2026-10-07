import 'package:get/get.dart';

import '../../data/models/cart_item.dart';
import '../services/storage_services.dart';

class CartService extends GetxService {
  CartService(this._storage);

  final StorageService _storage;

  static const String _storageKey = 'cart_items';

  final items = <CartItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  bool get isEmpty => items.isEmpty;
  int get itemCount {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  int get subtotalMinor {
    return items.fold(0, (total, item) => total + (item.price * item.quantity));
  }

  double get subtotal {
    if (items.isEmpty) return 0;
    final minorUnit = items.first.minorUnit;
    var divisor = 1;
    for (var i = 0; i < minorUnit; i++) {
      divisor *= 10;
    }
    return subtotalMinor / divisor;
  }

  Future<void> addItem({required CartItem item}) async {
    final index = items.indexWhere(
      (existing) => existing.lineKey == item.lineKey,
    );
    if (index >= 0) {
      final existing = items[index];
      items[index] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
    } else {
      items.add(item);
    }
    await _persist();
  }

  Future<void> increaseQuantity(CartItem item) async {
    final index = items.indexWhere(
      (existing) => existing.lineKey == item.lineKey,
    );
    if (index < 0) return;
    final current = items[index];
    items[index] = current.copyWith(quantity: current.quantity + 1);
    await _persist();
  }

  Future<void> decreaseQuantity(CartItem item) async {
    final index = items.indexWhere(
      (existing) => existing.lineKey == item.lineKey,
    );
    if (index < 0) return;
    final current = items[index];
    if (current.quantity <= 1) {
      await removeItem(current);
      return;
    }
    items[index] = current.copyWith(quantity: current.quantity - 1);
    await _persist();
  }

  Future<void> setQuantity(CartItem item, int quantity) async {
    final index = items.indexWhere(
      (existing) => existing.lineKey == item.lineKey,
    );
    if (index < 0) return;
    if (quantity <= 0) {
      await removeItem(item);
      return;
    }
    items[index] = items[index].copyWith(quantity: quantity);
    await _persist();
  }

  Future<void> removeItem(CartItem item) async {
    items.removeWhere((existing) => existing.lineKey == item.lineKey);
    await _persist();
  }

  Future<void> clearCart() async {
    items.clear();
    await _persist();
  }

  void _loadCart() {
    final stored = _storage.read<dynamic>(_storageKey);
    if (stored is! List) {
      return;
    }
    final restored = <CartItem>[];
    for (final value in stored) {
      if (value is Map) {
        try {
          restored.add(CartItem.fromJson(Map<String, dynamic>.from(value)));
        } catch (_) {
          // Ignore malformed cart entries.
        }
      }
    }

    items.assignAll(restored);
  }

  Future<void> _persist() async {
    await _storage.write(
      _storageKey,
      items.map((item) => item.toJson()).toList(),
    );
  }
}
