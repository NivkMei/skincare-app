import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import '../data/ingredient_data.dart';

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
    final l10n = AppLocalizations.of(context);

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
                      Text(l10n.reviews(product.reviewCount),
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Price
                  Text(
                    product.priceRange(currency),
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
                  Text(l10n.about,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(product.description,
                      style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.5,
                          fontSize: 14)),
                  const SizedBox(height: 24),

                  // Where to Buy
                  Text(l10n.whereToBuy,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  // Local Stores
                  if (localStores.isNotEmpty) ...[  
                    _sectionLabel(
                        Icons.store, l10n.localStores, Colors.green[700]!),
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
                        Icons.store, l10n.localStores, Colors.grey[500]!),
                    const SizedBox(height: 8),
                    Text(l10n.notInLocalStores,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    const SizedBox(height: 16),
                  ],

                  // Online Stores
                  _sectionLabel(
                      Icons.laptop, l10n.onlineStores, Colors.blue[700]!),
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
                  Text(l10n.ingredients,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _IngredientTable(ingredients: product.ingredients),
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

// ── CosDNA-style ingredient table ─────────────────────────────────────────
class _IngredientTable extends StatelessWidget {
  final List<String> ingredients;
  const _IngredientTable({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Header row
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 22),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Text(l10n.ingredientCol,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54)),
                ),
                _headerCell(l10n.functionCol, flex: 5),
                _headerCell(l10n.acneRiskCol, flex: 2, center: true),
                _headerCell(l10n.irritantCol, flex: 2, center: true),
                _headerCell(l10n.safetyCol, flex: 2, center: true),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          // Data rows
          ...ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final name = entry.value;
            final info = lookupIngredient(name);
            final isEven = index.isEven;
            return Column(
              children: [
                Container(
                  color: isEven ? Colors.white : Colors.grey.shade50,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row number
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.pink[400],
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Ingredient name
                      Expanded(
                        flex: 5,
                        child: Text(
                          name,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.3),
                        ),
                      ),
                      // Function
                      Expanded(
                        flex: 5,
                        child: Text(
                          info?.function ?? '—',
                          style: TextStyle(
                              fontSize: 11,
                              color: info != null
                                  ? Colors.grey[700]
                                  : Colors.grey[400],
                              height: 1.3),
                        ),
                      ),
                      // Acne Risk badge
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: _ratingBadge(
                            info?.acneRisk,
                            type: _BadgeType.acne,
                          ),
                        ),
                      ),
                      // Irritant badge
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: _ratingBadge(
                            info?.irritant,
                            type: _BadgeType.irritant,
                          ),
                        ),
                      ),
                      // Safety badge
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: _ratingBadge(
                            info?.safety,
                            type: _BadgeType.safety,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < ingredients.length - 1)
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
              ],
            );
          }),
          // Legend
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    l10n.ingredientLegend,
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {int flex = 1, bool center = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.black54),
      ),
    );
  }

  Widget _ratingBadge(int? value, {required _BadgeType type}) {
    if (value == null) {
      return Text('—',
          style: TextStyle(fontSize: 11, color: Colors.grey[400]));
    }
    final color = _badgeColor(value, type);
    return Container(
      width: 26,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$value',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }

  Color _badgeColor(int value, _BadgeType type) {
    if (type == _BadgeType.safety) {
      if (value <= 2) return const Color(0xFF27AE60);
      if (value <= 3) return const Color(0xFFF39C12);
      return const Color(0xFFE74C3C);
    } else {
      // acneRisk / irritant: 0 = green, 1-2 = yellow, 3+ = red
      if (value == 0) return const Color(0xFF27AE60);
      if (value <= 2) return const Color(0xFFF39C12);
      return const Color(0xFFE74C3C);
    }
  }
}

enum _BadgeType { acne, irritant, safety }
