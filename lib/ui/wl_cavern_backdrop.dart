import 'package:flutter/material.dart';

import '../core/wl_colors.dart';

class WLCavernBackdrop extends StatelessWidget {
  const WLCavernBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _WLCavernBackdropPainter(),
      child: SizedBox.expand(),
    );
  }
}

class _WLCavernBackdropPainter extends CustomPainter {
  const _WLCavernBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final center = Offset(size.width * 0.5, size.height * 0.42);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            WLColors.cavernGlow,
            WLColors.cavernMid,
            WLColors.cavernDeep,
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.72),
        ),
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0x00000000),
            Color(0xA0051018),
          ],
          stops: const [0.48, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.5, size.height * 0.48),
            radius: size.width * 0.74,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
