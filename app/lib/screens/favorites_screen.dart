import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_products.dart';
import '../providers/country_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoritesProvider>();
    final country = context.watch<CountryProvider>().selectedCountry;
    final favorites = favProvider.getFavorites(mockProducts);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Favorites',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Colors.black87)),
            Text(
              favorites.isEmpty
                  ? 'No saved products'
                  : '${favorites.length} saved product${favorites.length > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline,
                      size: 80, color: Colors.pink[200]),
                  const SizedBox(height: 16),
                  const Text('No favorites yet',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart on any product\nto save it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.50,
              ),
              itemCount: favorites.length,
              itemBuilder: (_, i) => ProductCard(
                product: favorites[i],
                countryCode: country.code,
                currency: country.currency,
              ),
            ),
    );
  }
}
