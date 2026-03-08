import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/country_provider.dart';
import 'providers/product_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SkincareApp());
}

class SkincareApp extends StatelessWidget {
  const SkincareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Skincare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
            brightness: Brightness.light,
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            scrolledUnderElevation: 1,
          ),
          navigationBarTheme: const NavigationBarThemeData(
            indicatorColor: Color(0xFFFCE4EC),
          ),
        ),
        home: const _AppRoot(),
      ),
    );
  }
}

/// Triggers the first product load once the country is known.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _initialLoadDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoadDone) {
      _initialLoadDone = true;
      final country = context.read<CountryProvider>().selectedCountry.code;
      context.read<ProductProvider>().loadProducts(country);
    }
  }

  @override
  Widget build(BuildContext context) => const HomeScreen();
}

