import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import 'auth/login_screen.dart';
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
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // Floating profile button (top-left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _ProfileButton(auth: auth),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.spa_outlined),
            selectedIcon: const Icon(Icons.spa),
            label: l10n.products,
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
            label: l10n.favoritesTab,
          ),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final AuthProvider auth;
  const _ProfileButton({required this.auth});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (auth.isLoggedIn) {
      return PopupMenuButton<String>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tooltip: auth.userName ?? l10n.profile,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            (auth.userName?.isNotEmpty == true)
                ? auth.userName![0].toUpperCase()
                : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onSelected: (v) async {
          if (v == 'logout') {
            await context.read<AuthProvider>().logout();
            if (!context.mounted) return;
            await context
                .read<FavoritesProvider>()
                .onAuthChanged(isLoggedIn: false);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            enabled: false,
            child: Text(auth.userEmail ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'logout',
            child: Row(children: [
              const Icon(Icons.logout, size: 18),
              const SizedBox(width: 8),
              Text(l10n.logout),
            ]),
          ),
        ],
      );
    }
    return IconButton.filled(
      onPressed: () => LoginScreen.show(context),
      icon: const Icon(Icons.person_outline),
      tooltip: l10n.login,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
