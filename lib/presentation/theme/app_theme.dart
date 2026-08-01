import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'neo_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Semantic color extension
// Access via: Theme.of(context).extension<AppColorScheme>()!
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.statusOk,
    required this.statusOkContainer,
    required this.statusOkOnContainer,
    required this.statusError,
    required this.statusErrorContainer,
    required this.statusErrorOnContainer,
    required this.statusWarning,
    required this.statusWarningContainer,
    required this.statusWarningOnContainer,
    required this.statusIdle,
    required this.statusIdleContainer,
    required this.statusIdleOnContainer,
    required this.statusActive,
    required this.statusActiveContainer,
    required this.statusActiveOnContainer,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.divider,
    required this.scanPulse,
    required this.tagListBg,
    required this.headerGradientStart,
    required this.headerGradientEnd,
  });

  final Color statusOk;
  final Color statusOkContainer;
  final Color statusOkOnContainer;
  final Color statusError;
  final Color statusErrorContainer;
  final Color statusErrorOnContainer;
  final Color statusWarning;
  final Color statusWarningContainer;
  final Color statusWarningOnContainer;
  final Color statusIdle;
  final Color statusIdleContainer;
  final Color statusIdleOnContainer;
  final Color statusActive;
  final Color statusActiveContainer;
  final Color statusActiveOnContainer;
  final Color surfaceCard;
  final Color surfaceElevated;
  final Color divider;
  final Color scanPulse;
  final Color tagListBg;
  final Color headerGradientStart;
  final Color headerGradientEnd;

  static const light = AppColorScheme(
    statusOk: AppColors.green500,
    statusOkContainer: AppColors.greenLight,
    statusOkOnContainer: AppColors.green700,
    statusError: AppColors.red500,
    statusErrorContainer: AppColors.redLight,
    statusErrorOnContainer: AppColors.red700,
    statusWarning: AppColors.amber500,
    statusWarningContainer: AppColors.amberLight,
    statusWarningOnContainer: AppColors.amber700,
    statusIdle: AppColors.neoInkMuted,
    statusIdleContainer: AppColors.neoGround,
    statusIdleOnContainer: AppColors.neoInkMuted,
    statusActive: AppColors.neoAccentEnd,
    statusActiveContainer: Color(0xFFDFE7F1),
    statusActiveOnContainer: AppColors.neoAccentEnd,
    // Soft UI: every surface is the one ground colour — depth comes from the
    // NeoBox shadow pair, never from a lighter/darker fill.
    surfaceCard: AppColors.neoGround,
    surfaceElevated: AppColors.neoGround,
    divider: AppColors.neoTrack,
    scanPulse: AppColors.neoAccentEnd,
    tagListBg: AppColors.neoGround,
    headerGradientStart: AppColors.neoAccentStart,
    headerGradientEnd: AppColors.neoAccentEnd,
  );

  static const dark = AppColorScheme(
    statusOk: AppColors.green500,
    statusOkContainer: AppColors.green900,
    statusOkOnContainer: AppColors.green500,
    statusError: AppColors.red500,
    statusErrorContainer: AppColors.red900,
    statusErrorOnContainer: AppColors.red500,
    statusWarning: AppColors.amber500,
    statusWarningContainer: AppColors.amber900,
    statusWarningOnContainer: AppColors.amber500,
    statusIdle: AppColors.neoInkMutedDark,
    statusIdleContainer: AppColors.neoGroundDark,
    statusIdleOnContainer: AppColors.neoInkMutedDark,
    statusActive: AppColors.neoAccentDim,
    statusActiveContainer: Color(0xFF2E3742),
    statusActiveOnContainer: AppColors.neoAccentDim,
    surfaceCard: AppColors.neoGroundDark,
    surfaceElevated: AppColors.neoGroundDark,
    divider: AppColors.neoTrackDark,
    scanPulse: AppColors.neoAccentDim,
    tagListBg: AppColors.neoGroundDark,
    headerGradientStart: AppColors.neoAccentStart,
    headerGradientEnd: AppColors.neoAccentEnd,
  );

  @override
  AppColorScheme copyWith({
    Color? statusOk, Color? statusOkContainer, Color? statusOkOnContainer,
    Color? statusError, Color? statusErrorContainer, Color? statusErrorOnContainer,
    Color? statusWarning, Color? statusWarningContainer, Color? statusWarningOnContainer,
    Color? statusIdle, Color? statusIdleContainer, Color? statusIdleOnContainer,
    Color? statusActive, Color? statusActiveContainer, Color? statusActiveOnContainer,
    Color? surfaceCard, Color? surfaceElevated, Color? divider,
    Color? scanPulse, Color? tagListBg,
    Color? headerGradientStart, Color? headerGradientEnd,
  }) {
    return AppColorScheme(
      statusOk: statusOk ?? this.statusOk,
      statusOkContainer: statusOkContainer ?? this.statusOkContainer,
      statusOkOnContainer: statusOkOnContainer ?? this.statusOkOnContainer,
      statusError: statusError ?? this.statusError,
      statusErrorContainer: statusErrorContainer ?? this.statusErrorContainer,
      statusErrorOnContainer: statusErrorOnContainer ?? this.statusErrorOnContainer,
      statusWarning: statusWarning ?? this.statusWarning,
      statusWarningContainer: statusWarningContainer ?? this.statusWarningContainer,
      statusWarningOnContainer: statusWarningOnContainer ?? this.statusWarningOnContainer,
      statusIdle: statusIdle ?? this.statusIdle,
      statusIdleContainer: statusIdleContainer ?? this.statusIdleContainer,
      statusIdleOnContainer: statusIdleOnContainer ?? this.statusIdleOnContainer,
      statusActive: statusActive ?? this.statusActive,
      statusActiveContainer: statusActiveContainer ?? this.statusActiveContainer,
      statusActiveOnContainer: statusActiveOnContainer ?? this.statusActiveOnContainer,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      divider: divider ?? this.divider,
      scanPulse: scanPulse ?? this.scanPulse,
      tagListBg: tagListBg ?? this.tagListBg,
      headerGradientStart: headerGradientStart ?? this.headerGradientStart,
      headerGradientEnd: headerGradientEnd ?? this.headerGradientEnd,
    );
  }

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other is! AppColorScheme) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColorScheme(
      statusOk: l(statusOk, other.statusOk),
      statusOkContainer: l(statusOkContainer, other.statusOkContainer),
      statusOkOnContainer: l(statusOkOnContainer, other.statusOkOnContainer),
      statusError: l(statusError, other.statusError),
      statusErrorContainer: l(statusErrorContainer, other.statusErrorContainer),
      statusErrorOnContainer: l(statusErrorOnContainer, other.statusErrorOnContainer),
      statusWarning: l(statusWarning, other.statusWarning),
      statusWarningContainer: l(statusWarningContainer, other.statusWarningContainer),
      statusWarningOnContainer: l(statusWarningOnContainer, other.statusWarningOnContainer),
      statusIdle: l(statusIdle, other.statusIdle),
      statusIdleContainer: l(statusIdleContainer, other.statusIdleContainer),
      statusIdleOnContainer: l(statusIdleOnContainer, other.statusIdleOnContainer),
      statusActive: l(statusActive, other.statusActive),
      statusActiveContainer: l(statusActiveContainer, other.statusActiveContainer),
      statusActiveOnContainer: l(statusActiveOnContainer, other.statusActiveOnContainer),
      surfaceCard: l(surfaceCard, other.surfaceCard),
      surfaceElevated: l(surfaceElevated, other.surfaceElevated),
      divider: l(divider, other.divider),
      scanPulse: l(scanPulse, other.scanPulse),
      tagListBg: l(tagListBg, other.tagListBg),
      headerGradientStart: l(headerGradientStart, other.headerGradientStart),
      headerGradientEnd: l(headerGradientEnd, other.headerGradientEnd),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ThemeData factory
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  const AppTheme._();

  /// The design specifies Manrope (400–800). It is not bundled, so the app
  /// falls back to the platform sans by default. To adopt it: drop the TTFs in
  /// `assets/fonts/`, declare the family in `pubspec.yaml`, and set this to
  /// `'Manrope'` — nothing else in the theme needs to change.
  static const String? fontFamily = null;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark()  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final cs  = isDark ? AppColorScheme.dark : AppColorScheme.light;
    final neo = isDark ? NeoScheme.dark : NeoScheme.light;

    // Soft UI: one ground colour for the scaffold *and* every surface on it.
    final bg        = neo.ground;
    final surface   = neo.ground;
    final onSurface = neo.ink;
    final primary   = isDark ? AppColors.neoAccentDim : AppColors.neoAccentEnd;
    final onPrimary = neo.onAccent;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: isDark ? const Color(0xFF2E3742) : const Color(0xFFDFE7F1),
      onPrimaryContainer: isDark ? AppColors.neoAccentDim : AppColors.neoAccentEnd,
      secondary: neo.inkMuted,
      onSecondary: neo.onAccent,
      secondaryContainer: neo.ground,
      onSecondaryContainer: neo.inkMuted,
      error: AppColors.red500,
      onError: const Color(0xFFFFFFFF),
      errorContainer: isDark ? AppColors.red900 : AppColors.redLight,
      onErrorContainer: isDark ? AppColors.red500 : AppColors.red700,
      surface: surface,
      onSurface: onSurface,
      // Every container level collapses onto the ground — see NeoBox.
      surfaceContainerHighest: neo.ground,
      surfaceContainerHigh: neo.ground,
      surfaceContainer: neo.ground,
      surfaceContainerLow: neo.ground,
      surfaceContainerLowest: neo.ground,
      outline: neo.track,
      outlineVariant: neo.track,
      scrim: isDark ? const Color(0x99000000) : const Color(0x522B3340),
      inverseSurface: isDark ? neo.ink : AppColors.neoInk,
      onInverseSurface: neo.ground,
      inversePrimary: AppColors.neoAccentStart,
      shadow: neo.shadowDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      canvasColor: neo.ground,
      fontFamily: fontFamily,
      extensions: <ThemeExtension<dynamic>>[cs, neo],

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        centerTitle: false,
        toolbarHeight: AppSpacing.appBarH,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -0.2,
        ),
      ),

      // ── Cards ─────────────────────────────────────────────────────────────
      // Borderless: a Card is just the ground; NeoBox supplies the depth.
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surfaceCard,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusNeo),
        ),
      ),

      // ── Filled button (primary CTA) ───────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, AppSpacing.touchMin),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: neo.track,
          disabledForegroundColor: neo.inkGhost,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusNeoSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1,
          ),
          elevation: 0,
        ),
      ),

      // ── Outlined button (secondary) ───────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(56, AppSpacing.touchMin),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          foregroundColor: primary,
          disabledForegroundColor: neo.inkGhost,
          side: BorderSide(color: neo.track, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusNeoSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1,
          ),
        ),
      ),

      // ── Text button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, AppSpacing.touchMin),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1,
          ),
        ),
      ),

      // ── Icon button ───────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppSpacing.touchMin, AppSpacing.touchMin),
          padding: const EdgeInsets.all(AppSpacing.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),

      // ── Navigation bar ────────────────────────────────────────────────────
      // The mobile shell draws its own inset tab tray (see AppShell); this
      // theme only covers the tablet NavigationRail fallback.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        height: AppSpacing.navBarH,
        elevation: 0,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(size: 26, color: sel ? primary : neo.inkMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            color: sel ? primary : neo.inkMuted,
          );
        }),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: neo.ground,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: primary, size: 26),
        unselectedIconTheme: IconThemeData(color: neo.inkMuted, size: 24),
        selectedLabelTextStyle: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: primary,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: neo.inkMuted,
        ),
      ),

      // ── Input decoration ──────────────────────────────────────────────────
      // Fields are wells: ground fill, hairline edge, accent only on focus.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neo.ground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusNeoSm),
          borderSide: BorderSide(color: neo.track, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusNeoSm),
          borderSide: BorderSide(color: neo.track, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusNeoSm),
          borderSide: BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusNeoSm),
          borderSide: const BorderSide(color: AppColors.red500, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusNeoSm),
          borderSide: const BorderSide(color: AppColors.red500, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md,
        ),
        labelStyle: TextStyle(fontSize: 15, color: neo.inkMuted),
        hintStyle: TextStyle(fontSize: 15, color: neo.inkGhost),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: neo.ground,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs,
        ),
        labelStyle: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: neo.inkMuted,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        side: BorderSide.none,
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: neo.ground,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusNeoLg + 4),
          ),
        ),
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: neo.track,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: cs.divider,
        thickness: 1,
        space: 0,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: neo.ground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusNeoLg),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800, color: neo.ink,
        ),
        contentTextStyle: TextStyle(
          fontSize: 13.5, height: 1.5, fontWeight: FontWeight.w500,
          color: neo.inkMuted,
        ),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      // Reads as the design's floating toast: ground-coloured, not a dark slab.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: neo.ground,
        contentTextStyle: TextStyle(
          color: neo.ink,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        actionTextColor: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusNeo),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),

      // ── Progress indicator ────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: neo.track,
        circularTrackColor: neo.track,
      ),

      // ── List tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        minLeadingWidth: 0,
        horizontalTitleGap: AppSpacing.sm,
        iconColor: neo.inkMuted,
        textColor: neo.ink,
        subtitleTextStyle: TextStyle(
          fontSize: 12.5, fontWeight: FontWeight.w500, color: neo.inkMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusNeoSm),
        ),
      ),

      // ── Icon / switch ─────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: neo.inkMuted, size: 22),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? neo.onAccent : neo.ground,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? neo.accentEnd : neo.track,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Text theme ────────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 57, fontWeight: FontWeight.w800,
          letterSpacing: -2, color: onSurface,
        ),
        displayMedium: TextStyle(
          fontSize: 45, fontWeight: FontWeight.w800,
          letterSpacing: -1.5, color: onSurface,
        ),
        headlineLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w700,
          letterSpacing: -0.5, color: onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700,
          letterSpacing: -0.3, color: onSurface,
        ),
        headlineSmall: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700,
          letterSpacing: -0.2, color: onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          letterSpacing: -0.2, color: onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w600,
          letterSpacing: -0.1, color: onSurface,
        ),
        titleSmall: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 17, height: 1.5, color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 15, height: 1.5, color: onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 13, height: 1.45, fontWeight: FontWeight.w500,
          color: neo.inkMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500,
          letterSpacing: 0.1, color: onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500,
          letterSpacing: 0.1, color: onSurface,
        ),
        labelSmall: TextStyle(
          fontSize: 10.5, fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: neo.inkFaint,
        ),
      ),
    );
  }
}
