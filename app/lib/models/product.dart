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
  final double price;
  final String currency;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> availableCountries;
  final List<String> onlineStores;
  final Map<String, List<String>> localStores; // country -> store names

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
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.availableCountries,
    required this.onlineStores,
    required this.localStores,
  });

  bool isAvailableIn(String country) => availableCountries.contains(country);
  List<String> localStoresIn(String country) => localStores[country] ?? [];

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
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      currency: json['currency'] as String? ?? 'HKD',
      imageUrl: json['image_url'] as String? ?? '',
      rating: double.tryParse(json['avg_rating']?.toString() ?? '0') ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      availableCountries: countryCode != null ? [countryCode] : [],
      onlineStores: const [],
      localStores: const {},
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

    double price = 0;
    String currency = 'HKD';
    if (countryCode != null && avail.containsKey(countryCode)) {
      final ca = avail[countryCode] as Map<String, dynamic>;
      price = double.tryParse(ca['price']?.toString() ?? '') ?? 0;
      currency = ca['currency'] as String? ?? 'HKD';
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
      price: price,
      currency: currency,
      imageUrl: product['image_url'] as String? ?? '',
      rating: double.tryParse(product['avg_rating']?.toString() ?? '0') ?? 0,
      reviewCount: product['review_count'] as int? ?? 0,
      availableCountries: availableCountries,
      onlineStores: onlineStoresSet.toList(),
      localStores: localStores,
    );
  }
}
