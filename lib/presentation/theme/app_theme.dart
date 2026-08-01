import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

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
    statusIdle: AppColors.slate600,
    statusIdleContainer: AppColors.slateLight,
    statusIdleOnContainer: AppColors.slate600,
    statusActive: AppColors.blue500,
    statusActiveContainer: AppColors.blueLight,
    statusActiveOnContainer: AppColors.blue500,
    surfaceCard: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF5F8FF),
    divider: AppColors.neutral100,
    scanPulse: AppColors.green500,
    tagListBg: Color(0xFFF7FAFF),
    headerGradientStart: Color(0xFF0E3E86),
    headerGradientEnd: Color(0xFF1E7BFF),
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
    statusIdle: AppColors.slate400,
    statusIdleContainer: AppColors.slateDark,
    statusIdleOnContainer: AppColors.slate400,
    statusActive: AppColors.blue400,
    statusActiveContainer: AppColors.blue900,
    statusActiveOnContainer: AppColors.blue400,
    surfaceCard: AppColors.neutral800,
    surfaceElevated: AppColors.neutral700,
    divider: AppColors.neutral600,
    scanPulse: AppColors.green500,
    tagListBg: AppColors.neutral850,
    headerGradientStart: Color(0xFF0A2447),
    headerGradientEnd: Color(0xFF1053A8),
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

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark()  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final cs = isDark ? AppColorScheme.dark : AppColorScheme.light;

    final bg       = isDark ? AppColors.neutral900 : AppColors.neutral50;
    final surface  = isDark ? AppColors.neutral800 : const Color(0xFFFFFFFF);
    final onSurface = isDark ? AppColors.neutral100 : AppColors.neutral900;
    final primary  = isDark ? AppColors.primary400  : AppColors.primary500;
    final onPrimary = isDark ? AppColors.neutral900 : const Color(0xFFFFFFFF);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: isDark ? AppColors.primary700 : AppColors.blueLight,
      onPrimaryContainer: isDark ? AppColors.primary400 : AppColors.primary600,
      secondary: isDark ? AppColors.neutral300 : AppColors.neutral500,
      onSecondary: isDark ? AppColors.neutral900 : const Color(0xFFFFFFFF),
      secondaryContainer: isDark ? AppColors.neutral700 : AppColors.neutral100,
      onSecondaryContainer: isDark ? AppColors.neutral200 : AppColors.neutral600,
      error: AppColors.red500,
      onError: const Color(0xFFFFFFFF),
      errorContainer: isDark ? AppColors.red900 : AppColors.redLight,
      onErrorContainer: isDark ? AppColors.red500 : AppColors.red700,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: isDark ? AppColors.neutral700 : AppColors.neutral100,
      surfaceContainerHigh: isDark ? AppColors.neutral750 : const Color(0xFFE8EFF8),
      surfaceContainer: isDark ? AppColors.neutral800 : const Color(0xFFFFFFFF),
      surfaceContainerLow: isDark ? AppColors.neutral800 : const Color(0xFFF5F8FF),
      surfaceContainerLowest: isDark ? AppColors.neutral900 : AppColors.neutral50,
      outline: isDark ? AppColors.neutral600 : AppColors.neutral100,
      outlineVariant: isDark ? AppColors.neutral700 : const Color(0xFFE0E9F5),
      scrim: const Color(0x99000000),
      inverseSurface: isDark ? const Color(0xFFFFFFFF) : AppColors.neutral900,
      onInverseSurface: isDark ? AppColors.neutral900 : AppColors.neutral50,
      inversePrimary: isDark ? AppColors.primary600 : AppColors.primary400,
      shadow: isDark
          ? const Color(0x66000000)
          : const Color(0x14000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      extensions: <ThemeExtension<dynamic>>[cs],

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
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surfaceCard,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      // ── Filled button (primary CTA) ───────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, AppSpacing.touchMin),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: colorScheme.outline,
          disabledForegroundColor: onSurface.withValues(alpha: 0.38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
          disabledForegroundColor: onSurface.withValues(alpha: 0.38),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.neutral800 : const Color(0xFFFFFFFF),
        height: AppSpacing.navBarH,
        elevation: 0,
        indicatorColor: isDark
            ? AppColors.primary700.withValues(alpha: 0.45)
            : AppColors.blueLight,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 26,
            color: sel
                ? primary
                : onSurface.withValues(alpha: 0.5),
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            color: sel ? primary : onSurface.withValues(alpha: 0.5),
          );
        }),
      ),

      // ── Input decoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.neutral750 : const Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.red500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.red500, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md,
        ),
        labelStyle: TextStyle(fontSize: 15, color: onSurface.withValues(alpha: 0.6)),
        hintStyle: TextStyle(fontSize: 15, color: onSurface.withValues(alpha: 0.4)),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs,
        ),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        side: BorderSide.none,
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        elevation: 4,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: cs.divider,
        thickness: 1,
        space: 0,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.neutral700 : AppColors.neutral800,
        contentTextStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ── Progress indicator ────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: isDark ? AppColors.neutral700 : AppColors.neutral100,
      ),

      // ── List tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        minLeadingWidth: 0,
        horizontalTitleGap: AppSpacing.sm,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
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
          fontSize: 13, height: 1.5,
          color: onSurface.withValues(alpha: 0.6),
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
          fontSize: 11, fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
