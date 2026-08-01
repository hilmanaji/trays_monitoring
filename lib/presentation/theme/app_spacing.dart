/// 8dp grid spacing constants for TrayTrack.
abstract final class AppSpacing {
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 16.0;
  static const double lg   = 24.0;
  static const double xl   = 32.0;
  static const double xxl  = 48.0;
  static const double xxxl = 64.0;

  // ── Touch targets ─────────────────────────────────────────────────────────
  /// Absolute minimum for any interactive element
  static const double touchMin     = 56.0;
  /// Comfortable for bare hands
  static const double touchComfort = 64.0;
  /// Glove-mode: extra-large targets
  static const double touchGlove   = 72.0;

  // ── Border radius ─────────────────────────────────────────────────────────
  static const double radiusXs  = 6.0;
  static const double radiusSm  = 8.0;
  static const double radiusMd  = 12.0;
  static const double radiusLg  = 16.0;
  static const double radiusXl  = 24.0;
  static const double radiusXxl = 32.0;

  // ── Neomorphic radii ──────────────────────────────────────────────────────
  // Soft UI needs generous corners so the shadow pair can wrap the edge.
  /// Chips, tabs, small badges.
  static const double radiusNeoSm = 15.0;
  /// Default for cards, fields and buttons.
  static const double radiusNeo   = 20.0;
  /// Panels, sheets and full-bleed containers.
  static const double radiusNeoLg = 26.0;

  // ── Layout ────────────────────────────────────────────────────────────────
  static const double screenPadding = 16.0;
  static const double cardPadding   = 20.0;
  static const double appBarH       = 70.0;
  static const double navBarH       = 76.0;
  static const double bottomBarH    = 80.0;

  // ── Gaps ──────────────────────────────────────────────────────────────────
  static const double sectionGap    = 16.0;
  static const double itemGap       = 10.0;
  static const double tileGap       = 8.0;
}
