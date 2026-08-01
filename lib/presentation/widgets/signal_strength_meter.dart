import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/neo_theme.dart';
import 'neo_box.dart';

/// Horizontal bar RSSI meter — used in list tiles and the Find screen header.
class SignalStrengthMeter extends StatelessWidget {
  const SignalStrengthMeter({
    super.key,
    required this.rssi,
    this.showLabel = true,
    this.height = 14.0,
  });

  /// Normalised signal strength: 0.0 (no signal) → 1.0 (maximum).
  final double rssi;
  final bool showLabel;
  final double height;

  Color get _color {
    if (rssi >= 0.75) return AppColors.green500;
    if (rssi >= 0.50) return AppColors.amber500;
    if (rssi >= 0.25) return AppColors.amber700;
    return AppColors.red500;
  }

  String get _label {
    if (rssi >= 0.75) return 'STRONG';
    if (rssi >= 0.50) return 'GOOD';
    if (rssi >= 0.25) return 'WEAK';
    return 'NO SIGNAL';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              _label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: _color,
              ),
            ),
          ),
        // Inset track so the level reads as liquid filling a groove.
        NeoBox.inset(
          height: height,
          radius: height / 2,
          elevation: 0.5,
          padding: const EdgeInsets.all(3),
          child: CustomPaint(
            painter: _BarPainter(rssi: rssi, color: _color),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({required this.rssi, required this.color});
  final double rssi;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final fgPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.6), color],
      ).createShader(Rect.fromLTWH(0, 0, size.width * rssi, size.height));

    // The track is drawn by the surrounding inset NeoBox; only the fill here.
    if (rssi > 0.01) {
      final fg = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * rssi.clamp(0.0, 1.0), size.height),
        radius,
      );
      canvas.drawRRect(fg, fgPaint);
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.rssi != rssi || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Geiger-style full-screen circular meter (Find mode)
// ─────────────────────────────────────────────────────────────────────────────

class GeigerMeter extends StatefulWidget {
  const GeigerMeter({
    super.key,
    required this.rssi,
    this.targetEpc,
    this.isActive = false,
  });

  /// Normalised 0.0 → 1.0.
  final double rssi;
  final String? targetEpc;
  final bool isActive;

  @override
  State<GeigerMeter> createState() => _GeigerMeterState();
}

class _GeigerMeterState extends State<GeigerMeter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _pulseDuration())
      ..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(GeigerMeter old) {
    super.didUpdateWidget(old);
    final next = _pulseDuration();
    if (next != _ctrl.duration) {
      _ctrl.duration = next;
    }
  }

  Duration _pulseDuration() {
    // Faster pulse = closer target. 150ms at full signal, 900ms at none.
    final ms = (900 - widget.rssi * 750).toInt().clamp(150, 900);
    return Duration(milliseconds: ms);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _color {
    if (widget.rssi >= 0.75) return AppColors.green500;
    if (widget.rssi >= 0.50) return AppColors.amber500;
    if (widget.rssi >= 0.25) return AppColors.amber700;
    return AppColors.red500;
  }

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        return SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring — proximity is read from its cadence.
              if (widget.rssi > 0.05)
                Container(
                  width: 260 + t * 40,
                  height: 260 + t * 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _color.withValues(alpha: (1.0 - t) * 0.25),
                      width: 2,
                    ),
                  ),
                ),
              // The dial is a well pressed into the ground…
              const NeoBox.inset(width: 250, height: 250, radius: 125),
              // …holding a raised disc that carries the reading.
              NeoBox(
                width: 200,
                height: 200,
                radius: 100,
                elevation: 0.9,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isActive
                          ? Icons.sensors_rounded
                          : Icons.sensors_off_rounded,
                      size: 40,
                      color: _color.withValues(alpha: 0.7 + t * 0.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.rssi > 0.01
                          ? '${(widget.rssi * 100).round()}%'
                          : '—',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2,
                        height: 1.0,
                        color: neo.ink,
                      ),
                    ),
                    if (widget.targetEpc != null) ...[
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 150,
                        child: Text(
                          widget.targetEpc!,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            color: neo.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
