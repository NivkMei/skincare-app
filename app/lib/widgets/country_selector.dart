import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/country.dart';
import '../providers/country_provider.dart';
import '../providers/language_provider.dart';

class CountrySelectorSheet extends StatelessWidget {
  const CountrySelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<CountryProvider>().selectedCountry;
    final langProvider = context.watch<LanguageProvider>();
    final isEn = langProvider.isEnglish;

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
          // ── Language toggle ────────────────────────────────────────────
          Row(
            children: [
              const Text('Language',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              _LangSegment(
                isEnglish: isEn,
                onTap: (en) {
                  if (en != isEn) langProvider.toggle();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // ── Country list ───────────────────────────────────────────────
          const Text('Country',
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

// ── Segmented EN / 繁中 toggle ──────────────────────────────────────────────
class _LangSegment extends StatelessWidget {
  final bool isEnglish;
  final void Function(bool en) onTap;
  const _LangSegment({required this.isEnglish, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tab('EN', selected: isEnglish, onTap: () => onTap(true)),
          _tab('繁中', selected: !isEnglish, onTap: () => onTap(false)),
        ],
      ),
    );
  }

  Widget _tab(String label,
      {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.pink[400] : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
