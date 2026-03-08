import 'package:flutter/foundation.dart';
import '../models/country.dart';

class CountryProvider extends ChangeNotifier {
  Country _selectedCountry = getCountryByCode('HK');

  Country get selectedCountry => _selectedCountry;

  void selectCountry(String code) {
    final country = getCountryByCode(code);
    if (country.code != _selectedCountry.code) {
      _selectedCountry = country;
      notifyListeners();
    }
  }
}
