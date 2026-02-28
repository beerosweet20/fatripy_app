import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/firebase/auth_service.dart';
import '../../localization/app_localizations_ext.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _bg = Color(0xFFFFF7E5);
  static const Color _navy = Color(0xFF31487A);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(context.l10n.errorFillAllFields);
      return;
    }

    setState(() => _isLoading = true);

    debugPrint('Attempting to login with Email: $email');

    try {
      await _authService.signIn(email, password);
      if (!mounted) return;
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? context.l10n.errorLoginFailed);
    } catch (e) {
      _showError(context.l10n.errorGeneric);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CustomPaint(painter: _PinkWavePainter()),
                    ),
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          'assets/images/logo_pink.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Text(
                context.l10n.loginWelcome,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'serif',
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label(text: context.l10n.labelEmail),
                    const SizedBox(height: 10),
                    _Field(
                      obscure: false,
                      controller: _emailController,
                      textInputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 22),
                    _Label(text: context.l10n.labelPassword),
                    const SizedBox(height: 10),
                    _Field(obscure: true, controller: _passwordController),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SizedBox(
                  height: 62,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _navy.withValues(alpha: 0.5),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            context.l10n.actionLogin,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'serif',
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.loginNoAccount,
                    style: const TextStyle(fontSize: 22, fontFamily: 'serif'),
                  ),
                  GestureDetector(
                    onTap: () => context.go(RegisterScreen.routeName),
                    child: Text(
                      context.l10n.actionRegister,
                      style: const TextStyle(
                        fontSize: 22,
                        fontFamily: 'serif',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 26, fontFamily: 'serif'),
    );
  }
}

class _Field extends StatelessWidget {
  final bool obscure;
  final TextEditingController controller;
  final TextInputType textInputType;
  const _Field({
    required this.obscure,
    required this.controller,
    this.textInputType = TextInputType.text,
  });

  static const Color _pink = Color(0xFFE79AA8);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: textInputType,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(36),
          borderSide: const BorderSide(color: _pink, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(36),
          borderSide: const BorderSide(color: _pink, width: 2.4),
        ),
      ),
    );
  }
}

class _PinkWavePainter extends CustomPainter {
  static const Color _pinkFill = Color(0xFFF3C1CA);
  static const Color _pink = Color(0xFFE79AA8);

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = _pinkFill
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final stroke = Paint()
      ..color = _pink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..isAntiAlias = true;

    final h = size.height;
    final w = size.width;

    final path = Path()
      ..moveTo(-w * 0.28, h * 0.58)
      ..cubicTo(w * 0.08, h * 0.30, w * 0.35, h * 0.82, w * 0.56, h * 0.56)
      ..cubicTo(w * 0.72, h * 0.38, w * 0.92, h * 0.36, w * 1.28, h * 0.46)
      ..lineTo(w * 1.28, h * 0.74)
      ..cubicTo(w * 0.92, h * 0.64, w * 0.72, h * 0.70, w * 0.56, h * 0.80)
      ..cubicTo(w * 0.35, h * 0.98, w * 0.08, h * 0.60, -w * 0.28, h * 0.82)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
