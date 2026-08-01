import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Thumb-zone action bar fixed at the bottom of RFID operation screens.
///
/// Layout rules:
///   - 1 action  → full-width primary
///   - 2 actions → secondary (1/3) + primary (2/3)
///   - 3 actions → tertiary (1/4) + secondary (1/4) + primary (1/2)
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.primary,
    this.secondary,
    this.tertiary,
    this.padding,
    this.color,
  });

  final Widget primary;
  final Widget? secondary;
  final Widget? tertiary;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      color: color ?? theme.colorScheme.surface,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + bottom,
      ),
      child: _layout(),
    );
  }

  Widget _layout() {
    const h = AppSpacing.touchMin;

    if (secondary == null && tertiary == null) {
      return SizedBox(height: h, child: primary);
    }

    if (tertiary == null) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(height: h, child: secondary!),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: SizedBox(height: h, child: primary),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: SizedBox(height: h, child: tertiary!)),
        const SizedBox(width: 8),
        Expanded(child: SizedBox(height: h, child: secondary!)),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: SizedBox(height: h, child: primary)),
      ],
    );
  }
}
