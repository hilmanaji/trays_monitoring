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

  // ── Neomorphism ("soft UI") ──────────────────────────────────────────────
  // A single ground colour carries the whole surface; depth comes from a pair
  // of shadows (dark bottom-right, white top-left) instead of borders.

  /// Light ground — every card, field, tab and button sits on this exact colour.
  static const neoGround      = Color(0xFFE9EDF3);
  static const neoShadowDark  = Color(0xFFCCD2DC);
  static const neoShadowLight = Color(0xFFFFFFFF);

  /// Dark ground — same recipe, inverted luminance.
  static const neoGroundDark      = Color(0xFF262B33);
  static const neoShadowDarkDeep  = Color(0xFF1B1F26);
  static const neoShadowLightDeep = Color(0xFF333A45);

  /// Steel-blue accent — primary actions, tag counters, active states only.
  static const neoAccentStart = Color(0xFF6A90B6);
  static const neoAccentEnd   = Color(0xFF4D7396);
  static const neoAccentDim   = Color(0xFF8CA9C6);

  /// Neutral accent — destructive / secondary emphasis (Scrap).
  static const neoMutedStart = Color(0xFF9AA4B2);
  static const neoMutedEnd   = Color(0xFF7A8494);

  // Text ramp — kept deliberately dark: neomorphic contrast is already low and
  // the app is used in brightly-lit warehouses.
  static const neoInk       = Color(0xFF2B3340);
  static const neoInkMuted  = Color(0xFF7A8494);
  static const neoInkFaint  = Color(0xFF9AA4B2);
  static const neoInkGhost  = Color(0xFFA3ADBB);
  static const neoTrack     = Color(0xFFE0E5EE);

  static const neoInkDark       = Color(0xFFE7EBF2);
  static const neoInkMutedDark  = Color(0xFF9BA6B6);
  static const neoInkFaintDark  = Color(0xFF7E8896);
  static const neoTrackDark     = Color(0xFF323945);
}
