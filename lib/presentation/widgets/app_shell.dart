import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_controller.dart';
import '../theme/app_spacing.dart';
import '../theme/neo_theme.dart';
import 'neo_box.dart';
import 'offline_banner.dart';
import 'siix_logo.dart';

/// App chrome: soft header, ground-coloured body, and an inset tab tray whose
/// selected item is the only accent-gradient surface on screen.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(label: 'Home',  icon: Icons.home_rounded,               route: '/dashboard'),
    _NavItem(label: 'Scan',  icon: Icons.sensors_rounded,            route: '/movement'),
    _NavItem(label: 'Stock', icon: Icons.inventory_2_rounded,        route: '/stock'),
    _NavItem(label: 'Find',  icon: Icons.location_searching_rounded, route: '/find'),
    _NavItem(label: 'Menu',  icon: Icons.grid_view_rounded,          route: '/menu'),
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

  /// Title + kicker for the current route, mirroring the design's header pair.
  (String, String) _titleFor() {
    if (location.startsWith('/dashboard')) return ('Dashboard', 'BERANDA / OVERVIEW');
    if (location.startsWith('/movement'))  return ('RFID Scan', 'TRANSFER LOKASI');
    if (location.startsWith('/stock'))     return ('Stock', 'LIVE INVENTORY');
    if (location.startsWith('/find'))      return ('Find Tray', 'GEIGER / LOCATE');
    if (location.startsWith('/register'))  return ('Register RFID', 'NEW TRAY · BULK READ');
    if (location.startsWith('/history'))   return ('Movement History', 'TRANSACTION LOG');
    if (location.startsWith('/scrap'))     return ('Scrap Center', 'DISPOSAL / WRITE-OFF');
    if (location.startsWith('/trays'))     return ('Tray Directory', 'TRAY RECORDS');
    if (location.startsWith('/profile'))   return ('Profile', 'OPERATOR');
    if (location.startsWith('/settings'))  return ('Settings', 'READER & DEVICE');
    return ('Menu', 'ALL MODULES');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final neo      = context.neo;
    final user     = ref.watch(authControllerProvider).user;
    final isTablet = MediaQuery.sizeOf(context).width >= 900;
    final selIdx   = _selectedIndex();
    final (title, kicker) = _titleFor();

    final appBar = PreferredSize(
      preferredSize: const Size.fromHeight(AppSpacing.appBarH),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
          child: Row(
            children: [
              const SiixLogo(width: 68, showTagline: false),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: neo.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kicker,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                        color: neo.inkFaint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              NeoBox(
                radius: AppSpacing.radiusNeoSm,
                elevation: 0.7,
                width: 42,
                height: 42,
                alignment: Alignment.center,
                onTap: () => context.go('/settings'),
                child: Icon(Icons.tune_rounded, size: 19, color: neo.accentEnd),
              ),
              const SizedBox(width: 8),
              // Operator badge — the design's zone/operator code block.
              NeoBox.inset(
                radius: AppSpacing.radiusNeoSm,
                elevation: 0.6,
                onTap: () => context.go('/profile'),
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      user != null ? 'NIK ${user.nik}' : 'GUEST',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: neo.inkMuted,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Not signed in',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: neo.inkGhost,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                    backgroundColor: neo.ground,
                    destinations: _items
                        .map(
                          (item) => NavigationRailDestination(
                            icon: Icon(item.icon),
                            label: Text(item.label),
                          ),
                        )
                        .toList(),
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
          Expanded(child: SafeArea(top: false, bottom: false, child: child)),
        ],
      ),
      bottomNavigationBar: _NeoTabTray(
        items: _items,
        selectedIndex: selIdx,
        onSelected: (i) => context.go(_items[i].route),
      ),
    );
  }
}

/// Inset tray holding the tabs; the active tab is extruded in accent gradient.
class _NeoTabTray extends StatelessWidget {
  const _NeoTabTray({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      color: neo.ground,
      padding: EdgeInsets.fromLTRB(14, 4, 14, 10 + bottom),
      child: NeoBox.inset(
        radius: AppSpacing.radiusNeoLg,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: _NeoTab(
                  item: items[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NeoTab extends StatelessWidget {
  const _NeoTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final fg = selected ? neo.onAccent : neo.inkMuted;

    return NeoBox(
      // Unselected tabs stay flat inside the well — only the active one lifts.
      depth: selected ? NeoDepth.accent : NeoDepth.flat,
      elevation: 0.7,
      radius: AppSpacing.radiusNeoSm + 3,
      height: 52,
      onTap: onTap,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 19, color: fg),
          const SizedBox(height: 3),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
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
