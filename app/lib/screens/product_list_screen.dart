import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/country_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/country_selector.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final countryProvider = context.watch<CountryProvider>();
    final productProvider = context.watch<ProductProvider>();
    final country = countryProvider.selectedCountry;
    final products =
        productProvider.filteredProducts(country.code);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Skincare',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Colors.black87)),
            Text('${products.length} products available',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
        actions: [
          // Country Selector Button
          GestureDetector(
            onTap: () => _showCountrySelector(context),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.pink.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(country.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Text(country.code,
                      style: TextStyle(
                          color: Colors.pink[600],
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16, color: Colors.pink[600]),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: productProvider.search,
                    decoration: InputDecoration(
                      hintText: 'Search products or brands...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey[400], size: 20),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showFilterSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: productProvider.hasActiveFilters
                          ? Colors.pink[400]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: productProvider.hasActiveFilters
                          ? Colors.white
                          : Colors.grey[700],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Active filter chips
          if (productProvider.hasActiveFilters)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  if (productProvider.selectedCategory != null)
                    _filterChip(
                        productProvider.selectedCategory!,
                        () => productProvider.setCategory(null)),
                  if (productProvider.selectedFunctionality != null)
                    _filterChip(
                        productProvider.selectedFunctionality!,
                        () => productProvider.setFunctionality(null)),
                  if (productProvider.selectedBrand != null)
                    _filterChip(
                        productProvider.selectedBrand!,
                        () => productProvider.setBrand(null)),
                  if (productProvider.maxPrice != null)
                    _filterChip(
                        '≤ HKD ${productProvider.maxPrice!.toStringAsFixed(0)}',
                        () => productProvider.setMaxPrice(null)),
                  const Spacer(),
                  TextButton(
                    onPressed: productProvider.clearFilters,
                    child: Text('Clear all',
                        style: TextStyle(
                            color: Colors.pink[400], fontSize: 12)),
                  ),
                ],
              ),
            ),
          // Category mode toggle + chip row
          _CategoryChipRow(productProvider: productProvider),
          // Local stores banner
          Container(
            color: Colors.green.shade50,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.store, color: Colors.green[700], size: 16),
                const SizedBox(width: 6),
                Text(
                  'Local in ${country.name}: ${country.localStoreNames.join(' · ')}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Product Grid
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('No products found',
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('Try adjusting your search or filters',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13)),
                        if (productProvider.error != null) ...
                          [
                            const SizedBox(height: 8),
                            Text(productProvider.error!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12)),
                          ],
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.50,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) => ProductCard(
                      product: products[i],
                      countryCode: country.code,
                      currency: country.currency,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white)),
        backgroundColor: Colors.pink[400],
        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
        onDeleted: onDelete,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _showCountrySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const CountrySelectorSheet(),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const FilterBottomSheet(),
    );
  }
}

// ─── Category mode toggle + horizontal chip scroller ─────────────────────────

class _CategoryChipRow extends StatelessWidget {
  final ProductProvider productProvider;
  const _CategoryChipRow({required this.productProvider});

  @override
  Widget build(BuildContext context) {
    final isTypeMode = productProvider.categoryMode == CategoryMode.productType;
    final chips = isTypeMode
        ? productProvider.allCategories
        : productProvider.allFunctionalities;
    final selectedChip = isTypeMode
        ? productProvider.selectedCategory
        : productProvider.selectedFunctionality;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Row(
              children: [
                _toggleTab(
                  context,
                  label: 'Product Type',
                  icon: Icons.category_outlined,
                  selected: isTypeMode,
                  onTap: () => productProvider
                      .setCategoryMode(CategoryMode.productType),
                ),
                const SizedBox(width: 8),
                _toggleTab(
                  context,
                  label: 'Functionality',
                  icon: Icons.auto_awesome_outlined,
                  selected: !isTypeMode,
                  onTap: () => productProvider
                      .setCategoryMode(CategoryMode.functionality),
                ),
              ],
            ),
          ),
          // Chips scroll row
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: chips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final chip = chips[i];
                final isSelected = selectedChip == chip;
                return GestureDetector(
                  onTap: () {
                    if (isTypeMode) {
                      productProvider
                          .setCategory(isSelected ? null : chip);
                    } else {
                      productProvider
                          .setFunctionality(isSelected ? null : chip);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.pink[400]
                          : Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.pink.shade400
                            : Colors.pink.shade200,
                      ),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : Colors.pink[600],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _toggleTab(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.pink[400] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
