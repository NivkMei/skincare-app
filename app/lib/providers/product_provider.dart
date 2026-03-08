import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../data/mock_products.dart';

/// Which tab the category chip row shows.
enum CategoryMode { productType, functionality }

class ProductProvider extends ChangeNotifier {
  String _searchQuery = '';
  CategoryMode _categoryMode = CategoryMode.productType;
  String? _selectedCategory;       // product type filter
  String? _selectedFunctionality;  // functionality filter
  String? _selectedBrand;
  double? _maxPrice;

  String get searchQuery => _searchQuery;
  CategoryMode get categoryMode => _categoryMode;
  String? get selectedCategory => _selectedCategory;
  String? get selectedFunctionality => _selectedFunctionality;
  String? get selectedBrand => _selectedBrand;
  double? get maxPrice => _maxPrice;

  bool get hasActiveFilters =>
      _selectedCategory != null ||
      _selectedFunctionality != null ||
      _selectedBrand != null ||
      _maxPrice != null;

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryMode(CategoryMode mode) {
    if (_categoryMode != mode) {
      _categoryMode = mode;
      // Clear the chip that belongs to the other mode
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

  List<Product> filteredProducts(String countryCode) {
    return mockProducts.where((product) {
      // Country availability
      if (!product.isAvailableIn(countryCode)) return false;
      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!product.name.toLowerCase().contains(q) &&
            !product.brand.toLowerCase().contains(q) &&
            !product.category.toLowerCase().contains(q) &&
            !product.functionalities
                .any((f) => f.toLowerCase().contains(q))) {
          return false;
        }
      }
      // Product type filter
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        if (product.category != _selectedCategory) return false;
      }
      // Functionality filter
      if (_selectedFunctionality != null &&
          _selectedFunctionality!.isNotEmpty) {
        if (!product.functionalities.contains(_selectedFunctionality)) {
          return false;
        }
      }
      // Brand filter
      if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        if (product.brand != _selectedBrand) return false;
      }
      // Max price filter
      if (_maxPrice != null && product.price > _maxPrice!) return false;
      return true;
    }).toList();
  }
}
