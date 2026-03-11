import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color _pink = Color(0xFFE18299);

  static const double _baseWidth = 412;

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

    try {
      final credential = await _authService.signIn(email, password);
      final isAdmin = await _authService.isAdmin(user: credential.user);
      if (!mounted) return;
      context.go(isAdmin ? '/admin' : '/home');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? context.l10n.errorLoginFailed);
    } catch (_) {
      _showError(context.l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: _navy));
  }

  Future<void> _showResetPasswordDialog() async {
    final l10n = context.l10n;
    final controller = TextEditingController(
      text: _emailController.text.trim(),
    );
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetPasswordTitle),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.labelEmail),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.resetPasswordSend),
          ),
        ],
      ),
    );
    controller.dispose();

    if (email == null || email.trim().isEmpty) {
      return;
    }

    try {
      await _authService.sendPasswordReset(email.trim());
      _showInfo(l10n.resetPasswordSuccess);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? l10n.resetPasswordFailure);
    } catch (_) {
      _showError(l10n.resetPasswordFailure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _baseWidth;
            double s(double value) => value * scale;
            final yNudge = s(16);

            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  Positioned.fill(child: Container(color: _bg)),
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(0, yNudge),
                      child: Stack(
                        children: [
                          Positioned(
                            left: s(-254),
                            top: s(27),
                            width: s(786),
                            height: s(289),
                            child: CustomPaint(painter: _AuthRibbonPainter()),
                          ),
                          Positioned(
                            left: s(100),
                            top: s(74),
                            width: s(207),
                            height: s(207),
                            child: Image.asset(
                              'assets/images/logo_pink.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: s(349),
                            width: constraints.maxWidth,
                            child: Text(
                              l10n.loginWelcome,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inriaSerif(
                                fontSize: s(40),
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Positioned(
                            left: s(22),
                            top: s(428),
                            child: Text(
                              '${l10n.labelEmail}:',
                              style: GoogleFonts.inriaSerif(
                                fontSize: s(18),
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Positioned(
                            left: s(22),
                            top: s(458),
                            width: s(367),
                            height: s(34),
                            child: _AuthField(
                              controller: _emailController,
                              obscureText: false,
                              borderColor: _pink,
                              scale: scale,
                            ),
                          ),
                          Positioned(
                            left: s(22),
                            top: s(505),
                            child: Text(
                              '${l10n.labelPassword}:',
                              style: GoogleFonts.inriaSerif(
                                fontSize: s(18),
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Positioned(
                            left: s(22),
                            top: s(534),
                            width: s(367),
                            height: s(34),
                            child: _AuthField(
                              controller: _passwordController,
                              obscureText: true,
                              borderColor: _pink,
                              scale: scale,
                            ),
                          ),
                          Positioned(
                            right: s(24),
                            top: s(575),
                            child: GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : _showResetPasswordDialog,
                              child: Text(
                                l10n.forgotPasswordCta,
                                style: GoogleFonts.inriaSerif(
                                  fontSize: s(14),
                                  fontWeight: FontWeight.w600,
                                  color: _navy,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: s(23),
                            top: s(610),
                            width: s(365),
                            height: s(45),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(s(50)),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      l10n.actionLogin,
                                      style: GoogleFonts.inriaSerif(
                                        fontSize: s(20),
                                        fontWeight: FontWeight.w700,
                                        height: 1.0,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: s(678),
                            width: constraints.maxWidth,
                            child: GestureDetector(
                              onTap: () => context.go(RegisterScreen.routeName),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.inriaSerif(
                                    fontSize: s(18),
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: l10n.loginNoAccount),
                                    TextSpan(
                                      text: l10n.actionRegister,
                                      style: TextStyle(
                                        color: _navy,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final Color borderColor;
  final double scale;

  const _AuthField({
    required this.controller,
    required this.obscureText,
    required this.borderColor,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.inriaSerif(fontSize: 15 * scale, color: Colors.black),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 6 * scale,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50 * scale),
          borderSide: BorderSide(color: borderColor, width: 1.5 * scale),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50 * scale),
          borderSide: BorderSide(color: borderColor, width: 1.5 * scale),
        ),
      ),
    );
  }
}

class _AuthRibbonPainter extends CustomPainter {
  static const double _baseW = 673.24;
  static const double _baseH = 240.906;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(501.078, 8.97672)
      ..cubicTo(522.768, 1.07497, 546.237, -0.60305, 568.83, 4.13101)
      ..lineTo(606.062, 11.9318)
      ..cubicTo(648.248, 20.7711, 676.55, 60.5591, 671.06, 103.311)
      ..cubicTo(665.163, 149.226, 622.693, 181.335, 576.909, 174.492)
      ..lineTo(465.084, 157.779)
      ..cubicTo(421.364, 151.245, 376.717, 159.653, 338.369, 181.644)
      ..lineTo(288.616, 210.177)
      ..cubicTo(239.08, 238.584, 180.458, 246.672, 125.08, 232.74)
      ..lineTo(70.4486, 218.997)
      ..cubicTo(46.0776, 212.866, 25.3388, 196.905, 13.1722, 174.916)
      ..cubicTo(-26.977, 102.354, 43.1931, 18.3863, 121.733, 45.0099)
      ..lineTo(222.117, 79.0382)
      ..cubicTo(251.167, 88.886, 282.708, 88.5313, 311.53, 78.0314)
      ..lineTo(501.078, 8.97672)
      ..close();

    final scaleX = size.width / _baseW;
    final scaleY = size.height / _baseH;
    final scaled = path.transform(
      Matrix4.diagonal3Values(scaleX, scaleY, 1).storage,
    );

    final fill = Paint()
      ..color = const Color(0xFFF5C9D4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final stroke = Paint()
      ..color = const Color(0xFFE18299)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * ((scaleX + scaleY) / 2)
      ..isAntiAlias = true;

    canvas.drawPath(scaled, fill);
    canvas.drawPath(scaled, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
