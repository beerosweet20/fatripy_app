import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _PinkWavePainter()),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 22),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cream,
                  border: Border.all(color: AppTheme.pink, width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinkWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.pinkFill;

    final path = Path()
      ..moveTo(0, size.height * 0.45)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.25,
        size.width * 0.55,
        size.height * 0.65,
        size.width,
        size.height * 0.42,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
