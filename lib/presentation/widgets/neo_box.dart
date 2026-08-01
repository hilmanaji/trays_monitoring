import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/neo_theme.dart';

/// The single surface primitive of the app.
///
/// Every card, field, tab, chip and button is a [NeoBox]; nothing else draws a
/// background. Depth comes from the shadow pair alone — see [NeoDepth].
///
/// When [onTap] is provided the box presses from [NeoDepth.raised] into
/// [NeoDepth.inset], which is the whole tactile idea of the soft-UI language.
class NeoBox extends StatefulWidget {
  const NeoBox({
    super.key,
    this.child,
    this.depth = NeoDepth.raised,
    this.radius = AppSpacing.radiusNeo,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.elevation = 1,
    this.gradient,
    this.alignment,
    this.pressedDepth,
    this.enabled = true,
  });

  /// Container that never presses (inset by convention).
  const NeoBox.inset({
    super.key,
    this.child,
    this.radius = AppSpacing.radiusNeo,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.elevation = 1,
    this.alignment,
    this.enabled = true,
  })  : depth = NeoDepth.inset,
        gradient = null,
        pressedDepth = null;

  /// Primary action — steel-blue gradient on a raised drop shadow.
  const NeoBox.accent({
    super.key,
    this.child,
    this.radius = AppSpacing.radiusNeo,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.elevation = 1,
    this.gradient,
    this.alignment,
    this.enabled = true,
  })  : depth = NeoDepth.accent,
        pressedDepth = null;

  final Widget? child;
  final NeoDepth depth;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Scales the shadow offset/blur; 1 is the standard card depth.
  final double elevation;

  /// Overrides the accent gradient (e.g. the muted ramp used by Scrap).
  final Gradient? gradient;
  final AlignmentGeometry? alignment;

  /// Depth shown while pressed. Defaults to [NeoDepth.inset] for raised boxes
  /// and to no change for accent boxes (they dim instead).
  final NeoDepth? pressedDepth;

  final bool enabled;

  @override
  State<NeoBox> createState() => _NeoBoxState();
}

class _NeoBoxState extends State<NeoBox> {
  bool _pressed = false;

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  NeoDepth get _effectiveDepth {
    if (!_pressed || !_interactive) return widget.depth;
    if (widget.pressedDepth != null) return widget.pressedDepth!;
    return switch (widget.depth) {
      NeoDepth.raised => NeoDepth.inset,
      NeoDepth.flat => NeoDepth.inset,
      NeoDepth.inset => NeoDepth.inset,
      NeoDepth.accent => NeoDepth.accent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final depth = _effectiveDepth;
    final radius = BorderRadius.circular(widget.radius);
    final dim = widget.depth == NeoDepth.accent && _pressed && _interactive;

    Widget surface = AnimatedContainer(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      padding: widget.padding,
      decoration: BoxDecoration(
        // Inset boxes stay transparent here: their ground is laid down by the
        // painter below, so the inner shadows land *above* the fill.
        color: depth == NeoDepth.accent || depth == NeoDepth.inset
            ? null
            : neo.ground,
        gradient: depth == NeoDepth.accent
            ? (widget.gradient ?? neo.accentGradient)
            : null,
        borderRadius: radius,
        boxShadow: switch (depth) {
          NeoDepth.raised => neo.raisedShadows(elevation: widget.elevation),
          NeoDepth.accent => neo.accentShadows(elevation: widget.elevation),
          NeoDepth.inset || NeoDepth.flat => const <BoxShadow>[],
        },
      ),
      foregroundDecoration: dim
          ? BoxDecoration(
              color: Colors.black.withValues(alpha: 0.10),
              borderRadius: radius,
            )
          : null,
      child: widget.child,
    );

    if (depth == NeoDepth.inset) {
      surface = CustomPaint(
        painter: _InsetShadowPainter(
          radius: widget.radius,
          ground: neo.ground,
          dark: neo.shadowDark,
          light: neo.shadowLight,
          elevation: widget.elevation,
        ),
        child: surface,
      );
    }

    if (_interactive) {
      surface = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: surface,
      );
    }

    if (widget.margin != null) {
      surface = Padding(padding: widget.margin!, child: surface);
    }
    return surface;
  }
}

