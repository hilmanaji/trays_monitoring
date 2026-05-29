import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
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
                  Text(title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(subtitle, style: theme.textTheme.bodyLarge),
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
