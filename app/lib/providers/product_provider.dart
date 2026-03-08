import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../data/mock_products.dart';
import '../services/api_service.dart';

enum CategoryMode { productType, functionality }

class ProductProvider extends ChangeNotifier {
  // ── Filter state ──────────────────────────────────────────────
  String _searchQuery = '';
  CategoryMode _categoryMode = CategoryMode.productType;
  String? _selectedCategory;
  String? _selectedFunctionality;
  String? _selectedBrand;
  double? _maxPrice;

  // ── API state ─────────────────────────────────────────────────
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String? _lastCountry;

  String get searchQuery => _searchQuery;
  CategoryMode get categoryMode => _categoryMode;
  String? get selectedCategory => _selectedCategory;
  String? get selectedFunctionality => _selectedFunctionality;
  String? get selectedBrand => _selectedBrand;
  double? get maxPrice => _maxPrice;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasActiveFilters =>
      _selectedCategory != null ||
      _selectedFunctionality != null ||
      _selectedBrand != null ||
      _maxPrice != null;

  // ── Derived lists used by filter UI ───────────────────────────
  List<String> get allCategories {
    final cats = _products.map((p) => p.category).toSet().toList()..sort();
    return cats.isNotEmpty
        ? cats
        : (mockProducts.map((p) => p.category).toSet().toList()..sort());
  }

  List<String> get allFunctionalities {
    final fns = _products.expand((p) => p.functionalities).toSet().toList()..sort();
    return fns.isNotEmpty
        ? fns
        : (mockProducts.expand((p) => p.functionalities).toSet().toList()..sort());
  }

  List<String> get allBrands {
    final brands = _products.map((p) => p.brand).toSet().toList()..sort();
    return brands.isNotEmpty
        ? brands
        : (mockProducts.map((p) => p.brand).toSet().toList()..sort());
  }

  // ── Fetch from backend ────────────────────────────────────────
  Future<void> loadProducts(String countryCode) async {
    _lastCountry = countryCode;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await apiService.getProducts(
        country: countryCode,
        limit: 100,
      );
      final list = data['products'] as List<dynamic>;
      _products = list
          .map((j) => Product.fromJson(j as Map<String, dynamic>,
              countryCode: countryCode))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
      _products = mockProducts.where((p) => p.isAvailableIn(countryCode)).toList();
    } catch (_) {
      _error = 'Network error. Showing cached data.';
      _products = mockProducts.where((p) => p.isAvailableIn(countryCode)).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Client-side filtering on the loaded list ──────────────────
  List<Product> filteredProducts(String countryCode) {
    if (_lastCountry != countryCode) {
      loadProducts(countryCode);
    }
    return _products.where((product) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!product.name.toLowerCase().contains(q) &&
            !product.brand.toLowerCase().contains(q) &&
            !product.category.toLowerCase().contains(q) &&
            !product.functionalities.any((f) => f.toLowerCase().contains(q))) {
          return false;
        }
      }
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        if (product.category != _selectedCategory) return false;
      }
      if (_selectedFunctionality != null && _selectedFunctionality!.isNotEmpty) {
        if (!product.functionalities.contains(_selectedFunctionality)) return false;
      }
      if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        if (product.brand != _selectedBrand) return false;
      }
      if (_maxPrice != null && product.price > 0 && product.price > _maxPrice!) {
        return false;
      }
      return true;
    }).toList();
  }

  // ── Setters ───────────────────────────────────────────────────
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryMode(CategoryMode mode) {
    if (_categoryMode != mode) {
      _categoryMode = mode;
      if (mode == CategoryMode.productType) {
        _selectedFunctionality = null;
      } else {
        _selectedCategory = null;
      }
      notifyListeners();
    }
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setFunctionality(String? functionality) {
    _selectedFunctionality = functionality;
    notifyListeners();
  }

  void setBrand(String? brand) {
    _selectedBrand = brand;
    notifyListeners();
  }

  void setMaxPrice(double? price) {
    _maxPrice = price;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedFunctionality = null;
    _selectedBrand = null;
    _maxPrice = null;
    notifyListeners();
  }
}

