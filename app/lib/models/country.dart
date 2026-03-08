class Country {
  final String code;
  final String name;
  final String flag;
  final String currency;
  final List<String> localStoreNames;
  final List<String> onlineStoreNames;

  const Country({
    required this.code,
    required this.name,
    required this.flag,
    required this.currency,
    required this.localStoreNames,
    required this.onlineStoreNames,
  });
}

final List<Country> supportedCountries = [
  Country(
    code: 'HK',
    name: 'Hong Kong',
    flag: '🇭🇰',
    currency: 'HKD',
    localStoreNames: ['SaSa', 'Watsons', 'Manning'],
    onlineStoreNames: ['HKTVmall', 'LOG-ON Online', 'SASA.com'],
  ),
  Country(
    code: 'SG',
    name: 'Singapore',
    flag: '🇸🇬',
    currency: 'SGD',
    localStoreNames: ['Guardian', 'Watsons', 'Sephora'],
    onlineStoreNames: ['Lazada', 'Shopee', 'Zalora'],
  ),
  Country(
    code: 'MY',
    name: 'Malaysia',
    flag: '🇲🇾',
    currency: 'MYR',
    localStoreNames: ['Watsons', 'Guardian', 'Caring Pharmacy'],
    onlineStoreNames: ['Lazada', 'Shopee', 'Zalora'],
  ),
  Country(
    code: 'TW',
    name: 'Taiwan',
    flag: '🇹🇼',
    currency: 'TWD',
    localStoreNames: ['Watsons', 'Cosmed', 'Poya'],
    onlineStoreNames: ['Momo', 'PChome', 'shopee.tw'],
  ),
  Country(
    code: 'JP',
    name: 'Japan',
    flag: '🇯🇵',
    currency: 'JPY',
    localStoreNames: ['Matsumoto Kiyoshi', 'Sundrug', 'Ain Pharmacy'],
    onlineStoreNames: ['Amazon JP', 'Rakuten', 'Cosme-de.com'],
  ),
];

Country getCountryByCode(String code) =>
    supportedCountries.firstWhere((c) => c.code == code,
        orElse: () => supportedCountries.first);
