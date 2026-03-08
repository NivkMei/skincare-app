import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  void toggle(Product product) {
    if (_favoriteIds.contains(product.id)) {
      _favoriteIds.remove(product.id);
    } else {
      _favoriteIds.add(product.id);
    }
    notifyListeners();
  }

  List<Product> getFavorites(List<Product> allProducts) =>
      allProducts.where((p) => _favoriteIds.contains(p.id)).toList();

  int get count => _favoriteIds.length;
}
