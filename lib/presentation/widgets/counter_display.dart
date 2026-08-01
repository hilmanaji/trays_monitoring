import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/neo_theme.dart';

enum CounterSize { xl, large, medium }

/// Big animated scan counter — the primary glanceable element on the Scan screen.
class CounterDisplay extends StatelessWidget {
  const CounterDisplay({
    super.key,
    required this.count,
    this.label,
    this.sublabel,
    this.color,
    this.size = CounterSize.large,
    this.isActive = false,
  });

  final int count;
  final String? label;
  final String? sublabel;
  final Color? color;
  final CounterSize size;
  final bool isActive;

  double get _fontSize => switch (size) {
        CounterSize.xl     => 80,
        CounterSize.large  => 56,
        CounterSize.medium => 40,
      };

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final effectiveColor = color ?? neo.ink;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: neo.inkFaint,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.25),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          child: Text(
            '$count',
            key: ValueKey<int>(count),
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -_fontSize * 0.04,
              height: 1.0,
              color: effectiveColor,
            ),
          ),
        ),
        if (sublabel != null) ...[
          const SizedBox(height: 4),
          Text(
            sublabel!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: neo.inkMuted,
            ),
          ),
        ],
        if (isActive) ...[
          const SizedBox(height: 12),
          _ScanningIndicator(color: effectiveColor),
        ],
      ],
    );
  }
}

class _ScanningIndicator extends StatefulWidget {
  const _ScanningIndicator({required this.color});
  final Color color;

  @override
  State<_ScanningIndicator> createState() => _ScanningIndicatorState();
}

class _ScanningIndicatorState extends State<_ScanningIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.4 + 0.6 * _anim.value),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'SCANNING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
              color: widget.color.withValues(alpha: 0.6 + 0.4 * _anim.value),
            ),
          ),
        ],
      ),
    );
  }
}

/// Flash overlay triggered once per new scan event.
class ScanFlashOverlay extends StatefulWidget {
  const ScanFlashOverlay({super.key, required this.child, this.triggerKey});

  final Widget child;

  /// Changing this value triggers a flash.
  final int? triggerKey;

  @override
  State<ScanFlashOverlay> createState() => _ScanFlashOverlayState();
}

class _ScanFlashOverlayState extends State<ScanFlashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(ScanFlashOverlay old) {
    super.didUpdateWidget(old);
    if (old.triggerKey != widget.triggerKey && widget.triggerKey != null) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashColor = Theme.of(context).extension<AppColorScheme>()?.scanPulse ??
        Colors.green;
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _anim,
          builder: (context, _) => Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: flashColor.withValues(
                  alpha: (1.0 - _anim.value) * 0.18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
