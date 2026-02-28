import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color _navy = Color(0xFF0E2C5B);

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: _navy),
            CustomPaint(painter: _CreamBandPainter()),
            const Center(child: _LogoCircle()),
          ],
        ),
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle();

  static const Color _navy = Color(0xFF0E2C5B);
  static const Color _cream = Color(0xFFF6F1E6);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      height: 175,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _cream,
        border: Border.all(color: _navy.withValues(alpha: 0.55), width: 1.8),
      ),
      padding: const EdgeInsets.all(24),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}

class _CreamBandPainter extends CustomPainter {
  static const Color _cream = Color(0xFFF6F1E6);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _cream
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final top = size.height * 0.12;
    final bottom = size.height * 0.88;
    final wave = size.height * 0.06;

    final path = Path()
      ..moveTo(0, top)
      ..cubicTo(
        size.width * 0.18,
        top + wave,
        size.width * 0.45,
        top - wave,
        size.width * 0.65,
        top + wave * 0.15,
      )
      ..cubicTo(
        size.width * 0.80,
        top + wave * 0.55,
        size.width * 0.92,
        top + wave * 0.20,
        size.width,
        top + wave * 0.35,
      )
      ..lineTo(size.width, bottom)
      ..cubicTo(
        size.width * 0.82,
        bottom - wave,
        size.width * 0.55,
        bottom + wave,
        size.width * 0.35,
        bottom - wave * 0.10,
      )
      ..cubicTo(
        size.width * 0.20,
        bottom - wave * 0.55,
        size.width * 0.08,
        bottom - wave * 0.20,
        0,
        bottom - wave * 0.35,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CreamBandPainter oldDelegate) => false;
}
