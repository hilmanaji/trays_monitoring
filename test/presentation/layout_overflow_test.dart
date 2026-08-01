import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trays_monitoring/presentation/providers/app_providers.dart';
import 'package:trays_monitoring/presentation/screens/auth/splash_screen.dart';
import 'package:trays_monitoring/presentation/screens/find/find_screen.dart';
import 'package:trays_monitoring/presentation/theme/app_theme.dart';
import 'package:trays_monitoring/services/rfid/rfid_service.dart';
import 'package:trays_monitoring/services/rfid/simulated_rfid_scanner.dart';

/// Handheld-sized viewports. The DT40 is short and narrow, which is exactly
/// where fixed-size soft-UI blocks (the geiger dial, data tables) overflow.
const _handheld = Size(375, 667);
const _shortHandheld = Size(360, 520);

Future<void> _pump(WidgetTester tester, Widget child, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Keeps the tree off platform channels; the screen never scans here.
        rfidServiceProvider.overrideWithValue(
          RFIDService(SimulatedRFIDScanner()),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: child),
    ),
  );
  await tester.pump();
}

void main() {
  group('FindScreen fits handheld viewports', () {
    testWidgets('renders without overflow at 375x667', (tester) async {
      await _pump(tester, const FindScreen(), _handheld);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a short 360x520 screen',
        (tester) async {
      await _pump(tester, const FindScreen(), _shortHandheld);
      expect(tester.takeException(), isNull);
    });
  });

  group('SplashScreen fits handheld viewports', () {
    testWidgets('renders without overflow at 375x667', (tester) async {
      await _pump(tester, const SplashScreen(), _handheld);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a short 360x520 screen',
        (tester) async {
      await _pump(tester, const SplashScreen(), _shortHandheld);
      expect(tester.takeException(), isNull);
    });
  });
}
