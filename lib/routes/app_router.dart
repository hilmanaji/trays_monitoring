import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/providers/auth_controller.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/history/movement_history_screen.dart';
import '../presentation/screens/menu/menu_screen.dart';
import '../presentation/screens/movement/tray_movement_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/rfid/rfid_registration_screen.dart';
import '../presentation/screens/scrap/scrap_screen.dart';
import '../presentation/screens/stock/stock_screen.dart';
import '../presentation/screens/tray/tray_detail_screen.dart';
import '../presentation/screens/tray/tray_list_screen.dart';
import '../presentation/widgets/app_shell.dart';

final routerRefreshNotifierProvider = Provider<_RouterRefreshNotifier>((ref) {
  final notifier = _RouterRefreshNotifier();
  ref.listen<AuthState>(
    authControllerProvider,
    (previous, next) => notifier.refresh(),
  );
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isAtLogin = location == '/login';
      final isAtSplash = location == '/splash';

      if (authState.status == AuthStatus.unknown ||
          authState.status == AuthStatus.loading) {
        return isAtSplash ? null : '/splash';
      }

      if (!authState.isAuthenticated) {
        return isAtLogin ? null : '/login';
      }

      if (isAtLogin || isAtSplash) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const RfidRegistrationScreen(),
          ),
          GoRoute(
            path: '/movement',
            builder: (context, state) => const TrayMovementScreen(),
          ),
          GoRoute(
            path: '/stock',
            builder: (context, state) => const StockScreen(),
          ),
          GoRoute(path: '/menu', builder: (context, state) => const MenuScreen()),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const MovementHistoryScreen(),
          ),
          GoRoute(
            path: '/scrap',
            builder: (context, state) => const ScrapScreen(),
          ),
          GoRoute(
            path: '/trays',
            builder: (context, state) => const TrayListScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final id =
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return TrayDetailScreen(trayId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}