/// Flutter has no inner box-shadow, so inset depth is painted: the ground is
/// clipped to the rounded rect and two blurred "holes" are drawn just outside
/// it, one offset down-right (dark) and one up-left (white).
class _InsetShadowPainter extends CustomPainter {
  const _InsetShadowPainter({
    required this.radius,
    required this.ground,
    required this.dark,
    required this.light,
    required this.elevation,
  });

  final double radius;
  final Color ground;
  final Color dark;
  final Color light;
  final double elevation;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final offset = 5.0 * elevation;
    final sigma = 5.5 * elevation;

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRRect(rrect, Paint()..color = ground);

    void inner(Color color, Offset shift) {
      final hole = Path()..addRRect(rrect.shift(shift));
      final outer = Path()..addRect(rect.inflate(offset + sigma * 3));
      canvas.drawPath(
        Path.combine(PathOperation.difference, outer, hole),
        Paint()
          ..color = color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
      );
    }

    inner(dark, Offset(offset, offset));
    inner(light, Offset(-offset, -offset));

    canvas.restore();
  }

  @override
  bool shouldRepaint(_InsetShadowPainter old) =>
      old.radius != radius ||
      old.ground != ground ||
      old.dark != dark ||
      old.light != light ||
      old.elevation != elevation;
}

// ─────────────────────────────────────────────────────────────────────────────
// Composed pieces built on NeoBox
// ─────────────────────────────────────────────────────────────────────────────

/// Uppercase letter-spaced section label — the recurring rhythm marker.
class NeoKicker extends StatelessWidget {
  const NeoKicker(this.text, {super.key, this.trailing, this.onTrailingTap});

  final String text;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final label = Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: neo.inkFaint,
      ),
    );

    if (trailing == null) return label;

    return Row(
      children: [
        label,
        const Spacer(),
        GestureDetector(
          onTap: onTrailingTap,
          behavior: HitTestBehavior.opaque,
          child: Text(
            trailing!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: neo.accentEnd,
            ),
          ),
        ),
      ],
    );
  }
}

/// Selectable pill — accent when active, raised when not (filters, reasons).
class NeoChoiceChip extends StatelessWidget {
  const NeoChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.minHeight = 42,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return NeoBox(
      depth: selected ? NeoDepth.accent : NeoDepth.raised,
      elevation: 0.7,
      radius: AppSpacing.radiusLg,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      height: minHeight,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: selected ? neo.onAccent : neo.inkMuted,
        ),
      ),
    );
  }
}

/// Small inset square holding a glyph or a 4–5 letter code.
class NeoIconBadge extends StatelessWidget {
  const NeoIconBadge({
    super.key,
    this.icon,
    this.text,
    this.size = 38,
    this.radius = 13,
    this.accent = false,
  }) : assert(icon != null || text != null, 'Provide an icon or a text code');

  final IconData? icon;
  final String? text;
  final double size;
  final double radius;

  /// Fill with the steel-blue gradient instead of insetting into the ground.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return NeoBox(
      depth: accent ? NeoDepth.accent : NeoDepth.inset,
      radius: radius,
      width: size,
      height: size,
      elevation: 0.6,
      alignment: Alignment.center,
      child: icon != null
          ? Icon(
              icon,
              size: size * 0.5,
              color: accent ? neo.onAccent : neo.accentEnd,
            )
          : Text(
              text!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: accent ? neo.onAccent : neo.accentEnd,
              ),
            ),
    );
  }
}

