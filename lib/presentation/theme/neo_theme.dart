import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Depth of a neomorphic surface.
///
///   * [raised] — extruded from the ground: anything that can be pressed.
///   * [inset]  — pushed into the ground: containers, fields, tracks, and the
///     pressed/active state of a raised element.
///   * [accent] — the one steel-blue gradient, reserved for the primary action,
///     tag counters and the selected tab.
///   * [flat]   — ground colour with no depth at all.
enum NeoDepth { raised, inset, accent, flat }

/// Neomorphic tokens. There is exactly one ground colour per brightness and
/// every surface in the app is that colour — depth is carried by the shadow
/// pair alone, never by a border or a fill.
@immutable
class NeoScheme extends ThemeExtension<NeoScheme> {
  const NeoScheme({
    required this.ground,
    required this.shadowDark,
    required this.shadowLight,
    required this.accentStart,
    required this.accentEnd,
    required this.mutedStart,
    required this.mutedEnd,
    required this.onAccent,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.inkGhost,
    required this.track,
  });

  final Color ground;
  final Color shadowDark;
  final Color shadowLight;
  final Color accentStart;
  final Color accentEnd;
  final Color mutedStart;
  final Color mutedEnd;
  final Color onAccent;

  /// Primary body text.
  final Color ink;

  /// Secondary text / supporting copy.
  final Color inkMuted;

  /// Kicker labels (uppercase, letter-spaced section headers).
  final Color inkFaint;

  /// Timestamps and other tertiary metadata.
  final Color inkGhost;

  /// Hairlines and progress tracks.
  final Color track;

  static const light = NeoScheme(
    ground: AppColors.neoGround,
    shadowDark: AppColors.neoShadowDark,
    shadowLight: AppColors.neoShadowLight,
    accentStart: AppColors.neoAccentStart,
    accentEnd: AppColors.neoAccentEnd,
    mutedStart: AppColors.neoMutedStart,
    mutedEnd: AppColors.neoMutedEnd,
    onAccent: Color(0xFFFFFFFF),
    ink: AppColors.neoInk,
    inkMuted: AppColors.neoInkMuted,
    inkFaint: AppColors.neoInkFaint,
    inkGhost: AppColors.neoInkGhost,
    track: AppColors.neoTrack,
  );

  static const dark = NeoScheme(
    ground: AppColors.neoGroundDark,
    shadowDark: AppColors.neoShadowDarkDeep,
    shadowLight: AppColors.neoShadowLightDeep,
    accentStart: AppColors.neoAccentStart,
    accentEnd: AppColors.neoAccentEnd,
    mutedStart: AppColors.neoMutedEnd,
    mutedEnd: Color(0xFF5E6774),
    onAccent: Color(0xFFFFFFFF),
    ink: AppColors.neoInkDark,
    inkMuted: AppColors.neoInkMutedDark,
    inkFaint: AppColors.neoInkFaintDark,
    inkGhost: AppColors.neoInkFaintDark,
    track: AppColors.neoTrackDark,
  );

  /// The 145° steel-blue gradient used by every accent surface.
  LinearGradient get accentGradient => LinearGradient(
        colors: [accentStart, accentEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Neutral counterpart of [accentGradient] — scrap / destructive emphasis.
  LinearGradient get mutedGradient => LinearGradient(
        colors: [mutedStart, mutedEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Extruded shadow pair. [elevation] scales the offset/blur together so the
  /// light source stays consistent across the whole app.
  List<BoxShadow> raisedShadows({double elevation = 1}) => <BoxShadow>[
        BoxShadow(
          color: shadowDark,
          offset: Offset(6 * elevation, 6 * elevation),
          blurRadius: 14 * elevation,
        ),
        BoxShadow(
          color: shadowLight,
          offset: Offset(-6 * elevation, -6 * elevation),
          blurRadius: 14 * elevation,
        ),
      ];

  /// Drop shadow for accent surfaces — the white counter-light is softened so
  /// the gradient still reads as sitting above the ground.
  List<BoxShadow> accentShadows({double elevation = 1}) => <BoxShadow>[
        BoxShadow(
          color: shadowDark,
          offset: Offset(6 * elevation, 6 * elevation),
          blurRadius: 14 * elevation,
        ),
        BoxShadow(
          color: shadowLight,
          offset: Offset(-5 * elevation, -5 * elevation),
          blurRadius: 12 * elevation,
        ),
      ];

  @override
  NeoScheme copyWith({
    Color? ground,
    Color? shadowDark,
    Color? shadowLight,
    Color? accentStart,
    Color? accentEnd,
    Color? mutedStart,
    Color? mutedEnd,
    Color? onAccent,
    Color? ink,
    Color? inkMuted,
    Color? inkFaint,
    Color? inkGhost,
    Color? track,
  }) {
    return NeoScheme(
      ground: ground ?? this.ground,
      shadowDark: shadowDark ?? this.shadowDark,
      shadowLight: shadowLight ?? this.shadowLight,
      accentStart: accentStart ?? this.accentStart,
      accentEnd: accentEnd ?? this.accentEnd,
      mutedStart: mutedStart ?? this.mutedStart,
      mutedEnd: mutedEnd ?? this.mutedEnd,
      onAccent: onAccent ?? this.onAccent,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      inkGhost: inkGhost ?? this.inkGhost,
      track: track ?? this.track,
    );
  }

  @override
  NeoScheme lerp(NeoScheme? other, double t) {
    if (other is! NeoScheme) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return NeoScheme(
      ground: l(ground, other.ground),
      shadowDark: l(shadowDark, other.shadowDark),
      shadowLight: l(shadowLight, other.shadowLight),
      accentStart: l(accentStart, other.accentStart),
      accentEnd: l(accentEnd, other.accentEnd),
      mutedStart: l(mutedStart, other.mutedStart),
      mutedEnd: l(mutedEnd, other.mutedEnd),
      onAccent: l(onAccent, other.onAccent),
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      inkFaint: l(inkFaint, other.inkFaint),
      inkGhost: l(inkGhost, other.inkGhost),
      track: l(track, other.track),
    );
  }
}

extension NeoThemeAccess on BuildContext {
  /// Neomorphic tokens for the current theme.
  NeoScheme get neo => Theme.of(this).extension<NeoScheme>() ?? NeoScheme.light;
}
