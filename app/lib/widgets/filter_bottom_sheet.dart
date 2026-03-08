import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../data/mock_products.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _category;
  String? _functionality;
  String? _brand;
  double _maxPrice = 1500;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductProvider>();
    _category = provider.selectedCategory;
    _functionality = provider.selectedFunctionality;
    _brand = provider.selectedBrand;
    _maxPrice = provider.maxPrice ?? 1500;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['', ...allCategories];
    final functionalities = allFunctionalities;
    final brands = ['', ...allBrands];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        color: Colors.white,
      ),
      child: ListView(
        controller: scrollController,
        shrinkWrap: true,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _category = null;
                    _functionality = null;
                    _brand = null;
                    _maxPrice = 1500;
                  });
                },
                child: Text('Reset', style: TextStyle(color: Colors.pink[400])),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Category
          const Text('Category',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final label = cat.isEmpty ? 'All' : cat;
              final isSelected = (_category ?? '') == cat;
              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                selectedColor: Colors.pink[100],
                onSelected: (_) =>
                    setState(() => _category = cat.isEmpty ? null : cat),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.pink[700] : Colors.black87,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Functionality
          const Text('Functionality',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _funcChip('All', null),
              ...functionalities.map((f) => _funcChip(f, f)),
            ],
          ),
          const SizedBox(height: 16),

          // Brand
          const Text('Brand',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _brand ?? '',
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!)),
            ),
            items: brands.map((b) {
              return DropdownMenuItem(
                  value: b, child: Text(b.isEmpty ? 'All Brands' : b));
            }).toList(),
            onChanged: (val) =>
                setState(() => _brand = (val == null || val.isEmpty) ? null : val),
          ),
          const SizedBox(height: 16),

          // Price Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Max Price',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('HKD ${_maxPrice.toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.pink[400], fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(
            value: _maxPrice,
            min: 50,
            max: 1500,
            divisions: 29,
            activeColor: Colors.pink[400],
            label: 'HKD ${_maxPrice.toStringAsFixed(0)}',
            onChanged: (val) => setState(() => _maxPrice = val),
          ),
          const SizedBox(height: 8),

          // Apply
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final provider = context.read<ProductProvider>();
                provider.setCategory(_category);
                provider.setFunctionality(_functionality);
                provider.setBrand(_brand);
                provider.setMaxPrice(_maxPrice < 1500 ? _maxPrice : null);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _funcChip(String label, String? value) {
    final isSelected = _functionality == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.purple[100],
      onSelected: (_) => setState(() => _functionality = value),
      labelStyle: TextStyle(
        color: isSelected ? Colors.purple[700] : Colors.black87,
        fontSize: 12,
      ),
    );
  }
}
