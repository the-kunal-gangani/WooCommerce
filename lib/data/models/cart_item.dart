class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.sku,
    this.variationId,
    this.variationSelections = const {},
    this.currencySymbol = '',
    this.minorUnit = 2,
  });

  final int productId;
  final int? variationId;
  final String name;
  final int price;
  final int quantity;
  final String? imageUrl;
  final String sku;
  final Map<String, String> variationSelections;

  final String currencySymbol;
  final int minorUnit;
  String get lineKey {
    final selections = variationSelections.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final selectionKey = selections
        .map((entry) => '${entry.key}=${entry.value}')
        .join('|');

    return '$productId:${variationId ?? 0}:$selectionKey';
  }

  double get unitPrice {
    var divisor = 1;

    for (var i = 0; i < minorUnit; i++) {
      divisor *= 10;
    }

    return price / divisor;
  }

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    int? productId,
    int? variationId,
    String? name,
    int? price,
    int? quantity,
    String? imageUrl,
    String? sku,
    Map<String, String>? variationSelections,
    String? currencySymbol,
    int? minorUnit,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      variationId: variationId ?? this.variationId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      sku: sku ?? this.sku,
      variationSelections: variationSelections ?? this.variationSelections,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      minorUnit: minorUnit ?? this.minorUnit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'variationId': variationId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'sku': sku,
      'variationSelections': variationSelections,
      'currencySymbol': currencySymbol,
      'minorUnit': minorUnit,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final rawSelections = json['variationSelections'];

    final selections = <String, String>{};

    if (rawSelections is Map) {
      for (final entry in rawSelections.entries) {
        selections[entry.key.toString()] = entry.value.toString();
      }
    }

    return CartItem(
      productId: _asInt(json['productId']),
      variationId: json['variationId'] == null
          ? null
          : _asInt(json['variationId']),
      name: json['name']?.toString() ?? '',
      price: _asInt(json['price']),
      quantity: _asInt(json['quantity'], 1),
      imageUrl: json['imageUrl']?.toString(),
      sku: json['sku']?.toString() ?? '',
      variationSelections: selections,
      currencySymbol: json['currencySymbol']?.toString() ?? '',
      minorUnit: _asInt(json['minorUnit'], 2),
    );
  }

  static int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
