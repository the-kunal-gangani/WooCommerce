import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/storage_services.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';

class FavouriteService extends GetxService {
  FavouriteService(this._storage);

  final StorageService _storage;

  final favourites = <Product>[].obs;

  static const String _storageKey = 'favourite_products';

  @override
  void onInit() {
    super.onInit();
    _loadFavourites();
  }

  bool isFavourite(int productId) {
    return favourites.any((product) => product.id == productId);
  }

  Future<void> toggleFavourite(Product product) async {
    if (isFavourite(product.id)) {
      await removeFavourite(product.id);
    } else {
      await addFavourite(product);
    }
  }

  Future<void> addFavourite(Product product) async {
    if (isFavourite(product.id)) return;

    favourites.add(product);

    await _persist();
  }

  Future<void> removeFavourite(int productId) async {
    favourites.removeWhere((product) => product.id == productId);

    await _persist();
  }

  Future<void> clearFavourites() async {
    favourites.clear();

    await _persist();
  }

  Future<void> _loadFavourites() async {
    final data = await _storage.read(_storageKey);

    if (data == null) return;

    try {
      final list = List<dynamic>.from(data as List);

      favourites.assignAll(
        list.map(
          (item) => Product.fromJson(Map<String, dynamic>.from(item as Map)),
        ),
      );
    } catch (_) {
      favourites.clear();
    }
  }

  Future<void> _persist() async {
    // Temporary implementation.
    //
    // Product currently does not expose toJson(), so persistence
    // will be added after deciding which Product fields should be
    // stored locally.
  }
}
