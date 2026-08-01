import 'package:flutter/material.dart';

import '../../theme/neo_theme.dart';
import '../../widgets/neo_box.dart';
import '../../widgets/siix_logo.dart';

/// Boot screen. Deliberately built from the same pieces as the login screen —
/// brand tile, title, kicker — so the handoff between them reads as one surface
/// settling rather than two different apps.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return Scaffold(
      backgroundColor: neo.ground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeoBox(
                  radius: 24,
                  elevation: 1.1,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: const SiixLogo(width: 110, showTagline: false),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tray Monitoring',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.05,
                    color: neo.ink,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'RFID TRAY CONTROL · UROVO DT40',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: neo.inkFaint,
                  ),
                ),

                // Indeterminate fill running through the same groove the
                // progress bars elsewhere in the app use.
                const SizedBox(height: 34),
                SizedBox(
                  width: 190,
                  child: NeoBox.inset(
                    height: 10,
                    radius: 5,
                    elevation: 0.55,
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          neo.accentEnd,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Menyiapkan sesi…',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: neo.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
