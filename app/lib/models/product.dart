class Product {
  final String id;
  // English fields
  final String name;
  final String brand;
  final String category;
  final String description;
  final List<String> ingredients;
  final List<String> functionalities;
  // Traditional Chinese fields (繁體中文)
  final String nameZh;
  final String brandZh;
  final String categoryZh;
  final String descriptionZh;
  final List<String> ingredientsZh;
  final List<String> functionalitiesZh;
  // Pricing / availability
  final double minPrice;
  final double maxPrice;
  final String currency;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> availableCountries;
  final List<String> onlineStores;
  final Map<String, List<String>> localStores; // country -> store names
  final bool availableOnline;
  final bool availableInStore;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.ingredients,
    required this.functionalities,
    this.nameZh = '',
    this.brandZh = '',
    this.categoryZh = '',
    this.descriptionZh = '',
    this.ingredientsZh = const [],
    this.functionalitiesZh = const [],
    required this.minPrice,
    required this.maxPrice,
    required this.currency,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.availableCountries,
    required this.onlineStores,
    required this.localStores,
    this.availableOnline = true,
    this.availableInStore = true,
  });

  bool isAvailableIn(String country) => availableCountries.contains(country);
  List<String> localStoresIn(String country) => localStores[country] ?? [];

  /// Returns a formatted price range string, e.g. "HKD 132 – 139".
  /// When both prices are equal, returns a single price, e.g. "HKD 132".
  String priceRange(String cur) {
    final lo = minPrice.toStringAsFixed(0);
    final hi = maxPrice.toStringAsFixed(0);
    return lo == hi ? '$cur $lo' : '$cur $lo – $hi';
  }

  /// Returns the localised name, falling back to English.
  String localName(String locale) =>
      locale.startsWith('zh') && nameZh.isNotEmpty ? nameZh : name;

  /// Returns the localised brand, falling back to English.
  String localBrand(String locale) =>
      locale.startsWith('zh') && brandZh.isNotEmpty ? brandZh : brand;

  /// Returns the localised category, falling back to English.
  String localCategory(String locale) =>
      locale.startsWith('zh') && categoryZh.isNotEmpty ? categoryZh : category;

  /// Returns the localised description, falling back to English.
  String localDescription(String locale) =>
      locale.startsWith('zh') && descriptionZh.isNotEmpty
          ? descriptionZh
          : description;

  /// Returns the localised ingredients list, falling back to English.
  List<String> localIngredients(String locale) =>
      locale.startsWith('zh') && ingredientsZh.isNotEmpty
          ? ingredientsZh
          : ingredients;

  /// Returns the localised functionalities list, falling back to English.
  List<String> localFunctionalities(String locale) =>
      locale.startsWith('zh') && functionalitiesZh.isNotEmpty
          ? functionalitiesZh
          : functionalities;

  // ── JSON parsing helpers ──────────────────────────────────────────────────
  // The Node.js `pg` library returns NUMERIC columns as strings and booleans
  // as native booleans. These helpers handle any combination safely.
  static double _toDouble(dynamic v, {double fallback = 0.0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static bool _toBool(dynamic v, {bool fallback = false}) {
    if (v == null) return fallback;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    return s == 'true' || s == '1' || s == 't';
  }

  /// Build a Product from the list endpoint response.
  /// When [countryCode] is provided the response includes price/currency.
  factory Product.fromJson(Map<String, dynamic> json, {String? countryCode}) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String,
      description: json['description'] as String? ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      functionalities: List<String>.from(json['functionalities'] ?? []),
      nameZh: json['name_zh'] as String? ?? '',
      brandZh: json['brand_zh'] as String? ?? '',
      categoryZh: json['category_zh'] as String? ?? '',
      descriptionZh: json['description_zh'] as String? ?? '',
      ingredientsZh: List<String>.from(json['ingredients_zh'] ?? []),
      functionalitiesZh: List<String>.from(json['functionalities_zh'] ?? []),
      minPrice: _toDouble(json['min_price']),
      maxPrice: _toDouble(json['max_price']),
      currency: json['currency'] as String? ?? 'HKD',
      imageUrl: json['image_url'] as String? ?? '',
      rating: _toDouble(json['avg_rating']),
      reviewCount: _toInt(json['review_count']),
      availableCountries: countryCode != null ? [countryCode] : [],
      onlineStores: const [],
      localStores: const {},
      availableOnline: _toBool(json['available_online'], fallback: true),
      availableInStore: _toBool(json['available_in_store'], fallback: true),
    );
  }

  /// Build a Product from the detail endpoint response (includes full availability).
  factory Product.fromDetailJson(Map<String, dynamic> json,
      {String? countryCode}) {
    final avail = (json['availability'] as Map<String, dynamic>?) ?? {};
    final availableCountries = avail.keys.toList();
    final Map<String, List<String>> localStores = {};
    final Set<String> onlineStoresSet = {};

    for (final entry in avail.entries) {
      final countryAvail = entry.value as Map<String, dynamic>;
      final stores = (countryAvail['stores'] as List?) ?? [];
      for (final store in stores) {
        final s = store as Map<String, dynamic>;
        if (s['type'] == 'local') {
          localStores.putIfAbsent(entry.key, () => []).add(s['name'] as String);
        } else {
          onlineStoresSet.add(s['name'] as String);
        }
      }
    }

    double minPrice = 0;
    double maxPrice = 0;
    String currency = 'HKD';
    bool availableOnlineFlag = false;
    bool availableInStoreFlag = false;
    if (countryCode != null && avail.containsKey(countryCode)) {
      final ca = avail[countryCode] as Map<String, dynamic>;
      minPrice = _toDouble(ca['min_price']);
      maxPrice = _toDouble(ca['max_price']);
      currency = ca['currency'] as String? ?? 'HKD';
      availableOnlineFlag = _toBool(ca['available_online']);
      availableInStoreFlag = _toBool(ca['available_in_store']);
    }

    final product = json['product'] as Map<String, dynamic>? ?? json;
    return Product(
      id: product['id'].toString(),
      name: product['name'] as String,
      brand: product['brand'] as String,
      category: product['category'] as String,
      description: product['description'] as String? ?? '',
      ingredients: List<String>.from(product['ingredients'] ?? []),
      functionalities: List<String>.from(product['functionalities'] ?? []),
      nameZh: product['name_zh'] as String? ?? '',
      brandZh: product['brand_zh'] as String? ?? '',
      categoryZh: product['category_zh'] as String? ?? '',
      descriptionZh: product['description_zh'] as String? ?? '',
      ingredientsZh: List<String>.from(product['ingredients_zh'] ?? []),
      functionalitiesZh: List<String>.from(product['functionalities_zh'] ?? []),
      minPrice: minPrice,
      maxPrice: maxPrice,
      currency: currency,
      imageUrl: product['image_url'] as String? ?? '',
      rating: _toDouble(product['avg_rating']),
      reviewCount: _toInt(product['review_count']),
      availableCountries: availableCountries,
      onlineStores: onlineStoresSet.toList(),
      localStores: localStores,
      availableOnline: availableOnlineFlag,
      availableInStore: availableInStoreFlag,
    );
  }
}
