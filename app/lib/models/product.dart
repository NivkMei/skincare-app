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
}
