import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashSequence extends StatefulWidget {
  const SplashSequence({super.key});
  static const String routeName = '/';

  @override
  State<SplashSequence> createState() => _SplashSequenceState();
}

class _SplashSequenceState extends State<SplashSequence> {
  static const String _kHasSeenSplash = 'has_seen_splash_v1';
  final PageController _pc = PageController();
  Timer? _timer;
  int _index = 0;

  // عدد الصفحات عندك الآن: 3 (96, 94, 95)
  static const int _pageCount = 3;

  @override
  void initState() {
    super.initState();
    _initSplash();
  }

  Future<void> _initSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(_kHasSeenSplash) ?? false;
    if (hasSeen) {
      if (!mounted) return;
      context.go('/home');
      return;
    }
    _runSequence();
  }

  void _runSequence() {
    // الترتيب: 96 (2s) -> 94 (2s) -> 95 (0.8s) -> Login
    final durations = <Duration>[
      const Duration(seconds: 2), // 96
      const Duration(seconds: 2), // 94
      const Duration(milliseconds: 800), // 95 (الأخيرة أسرع)
    ];

    void scheduleNext() {
      // إذا وصلنا لآخر شاشة (index == 2) ننتظر مدتها ثم ننتقل
      if (_index >= _pageCount - 1) {
        _timer = Timer(durations[_index], () {
          if (!mounted) return;
          SharedPreferences.getInstance().then((prefs) {
            prefs.setBool(_kHasSeenSplash, true);
          });
          context.go('/home');
        });
        return;
      }

      // غير كذا: انتظر مدة الشاشة الحالية ثم انتقل للصفحة التالية
      _timer = Timer(durations[_index], () {
        if (!mounted) return;

        _index++;
        _pc.animateToPage(
          _index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );

        // بعد بدء الانتقال، جدولة المرحلة التالية
        scheduleNext();
      });
    }

    scheduleNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pc,
        physics: const NeverScrollableScrollPhysics(),
        children: const [_Splash96(), _Splash94(), _Splash95()],
      ),
    );
  }
}

// ==================== Shared constants ====================
const Color _pinkBg = Color(0xFFF5C9D4);
const Color _beige = Color(0xFFFEF9E6);
const Color _waveBorder = Color(0xFFE18299);

// ==================== Frame 96 (blue only) ====================
class _Splash96 extends StatelessWidget {
  const _Splash96();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: _pinkBg);
  }
}

// ==================== Frame 94 (Wave + bigger logo) ====================
class _Splash94 extends StatelessWidget {
  const _Splash94();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pinkBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _WavePainter(), child: SizedBox.expand()),
          Center(child: _LogoImage(size: 240)),
        ],
      ),
    );
  }
}

// ==================== Frame 95 (Cream background + biggest logo) ====================
class _Splash95 extends StatelessWidget {
  const _Splash95();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _beige,
      body: Center(child: _LogoImage(size: 320)),
    );
  }
}

// ==================== Wave painter ====================
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _beige
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final border = Paint()
      ..color = _waveBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..isAntiAlias = true;

    final topY = size.height * 0.22;
    final bottomY = size.height * 0.78;

    final path = Path()..moveTo(0, topY);

    path.cubicTo(
      size.width * 0.22,
      topY + size.height * 0.10,
      size.width * 0.48,
      topY - size.height * 0.09,
      size.width * 0.72,
      topY + size.height * 0.02,
    );
    path.cubicTo(
      size.width * 0.88,
      topY + size.height * 0.10,
      size.width,
      topY + size.height * 0.05,
      size.width,
      topY + size.height * 0.08,
    );

    path.lineTo(size.width, bottomY);

    path.cubicTo(
      size.width * 0.78,
      bottomY - size.height * 0.10,
      size.width * 0.55,
      bottomY + size.height * 0.09,
      size.width * 0.30,
      bottomY - size.height * 0.02,
    );
    path.cubicTo(
      size.width * 0.12,
      bottomY - size.height * 0.10,
      0,
      bottomY - size.height * 0.05,
      0,
      bottomY - size.height * 0.08,
    );

    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== Logo image only (no circle) ====================
class _LogoImage extends StatelessWidget {
  final double size;
  const _LogoImage({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset('assets/images/logo_pink.png', fit: BoxFit.contain),
    );
  }
}
