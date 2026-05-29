import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/storage/hive_storage_service.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/theme/app_theme.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorageService.instance.initialize();
  runApp(const ProviderScope(child: TrayMonitoringApp()));
}

class TrayMonitoringApp extends ConsumerWidget {
  const TrayMonitoringApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(pendingSyncBootstrapProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'RFID Tray Tracking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