/// Accent counter bubble — used for the live tag count.
class NeoCountBadge extends StatelessWidget {
  const NeoCountBadge({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return NeoBox.accent(
      radius: 12,
      elevation: 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: neo.onAccent,
        ),
      ),
    );
  }
}

/// Inset track with an accent fill — opname progress, signal levels.
class NeoProgressBar extends StatelessWidget {
  const NeoProgressBar({
    super.key,
    required this.value,
    this.height = 14,
    this.gradient,
  });

  /// 0.0 → 1.0.
  final double value;
  final double height;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return NeoBox.inset(
      height: height,
      radius: height / 2,
      elevation: 0.55,
      padding: const EdgeInsets.all(3),
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            width: constraints.maxWidth * value.clamp(0.0, 1.0),
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(colors: [neo.accentStart, neo.accentEnd]),
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width primary CTA. Falls back to a dead inset slab when disabled, which
/// is how the design communicates "nothing to commit yet".
class NeoButton extends StatelessWidget {
  const NeoButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.gradient,
    this.height = AppSpacing.touchMin,
    this.radius = AppSpacing.radiusNeo,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final enabled = onPressed != null;

    return NeoBox(
      depth: enabled ? NeoDepth.accent : NeoDepth.inset,
      gradient: gradient,
      radius: radius,
      height: height,
      onTap: onPressed,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: enabled ? neo.onAccent : neo.inkGhost),
            const SizedBox(width: 9),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: enabled ? neo.onAccent : neo.inkGhost,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Secondary action — raised, ink-coloured, presses to inset.
class NeoSecondaryButton extends StatelessWidget {
  const NeoSecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.height = AppSpacing.touchMin,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final enabled = onPressed != null;
    final fg = enabled ? (color ?? neo.accentEnd) : neo.inkGhost;

    return NeoBox(
      depth: enabled ? NeoDepth.raised : NeoDepth.inset,
      elevation: 0.8,
      radius: AppSpacing.radiusNeo,
      height: height,
      onTap: onPressed,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 19, color: fg),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The hardware-trigger twin: latches inset while scanning is live.
class NeoTriggerButton extends StatelessWidget {
  const NeoTriggerButton({
    super.key,
    required this.scanning,
    required this.onTap,
    this.width = 96,
    this.height = AppSpacing.touchMin,
  });

  final bool scanning;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return NeoBox(
      depth: scanning ? NeoDepth.inset : NeoDepth.raised,
      radius: AppSpacing.radiusNeo,
      width: width,
      height: height,
      onTap: onTap,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            scanning ? 'Stop' : 'Scan',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: neo.accentEnd,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'TRIGGER',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: neo.inkGhost,
            ),
          ),
        ],
      ),
    );
  }
}

/// Field-style inset block with a kicker and a value — the login/detail pattern.
class NeoField extends StatelessWidget {
  const NeoField({
    super.key,
    required this.label,
    required this.value,
    this.valueStyle,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return NeoBox(
      depth: NeoDepth.inset,
      radius: AppSpacing.radiusLg + 2,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: neo.inkFaint,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle ??
                      TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: neo.ink,
                      ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Pulsing accent disc used by idle scan states (`neoPulse` in the source).
class NeoPulse extends StatefulWidget {
  const NeoPulse({super.key, this.size = 68, this.child});

  final double size;
  final Widget? child;

  @override
  State<NeoPulse> createState() => _NeoPulseState();
}

class _NeoPulseState extends State<NeoPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_ctrl.value);
        return Container(
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: neo.accentGradient,
            boxShadow: [
              BoxShadow(
                color: neo.accentEnd.withValues(alpha: 0.30 * (1 - t)),
                blurRadius: 0,
                spreadRadius: 22 * t,
              ),
            ],
          ),
          child: widget.child ??
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: neo.onAccent.withValues(alpha: 0.85),
                    width: 2,
                  ),
                ),
              ),
        );
      },
    );
  }
}
