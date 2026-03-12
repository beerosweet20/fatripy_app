import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/firebase/auth_service.dart';
import '../../localization/app_localizations_ext.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color _bg = Color(0xFFFFF7E5);
  static const Color _navy = Color(0xFF31487A);
  static const Color _pink = Color(0xFFE18299);

  static const double _baseWidth = 412;
  static const double _baseContentHeight = 930;

  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final l10n = context.l10n;
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError(l10n.errorFillAllFields);
      return;
    }

    if (username.contains(' ')) {
      _showError(l10n.errorUsernameNoSpaces);
      return;
    }

    if (password.length < 6) {
      _showError(l10n.errorPasswordTooShort);
      return;
    }

    if (password != confirmPassword) {
      _showError(l10n.errorPasswordsDoNotMatch);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isAvailable = await _authService.isUsernameAvailable(username);
      if (!mounted) return;
      if (!isAvailable) {
        _showError(l10n.errorUsernameTaken);
        setState(() => _isLoading = false);
        return;
      }

      final userCredential = await _authService.signUp(email, password);
      if (userCredential.user != null) {
        await _authService.createUserProfile(
          userCredential.user!.uid,
          fullName,
          username,
          email,
        );
      }

      if (!mounted) return;
      context.go('/home');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? l10n.errorRegistrationFailed);
    } catch (_) {
      _showError(l10n.errorGeneric);
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth
                .clamp(280.0, 460.0)
                .toDouble();
            final scale = (contentWidth / _baseWidth)
                .clamp(0.78, 1.2)
                .toDouble();
            double s(double value) => value * scale;

            final yNudge = s(4);
            final contentHeight = s(_baseContentHeight);
            final stackHeight = math.max(
              constraints.maxHeight,
              contentHeight + yNudge,
            );

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: s(20)),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    height: stackHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(child: Container(color: _bg)),
                        Positioned.fill(
                          child: Transform.translate(
                            offset: Offset(0, yNudge),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: s(-262),
                                  top: s(30),
                                  width: s(786),
                                  height: s(275),
                                  child: CustomPaint(
                                    painter: _AuthRibbonPainter(),
                                  ),
                                ),
                                Positioned(
                                  left: s(109),
                                  top: s(80),
                                  width: s(194),
                                  height: s(194),
                                  child: Image.asset(
                                    'assets/images/logo_pink.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  left: s(10),
                                  top: s(322),
                                  width: s(392),
                                  child: Text(
                                    l10n.registerTitle,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inriaSerif(
                                      fontSize: s(24),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      height: 1.05,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: s(22),
                                  top: s(386),
                                  child: _label(
                                    '${l10n.labelFullName}:',
                                    scale,
                                  ),
                                ),
                                Positioned(
                                  left: s(23),
                                  top: s(416),
                                  width: s(367),
                                  height: s(34),
                                  child: _RegisterField(
                                    controller: _fullNameController,
                                    obscureText: false,
                                    borderColor: _pink,
                                    scale: scale,
                                  ),
                                ),
                                Positioned(
                                  left: s(22),
                                  top: s(463),
                                  child: _label(
                                    '${l10n.labelUsername}:',
                                    scale,
                                  ),
                                ),
                                Positioned(
                                  left: s(23),
                                  top: s(492),
                                  width: s(367),
                                  height: s(34),
                                  child: _RegisterField(
                                    controller: _usernameController,
                                    obscureText: false,
                                    borderColor: _pink,
                                    scale: scale,
                                  ),
                                ),
                                Positioned(
                                  left: s(22),
                                  top: s(540),
                                  child: _label('${l10n.labelEmail}:', scale),
                                ),
                                Positioned(
                                  left: s(23),
                                  top: s(568),
                                  width: s(367),
                                  height: s(34),
                                  child: _RegisterField(
                                    controller: _emailController,
                                    obscureText: false,
                                    keyboardType: TextInputType.emailAddress,
                                    borderColor: _pink,
                                    scale: scale,
                                  ),
                                ),
                                Positioned(
                                  left: s(22),
                                  top: s(617),
                                  child: _label(
                                    '${l10n.labelPassword}:',
                                    scale,
                                  ),
                                ),
                                Positioned(
                                  left: s(23),
                                  top: s(644),
                                  width: s(367),
                                  height: s(34),
                                  child: _RegisterField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    borderColor: _pink,
                                    scale: scale,
                                  ),
                                ),
                                Positioned(
                                  left: s(22),
                                  top: s(694),
                                  child: _label(
                                    '${l10n.labelConfirmPassword}:',
                                    scale,
                                  ),
                                ),
                                Positioned(
                                  left: s(23),
                                  top: s(720),
                                  width: s(367),
                                  height: s(34),
                                  child: _RegisterField(
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                    borderColor: _pink,
                                    scale: scale,
                                  ),
                                ),
                                Positioned(
                                  left: s(24),
                                  top: s(796),
                                  width: s(365),
                                  height: s(45),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _navy,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          s(50),
                                        ),
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
                                            l10n.actionRegister,
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
                                  top: s(864),
                                  width: contentWidth,
                                  child: GestureDetector(
                                    onTap: () =>
                                        context.go(LoginScreen.routeName),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: GoogleFonts.inriaSerif(
                                          fontSize: s(18),
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: l10n.registerHaveAccount,
                                          ),
                                          TextSpan(
                                            text: l10n.actionLogin,
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _label(String text, double scale) {
    return Text(
      text,
      style: GoogleFonts.inriaSerif(
        fontSize: 18 * scale,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Color borderColor;
  final double scale;

  const _RegisterField({
    required this.controller,
    required this.obscureText,
    this.keyboardType = TextInputType.text,
    required this.borderColor,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
