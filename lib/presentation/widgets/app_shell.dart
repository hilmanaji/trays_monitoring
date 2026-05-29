import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';
import 'siix_logo.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const List<_NavigationItem> _items = <_NavigationItem>[
    _NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_rounded,
      route: '/dashboard',
    ),
    _NavigationItem(
      label: 'Register',
      icon: Icons.qr_code_2_rounded,
      route: '/register',
    ),
    _NavigationItem(
      label: 'Movement',
      icon: Icons.compare_arrows_rounded,
      route: '/movement',
    ),
    _NavigationItem(
      label: 'Stock',
      icon: Icons.inventory_2_rounded,
      route: '/stock',
    ),
    _NavigationItem(label: 'Menu', icon: Icons.grid_view_rounded, route: '/menu'),
  ];

  static const List<String> _menuRoutes = <String>[
    '/menu',
    '/history',
    '/scrap',
    '/trays',
    '/profile',
  ];

  int _selectedIndex() {
    if (_menuRoutes.any(location.startsWith)) {
      return _items.length - 1;
    }

    for (var index = 0; index < _items.length; index += 1) {
      if (location.startsWith(_items[index].route)) {
        return index;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _selectedIndex();
    final theme = Theme.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 900;
    final user = ref.watch(authControllerProvider).user;
    final currentLabel = _labelForLocation();

    final appBar = AppBar(
      toolbarHeight: 78,
      title: Row(
        children: [
          const SiixLogo(width: 82, showTagline: false),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(currentLabel),
                Text(
                  user?.name ?? 'Warehouse Operations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Profile',
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.person_outline_rounded),
        ),
        const SizedBox(width: 8),
      ],
    );

    if (isTablet) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width >= 1200,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => context.go(_items[index].route),
              destinations: _items
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: SafeArea(child: child)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: SafeArea(child: child),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => context.go(_items[index].route),
            destinations: _items
                .map(
                  (item) => NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  String _labelForLocation() {
    if (location.startsWith('/profile')) {
      return 'Profile';
    }
    if (location.startsWith('/history')) {
      return 'History Log';
    }
    if (location.startsWith('/scrap')) {
      return 'Scrap Center';
    }
    if (location.startsWith('/trays')) {
      return 'Tray Directory';
    }

    for (final item in _items) {
      if (location.startsWith(item.route)) {
        return item.label;
      }
    }

    return 'Tray Monitoring';
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
