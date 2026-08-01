import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'offline_banner.dart';
import 'siix_logo.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(label: 'Home',     icon: Icons.home_rounded,          route: '/dashboard'),
    _NavItem(label: 'Scan',     icon: Icons.sensors_rounded,       route: '/movement'),
    _NavItem(label: 'Stock',    icon: Icons.inventory_2_rounded,   route: '/stock'),
    _NavItem(label: 'Find',     icon: Icons.location_searching_rounded, route: '/find'),
    _NavItem(label: 'Menu',     icon: Icons.grid_view_rounded,     route: '/menu'),
  ];

  static const List<String> _menuSubRoutes = <String>[
    '/menu',
    '/history',
    '/scrap',
    '/trays',
    '/profile',
    '/register',
    '/settings',
  ];

  int _selectedIndex() {
    if (_menuSubRoutes.any(location.startsWith)) return _items.length - 1;
    for (var i = 0; i < _items.length; i++) {
      if (location.startsWith(_items[i].route)) return i;
    }
    return 0;
  }

  String _titleFor() {
    if (location.startsWith('/dashboard')) return 'Dashboard';
    if (location.startsWith('/movement'))  return 'RFID Scan';
    if (location.startsWith('/stock'))     return 'Stock';
    if (location.startsWith('/find'))      return 'Find Tray';
    if (location.startsWith('/register'))  return 'Register RFID';
    if (location.startsWith('/history'))   return 'Movement History';
    if (location.startsWith('/scrap'))     return 'Scrap Center';
    if (location.startsWith('/trays'))     return 'Tray Directory';
    if (location.startsWith('/profile'))   return 'Profile';
    if (location.startsWith('/settings'))  return 'Settings';
    return 'Menu';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme   = Theme.of(context);
    final cs      = theme.extension<AppColorScheme>()!;
    final user    = ref.watch(authControllerProvider).user;
    final isTablet = MediaQuery.sizeOf(context).width >= 900;
    final selIdx  = _selectedIndex();

    final appBar = PreferredSize(
      preferredSize: const Size.fromHeight(AppSpacing.appBarH + 1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            toolbarHeight: AppSpacing.appBarH,
            title: Row(
              children: [
                const SiixLogo(width: 76, showTagline: false),
                Container(
                  width: 1,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: theme.colorScheme.outline,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _titleFor(),
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user != null)
                        Text(
                          user.name,
                          style: theme.textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Settings',
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.tune_rounded, size: 24),
              ),
              IconButton(
                tooltip: 'Profile',
                onPressed: () => context.go('/profile'),
                icon: CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          Divider(height: 1, thickness: 1, color: theme.colorScheme.outline),
        ],
      ),
    );

    final bottomNav = Container(
      decoration: BoxDecoration(
        color: theme.navigationBarTheme.backgroundColor,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selIdx,
          onDestinationSelected: (i) => context.go(_items[i].route),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
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
    );

    if (isTablet) {
      return Scaffold(
        appBar: appBar,
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: Row(
                children: [
                  NavigationRail(
                    extended: MediaQuery.sizeOf(context).width >= 1200,
                    selectedIndex: selIdx,
                    onDestinationSelected: (i) => context.go(_items[i].route),
                    backgroundColor: cs.surfaceCard,
                    destinations: _items
                        .map(
                          (item) => NavigationRailDestination(
                            icon: Icon(item.icon),
                            label: Text(item.label),
                          ),
                        )
                        .toList(),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: theme.colorScheme.outline,
                  ),
                  Expanded(child: SafeArea(child: child)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: SafeArea(top: false, child: child)),
        ],
      ),
      bottomNavigationBar: bottomNav,
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
