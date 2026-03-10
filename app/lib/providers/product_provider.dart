import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

enum CategoryMode { productType, functionality }

class ProductProvider extends ChangeNotifier {
  static const int _pageSize = 50;

  // ── Filter state ──────────────────────────────────────────────
  String _searchQuery = '';
  CategoryMode _categoryMode = CategoryMode.productType;
  String? _selectedCategory;
  String? _selectedFunctionality;
  String? _selectedBrand;
  double? _maxPrice;

  // ── Pagination + API state ────────────────────────────────────
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _lastCountry;
  int _page = 1;
  int _total = 0;
  bool _hasMore = false;

  // Accumulated filter options (grow as pages load)
  final Set<String> _knownCategories = {};
  final Set<String> _knownFunctionalities = {};
  final Set<String> _knownBrands = {};

  String get searchQuery => _searchQuery;
  CategoryMode get categoryMode => _categoryMode;
  String? get selectedCategory => _selectedCategory;
  String? get selectedFunctionality => _selectedFunctionality;
  String? get selectedBrand => _selectedBrand;
  double? get maxPrice => _maxPrice;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get total => _total;
  String? get error => _error;

  bool get hasActiveFilters =>
      _selectedCategory != null ||
      _selectedFunctionality != null ||
      _selectedBrand != null ||
      _maxPrice != null;

  // ── Derived lists used by filter UI ───────────────────────────
  List<String> get allCategories => _knownCategories.toList()..sort();
  List<String> get allFunctionalities => _knownFunctionalities.toList()..sort();
  List<String> get allBrands => _knownBrands.toList()..sort();

  // ── Internal helpers ──────────────────────────────────────────
  void _accumulateFilterOptions(List<Product> products) {
    for (final p in products) {
      _knownCategories.add(p.category);
      _knownBrands.add(p.brand);
      _knownFunctionalities.addAll(p.functionalities);
    }
  }

  // ── Load page 1 (reset) ───────────────────────────────────────
  Future<void> loadProducts(String countryCode) async {
    final countryChanged = _lastCountry != countryCode;
    _lastCountry = countryCode;
    _page = 1;
    _hasMore = false;
    _isLoading = true;
    _error = null;
    // Clear accumulated filter options only on country switch so that
    // chips from country A don't bleed into country B's browse session.
    if (countryChanged) {
      _knownCategories.clear();
      _knownFunctionalities.clear();
      _knownBrands.clear();
    }
    notifyListeners();

    try {
      final data = await apiService.getProducts(
        country: countryCode,
        page: _page,
        limit: _pageSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory,
        functionality: _selectedFunctionality,
        brand: _selectedBrand,
        maxPrice: _maxPrice,
      );
      _total = (data['total'] as num?)?.toInt() ?? 0;
      final list = data['products'] as List<dynamic>;
      _products = list
          .map((j) => Product.fromJson(j as Map<String, dynamic>,
              countryCode: countryCode))
          .toList();
      _accumulateFilterOptions(_products);
      _hasMore = _products.length < _total;
    } on ApiException catch (e) {
      _error = e.message;
      _products = [];
    } catch (_) {
      _error = 'Network error. Please check your connection.';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Load next page (append) ───────────────────────────────────
  Future<void> loadMore(String countryCode) async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    _isLoadingMore = true;
    _page++;
    notifyListeners();

    try {
      final data = await apiService.getProducts(
        country: countryCode,
        page: _page,
        limit: _pageSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory,
        functionality: _selectedFunctionality,
        brand: _selectedBrand,
        maxPrice: _maxPrice,
      );
      _total = (data['total'] as num?)?.toInt() ?? 0;
      final list = data['products'] as List<dynamic>;
      final newProducts = list
          .map((j) => Product.fromJson(j as Map<String, dynamic>,
              countryCode: countryCode))
          .toList();
      _products.addAll(newProducts);
      _accumulateFilterOptions(newProducts);
      _hasMore = _products.length < _total;
    } catch (_) {
      _page--; // revert on failure
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Expose loaded list (server already filtered) ──────────────
  List<Product> filteredProducts(String countryCode) {
    if (_lastCountry != countryCode) {
      loadProducts(countryCode);
    }
    return _products;
  }

  // ── Setters (each triggers a fresh load) ─────────────────────
  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    if (_lastCountry != null) loadProducts(_lastCountry!);
  }

  void setCategoryMode(CategoryMode mode) {
    if (_categoryMode == mode) return;
    _categoryMode = mode;
    if (mode == CategoryMode.productType) {
      _selectedFunctionality = null;
    } else {
      _selectedCategory = null;
    }
    if (_lastCountry != null) loadProducts(_lastCountry!);
  }

  void setCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    if (_lastCountry != null) loadProducts(_lastCountry!);
  }

  void setFunctionality(String? functionality) {
    if (_selectedFunctionality == functionality) return;
    _selectedFunctionality = functionality;
    if (_lastCountry != null) loadProducts(_lastCountry!);
  }

  void setBrand(String? brand) {
    if (_selectedBrand == brand) return;
    _selectedBrand = brand;
    if (_lastCountry != null) loadProducts(_lastCountry!);
  }

  void setMaxPrice(double? price) {
    if (_maxPrice == price) return;
    _maxPrice = price;
    if (_lastCountry != null) loadProducts(_lastCountry!);
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedFunctionality = null;
    _selectedBrand = null;
    _maxPrice = null;
    if (_lastCountry != null) loadProducts(_lastCountry!);
  }
}
