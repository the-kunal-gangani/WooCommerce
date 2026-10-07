class FavouriteProduct {
  const FavouriteProduct({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.sku,
    required this.currencySymbol,
    required this.minorUnit,
  });

  final int productId;
  final String name;
  final int price;
  final String? imageUrl;
  final String sku;
  final String currencySymbol;
  final int minorUnit;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'sku': sku,
      'currency_symbol': currencySymbol,
      'minor_unit': minorUnit,
    };
  }

  factory FavouriteProduct.fromJson(Map<String, dynamic> json) {
    return FavouriteProduct(
      productId: json['product_id'] as int,
      name: json['name'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
      sku: json['sku'] as String? ?? '',
      currencySymbol: json['currency_symbol'] as String? ?? '₹',
      minorUnit: json['minor_unit'] as int? ?? 2,
    );
  }
}
