import 'package:flutter/material.dart';
import 'hotels_screen.dart'; // أو غيّرها لصفحتك التالية

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color _navy = Color(0xFF0E2C5B);
  static const Color _cream = Color(0xFFF6F1E6);

  @override
  void initState() {
    super.initState();

    // انتقال بعد 2 ثانية (عدّل الوجهة حسب رغبتك)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(HotelsScreen.routeName);
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

            // الشريط/الجزيرة الكريمية في الوسط
            CustomPaint(painter: _CreamBandPainter()),

            // اللوقو في المنتصف
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
        border: Border.all(color: _navy.withOpacity(0.55), width: 1.8),
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

    // تحكم: كم يمتد الكريمي للأعلى/للأسفل
    final top = size.height * 0.12; // قلّلها لو تبغى كحلي أكثر فوق
    final bottom = size.height * 0.88; // زوّدها لو تبغى كحلي أقل تحت

    // تحكم: عمق الموجة (كل ما زاد = موجة أقوى)
    final wave = size.height * 0.06;

    final path = Path()
      // ابدأ من يسار أعلى الجزيرة
      ..moveTo(0, top)
      // موجة علوية ناعمة (من اليسار لليمين)
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
      // نزول يمين (حافة مستقيمة)
      ..lineTo(size.width, bottom)
      // موجة سفلية ناعمة (من اليمين لليسار)
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
      // صعود يسار للإغلاق
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CreamBandPainter oldDelegate) => false;
}
