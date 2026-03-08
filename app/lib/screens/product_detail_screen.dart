import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final String countryCode;
  final String currency;

  const ProductDetailScreen({
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Hero image + back/favorite buttons
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.pink : Colors.black87,
                    ),
                    onPressed: () => favorites.toggle(product),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.pink.shade50,
                  child: const Icon(Icons.spa, size: 100, color: Colors.pink),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand + Category + Functionalities
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(product.category,
                            style: TextStyle(
                                color: Colors.pink[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Text(product.brand,
                          style: TextStyle(
                              color: Colors.pink[400],
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Functionality tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: product.functionalities
                        .map((f) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.purple.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome,
                                      size: 11,
                                      color: Colors.purple[400]),
                                  const SizedBox(width: 3),
                                  Text(f,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.purple[700],
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  // Name
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),

                  // Rating + Reviews
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        return Icon(
                          i < product.rating.floor()
                              ? Icons.star
                              : (i < product.rating
                                  ? Icons.star_half
                                  : Icons.star_border),
                          color: Colors.amber[600],
                          size: 18,
                        );
                      }),
                      const SizedBox(width: 6),
                      Text(product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('(${product.reviewCount} reviews)',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Price
                  Text(
                    '$currency ${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.pink[600],
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  const Text('About',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(product.description,
                      style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.5,
                          fontSize: 14)),
                  const SizedBox(height: 24),

                  // Where to Buy
                  const Text('Where to Buy',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  // Local Stores
                  if (localStores.isNotEmpty) ...[
                    _sectionLabel(
                        Icons.store, 'Local Stores', Colors.green[700]!),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: localStores
                          .map((store) => _storeBadge(store,
                              Colors.green.shade50, Colors.green.shade200,
                              Colors.green[800]!))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _sectionLabel(
                        Icons.store, 'Local Stores', Colors.grey[500]!),
                    const SizedBox(height: 8),
                    Text('Not available in local stores for this country.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    const SizedBox(height: 16),
                  ],

                  // Online Stores
                  _sectionLabel(
                      Icons.laptop, 'Online Stores', Colors.blue[700]!),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.onlineStores
                        .map((store) => _storeBadge(store, Colors.blue.shade50,
                            Colors.blue.shade200, Colors.blue[800]!))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Ingredients
                  const Text('Ingredients',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'Full ingredient list:',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  ...product.ingredients.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.pink[400],
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(entry.value,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[800],
                                    height: 1.4)),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: color)),
      ],
    );
  }

  Widget _storeBadge(
      String name, Color bg, Color border, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(name,
          style: TextStyle(
              fontSize: 12, color: textColor, fontWeight: FontWeight.w600)),
    );
  }
}
