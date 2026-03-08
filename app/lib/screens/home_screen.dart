import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'product_list_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ProductListScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final favCount = context.watch<FavoritesProvider>().count;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite),
            ),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
