import 'package:flutter/material.dart';

import '../theme/neo_theme.dart';

class ModulePage extends StatelessWidget {
  const ModulePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.actions = const <Widget>[],
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final neo   = context.neo;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 640 ? 16.0 : 24.0;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        18,
        horizontalPadding,
        28,
      ),
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: neo.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Kicker treatment: the subtitle is the screen's "code line".
                  Text(
                    subtitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      height: 1.4,
                      color: neo.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
            ...actions,
          ],
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }
}
