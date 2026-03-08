import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/country.dart';
import '../providers/country_provider.dart';

class CountrySelectorSheet extends StatelessWidget {
  const CountrySelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<CountryProvider>().selectedCountry;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select Country',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...supportedCountries.map((country) {
            final isSelected = country.code == current.code;
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              leading: Text(country.flag, style: const TextStyle(fontSize: 28)),
              title: Text(country.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                'Local: ${country.localStoreNames.join(', ')}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: Colors.pink[400])
                  : null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              tileColor: isSelected ? Colors.pink.shade50 : null,
              onTap: () {
                context.read<CountryProvider>().selectCountry(country.code);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}
