import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class FavoritesProvider extends ChangeNotifier {
  // Local set for offline/guest mode
  final Set<String> _favoriteIds = {};
  // Full product objects fetched from API (for logged-in users)
  List<Product> _apiProducts = [];
  bool _isLoggedIn = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  int get count => _favoriteIds.length;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  /// Call this from AuthProvider on login/logout.
  Future<void> onAuthChanged({required bool isLoggedIn}) async {
    _isLoggedIn = isLoggedIn;
    if (isLoggedIn) {
      await _syncFromApi();
    } else {
      _favoriteIds.clear();
      _apiProducts.clear();
      notifyListeners();
    }
  }

  Future<void> _syncFromApi() async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await apiService.getFavorites();
      _apiProducts = list
          .map((j) => Product.fromJson(j as Map<String, dynamic>))
          .toList();
      _favoriteIds
        ..clear()
        ..addAll(_apiProducts.map((p) => p.id));
    } catch (_) {
      // silently keep local state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(Product product) async {
    final isFav = _favoriteIds.contains(product.id);

    // Optimistic update
    if (isFav) {
      _favoriteIds.remove(product.id);
      _apiProducts.removeWhere((p) => p.id == product.id);
    } else {
      _favoriteIds.add(product.id);
      _apiProducts.add(product);
    }
    notifyListeners();

    if (_isLoggedIn) {
      try {
        if (isFav) {
          await apiService.removeFavorite(product.id);
        } else {
          await apiService.addFavorite(product.id);
        }
      } catch (_) {
        // Revert on failure
        if (isFav) {
          _favoriteIds.add(product.id);
          _apiProducts.add(product);
        } else {
          _favoriteIds.remove(product.id);
          _apiProducts.removeWhere((p) => p.id == product.id);
        }
        notifyListeners();
      }
    }
  }

  List<Product> getFavorites(List<Product> allProducts) {
    if (_isLoggedIn && _apiProducts.isNotEmpty) return _apiProducts;
    return allProducts.where((p) => _favoriteIds.contains(p.id)).toList();
  }
}

