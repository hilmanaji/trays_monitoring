// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trays_monitoring/presentation/screens/auth/login_screen.dart';

void main() {
  testWidgets('login screen renders required controls', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LoginScreen(
            onLogin: ({required nik, required password}) async {},
          ),
        ),
      ),
    );

    expect(find.text('Tray Monitoring'), findsOneWidget);
    expect(find.text('NIK'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk / Sign in'), findsOneWidget);
  });
}
