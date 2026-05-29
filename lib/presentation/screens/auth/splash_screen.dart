import 'package:flutter/material.dart';

import '../../widgets/siix_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF08244A), Color(0xFF165DDB), Color(0xFF6DC6FF)],
          ),
        ),
        child: Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33081730),
                  blurRadius: 28,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SiixLogo(width: 150),
                SizedBox(height: 18),
                Text(
                  'Tray Monitoring',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF081120),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Warehouse RFID workflow is preparing your session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.4,
                    color: Color(0xFF6B7A90),
                  ),
                ),
                SizedBox(height: 22),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
