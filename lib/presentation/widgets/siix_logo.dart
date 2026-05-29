import 'package:flutter/material.dart';

class SiixLogo extends StatelessWidget {
  const SiixLogo({
    super.key,
    this.width = 144,
    this.showTagline = true,
    this.textColor = const Color(0xFF081120),
    this.taglineColor = const Color(0xFF6B7A90),
  });

  final double width;
  final bool showTagline;
  final Color textColor;
  final Color taglineColor;

  @override
  Widget build(BuildContext context) {
    final dotSize = width * 0.078;
    final wordHeight = width * 0.42;
    final textSize = width * 0.29;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: wordHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'SIIX',
                    style: TextStyle(
                      color: textColor,
                      fontSize: textSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: width * 0.01,
                      height: 1,
                    ),
                  ),
                ),
                Positioned(
                  left: width * 0.305,
                  top: width * 0.03,
                  child: _LogoDot(
                    size: dotSize,
                    color: const Color(0xFF2346F2),
                  ),
                ),
                Positioned(
                  left: width * 0.477,
                  bottom: width * 0.018,
                  child: _LogoDot(
                    size: dotSize,
                    color: const Color(0xFFFF7A1A),
                  ),
                ),
              ],
            ),
          ),
          if (showTagline) ...[
            SizedBox(height: width * 0.015),
            Text(
              'W e   c a r e .',
              style: TextStyle(
                color: taglineColor,
                fontSize: width * 0.07,
                fontWeight: FontWeight.w600,
                letterSpacing: width * 0.01,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogoDot extends StatelessWidget {
  const _LogoDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: size * 0.9,
            offset: Offset(0, size * 0.25),
          ),
        ],
      ),
    );
  }
}
