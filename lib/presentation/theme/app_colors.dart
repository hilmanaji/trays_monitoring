import 'package:flutter/material.dart';

/// Raw palette — consumed by [AppColorScheme] and [AppTheme].
/// Do NOT use these directly in widgets; use the ThemeExtension instead.
abstract final class AppColors {
  // ── Brand / Primary ──────────────────────────────────────────────────────
  static const primary400 = Color(0xFF4D94FF);
  static const primary500 = Color(0xFF1E7BFF);
  static const primary600 = Color(0xFF165DDB);
  static const primary700 = Color(0xFF0A3B7A);

  // ── Neutral scale (dark → light) ─────────────────────────────────────────
  static const neutral950 = Color(0xFF020810);
  static const neutral900 = Color(0xFF060D18);
  static const neutral850 = Color(0xFF09111E);
  static const neutral800 = Color(0xFF0D1B2E);
  static const neutral750 = Color(0xFF10213A);
  static const neutral700 = Color(0xFF152338);
  static const neutral600 = Color(0xFF1E3250);
  static const neutral500 = Color(0xFF2D4A6A);
  static const neutral400 = Color(0xFF4D6A8A);
  static const neutral300 = Color(0xFF7A9ABB);
  static const neutral200 = Color(0xFFB0C7DD);
  static const neutral100 = Color(0xFFDDE8F5);
  static const neutral50  = Color(0xFFF0F4FF);

  // ── Status: OK / Scanned ─────────────────────────────────────────────────
  static const green500  = Color(0xFF22C55E);
  static const green600  = Color(0xFF16A34A);
  static const green700  = Color(0xFF15803D);
  static const green900  = Color(0xFF052E16);
  static const greenLight = Color(0xFFDCFCE7);

  // ── Status: Error / Missing ──────────────────────────────────────────────
  static const red500   = Color(0xFFEF4444);
  static const red700   = Color(0xFFB91C1C);
  static const red900   = Color(0xFF2D0909);
  static const redLight  = Color(0xFFFEE2E2);

  // ── Status: Warning / Unexpected ─────────────────────────────────────────
  static const amber500  = Color(0xFFF59E0B);
  static const amber700  = Color(0xFFD97706);
  static const amber900  = Color(0xFF2D1A00);
  static const amberLight = Color(0xFFFEF3C7);

  // ── Status: Idle / Pending ───────────────────────────────────────────────
  static const slate400  = Color(0xFF94A3B8);
  static const slate600  = Color(0xFF475569);
  static const slateLight = Color(0xFFF1F5F9);
  static const slateDark  = Color(0xFF1E2C3A);

  // ── Status: Active / Scanning ────────────────────────────────────────────
  static const blue400  = Color(0xFF60A5FA);
  static const blue500  = Color(0xFF3B82F6);
  static const blue900  = Color(0xFF0D1E3A);
  static const blueLight = Color(0xFFEFF6FF);
}
