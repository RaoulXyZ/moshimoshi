import 'package:flutter/material.dart';

import '../../utility/mindblooming_color_scheme.dart';

class CustomLinearProgressIndicator extends StatelessWidget {
  const CustomLinearProgressIndicator({
    super.key,
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MindBloomingColorScheme.textColorDark1shadow,
                    width: 0.5,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  color: MindBloomingColorScheme.primary2shadow,
                ),
              ),
              Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [
                    MindBloomingColorScheme.secondary,
                    MindBloomingColorScheme.secondary3shadow,
                    MindBloomingColorScheme.tertiary2shadow,
                    MindBloomingColorScheme.tertiary,
                  ]),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: CustomPaint(
                    painter: InvertedRoundedRectanglePainter(
                      radius: progress == 155 ? 0 : 10,
                      color: MindBloomingColorScheme.primary2shadow,
                    ),
                    child: SizedBox(
                      height: 10,
                      width: progress,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InvertedRoundedRectanglePainter extends CustomPainter {
  InvertedRoundedRectanglePainter({
    required this.radius,
    required this.color,
  });

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..quadraticBezierTo(radius / 2, size.height / 2, 0, 0)
        ..lineTo(0, 0),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(InvertedRoundedRectanglePainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}
