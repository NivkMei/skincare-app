class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final String currency;
  final String imageUrl;
  final String description;
  final List<String> ingredients;
  final double rating;
  final int reviewCount;
  final List<String> functionalities;
  final List<String> availableCountries;
  final List<String> onlineStores;
  final Map<String, List<String>> localStores; // country -> store names

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.description,
    required this.ingredients,
    required this.rating,
    required this.reviewCount,
    required this.functionalities,
    required this.availableCountries,
    required this.onlineStores,
    required this.localStores,
  });

  bool isAvailableIn(String country) => availableCountries.contains(country);
  List<String> localStoresIn(String country) => localStores[country] ?? [];

  /// Build a Product from the list endpoint response.
  /// When [countryCode] is provided the response includes price/currency.
  factory Product.fromJson(Map<String, dynamic> json, {String? countryCode}) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0,
      currency: json['currency'] as String? ?? 'HKD',
      imageUrl: json['image_url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      rating: double.tryParse(json['avg_rating']?.toString() ?? '0') ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      functionalities: List<String>.from(json['functionalities'] ?? []),
      availableCountries: countryCode != null ? [countryCode] : [],
      onlineStores: const [],
      localStores: const {},
    );
  }

  /// Build a Product from the detail endpoint response (includes full availability).
  factory Product.fromDetailJson(Map<String, dynamic> json, {String? countryCode}) {
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
      price = (ca['price'] as num?)?.toDouble() ?? 0;
      currency = ca['currency'] as String? ?? 'HKD';
    }

    final product = json['product'] as Map<String, dynamic>? ?? json;
    return Product(
      id: product['id'].toString(),
      name: product['name'] as String,
      brand: product['brand'] as String,
      category: product['category'] as String,
      price: price,
      currency: currency,
      imageUrl: product['image_url'] as String? ?? '',
      description: product['description'] as String? ?? '',
      ingredients: List<String>.from(product['ingredients'] ?? []),
      rating: double.tryParse(product['avg_rating']?.toString() ?? '0') ?? 0,
      reviewCount: product['review_count'] as int? ?? 0,
      functionalities: List<String>.from(product['functionalities'] ?? []),
      availableCountries: availableCountries,
      onlineStores: onlineStoresSet.toList(),
      localStores: localStores,
    );
  }
}
