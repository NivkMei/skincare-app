import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String countryCode;
  final String currency;

  const ProductCard({
    super.key,
    required this.product,
    required this.countryCode,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorite(product.id);
    final localStores = product.localStoresIn(countryCode);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: product,
            countryCode: countryCode,
            currency: currency,
          ),
        ),
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.pink.shade50,
                      child: const Icon(Icons.spa, size: 60, color: Colors.pink),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => favorites.toggle(product),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.pink : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: TextStyle(
                      color: Colors.pink.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade600, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount})',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$currency ${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.pink.shade600,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (localStores.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: localStores
                          .map(
                            (store) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                border: Border.all(
                                    color: Colors.green.shade200, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                store,
                                style: TextStyle(
                                    fontSize: 9, color: Colors.green[700]),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  // Functionality tags
                  if (product.functionalities.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: product.functionalities
                          .map(
                            (f) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                border: Border.all(
                                    color: Colors.purple.shade200, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                f,
                                style: TextStyle(
                                    fontSize: 9, color: Colors.purple[700]),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
