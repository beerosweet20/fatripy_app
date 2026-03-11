import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/app_localizations_ext.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  static const double _designWidth = 412;
  static const double _designHeight = 1603;

  static const Color _bg = Color(0xFFFFF7E5);
  static const Color _header = Color(0xFFFFDC91);
  static const Color _blue = Color(0xFF7FA2DA);
  static const Color _pinkLight = Color(0xFFF5C9D4);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showBack = context.canPop();
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _designWidth;
            double s(double value) => value * scale;

            return SingleChildScrollView(
              child: SizedBox(
                width: constraints.maxWidth,
                height: s(_designHeight),
                child: Stack(
                  children: [
                    Positioned.fill(child: Container(color: _bg)),
                    Positioned(
                      left: s(1),
                      top: s(64),
                      width: s(410),
                      height: s(51),
                      child: Container(color: _header),
                    ),
                    if (showBack)
                      Positioned(
                        left: s(12),
                        top: s(78),
                        width: s(24),
                        height: s(24),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: s(24),
                          onPressed: () {
                            if (context.canPop()) context.pop();
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      top: s(67),
                      width: constraints.maxWidth,
                      child: Text(
                        l10n.blogTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inriaSerif(
                          fontSize: s(21),
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      left: s(96),
                      top: s(93),
                      width: s(235),
                      height: s(17),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          l10n.blogSubtitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          textScaler: TextScaler.noScaling,
                          style: GoogleFonts.inriaSerif(
                            fontSize: s(12),
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    _BlogCityCard(
                      x: s(1),
                      y: s(190),
                      width: s(338),
                      height: s(230),
                      badgeX: s(-2),
                      badgeY: s(169),
                      badgeWidth: s(120),
                      badgeHeight: s(43),
                      badgeText: l10n.cityRiyadh,
                      badgeColor: _blue,
                      borderColor: _pinkLight,
                      circleX: s(281),
                      circleY: s(384),
                      circleSize: s(100),
                      imagePath: 'assets/images/home/hero_riyadh.jpg',
                      contentPadding: EdgeInsets.fromLTRB(
                        s(9),
                        s(28),
                        s(12),
                        s(8),
                      ),
                      description: l10n.blogRiyadhDescription,
                    ),
                    Positioned(
                      left: s(36),
                      top: s(508),
                      width: s(376),
                      height: s(70),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _blue,
                          borderRadius: BorderRadius.circular(s(8)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.blogFutureNotice,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inriaSerif(
                            fontSize: s(18),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    _BlogCityCard(
                      x: s(1),
                      y: s(685),
                      width: s(338),
                      height: s(230),
                      badgeX: s(1),
                      badgeY: s(665),
                      badgeWidth: s(120),
                      badgeHeight: s(40),
                      badgeText: l10n.cityJeddah,
                      badgeColor: _blue,
                      borderColor: _pinkLight,
                      circleX: s(287),
                      circleY: s(846),
                      circleSize: s(100),
                      imagePath: 'assets/images/home/season_boulevard.jpg',
                      contentPadding: EdgeInsets.fromLTRB(
                        s(16),
                        s(23),
                        s(42),
                        s(12),
                      ),
                      description: l10n.blogJeddahDescription,
                    ),
                    _BlogCityCard(
                      x: s(74),
                      y: s(975),
                      width: s(338),
                      height: s(230),
                      badgeX: s(293),
                      badgeY: s(955),
                      badgeWidth: s(120),
                      badgeHeight: s(40),
                      badgeText: l10n.blogCityJazan,
                      badgeColor: _blue,
                      borderColor: _pinkLight,
                      circleX: s(24),
                      circleY: s(1135),
                      circleSize: s(100),
                      imagePath: 'assets/images/home/season_noor_riyadh.jpg',
                      contentPadding: EdgeInsets.fromLTRB(
                        s(43),
                        s(27),
                        s(7),
                        s(20),
                      ),
                      description: l10n.blogJazanDescription,
                    ),
                    _BlogCityCard(
                      x: s(1),
                      y: s(1266),
                      width: s(338),
                      height: s(230),
                      badgeX: s(1),
                      badgeY: s(1246),
                      badgeWidth: s(120),
                      badgeHeight: s(40),
                      badgeText: l10n.blogCityAlKhobar,
                      badgeColor: _blue,
                      borderColor: _pinkLight,
                      circleX: s(289),
                      circleY: s(1439),
                      circleSize: s(100),
                      imagePath: 'assets/images/home/season_riyadh_season.jpg',
                      contentPadding: EdgeInsets.fromLTRB(
                        s(13),
                        s(24),
                        s(16),
                        s(12),
                      ),
                      description: l10n.blogAlKhobarDescription,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BlogCityCard extends StatelessWidget {
  final double x;
  final double y;
  final double width;
  final double height;
  final double badgeX;
  final double badgeY;
  final double badgeWidth;
  final double badgeHeight;
  final String badgeText;
  final Color badgeColor;
  final Color borderColor;
  final double circleX;
  final double circleY;
  final double circleSize;
  final String imagePath;
  final EdgeInsets contentPadding;
  final String description;

  const _BlogCityCard({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.badgeX,
    required this.badgeY,
    required this.badgeWidth,
    required this.badgeHeight,
    required this.badgeText,
    required this.badgeColor,
    required this.borderColor,
    required this.circleX,
    required this.circleY,
    required this.circleSize,
    required this.imagePath,
    required this.contentPadding,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: x,
          top: y,
          width: width,
          height: height,
          child: Container(
            padding: contentPadding,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E5),
              borderRadius: BorderRadius.circular(width * 0.03),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Text(
              description,
              textAlign: TextAlign.left,
              style: GoogleFonts.inriaSerif(
                color: Colors.black,
                fontSize: width * 0.036,
                height: 1.12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        Positioned(
          left: badgeX,
          top: badgeY,
          width: badgeWidth,
          height: badgeHeight,
          child: Container(
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(badgeHeight * 0.2),
            ),
            alignment: Alignment.center,
            child: Text(
              badgeText,
              style: GoogleFonts.inriaSerif(
                color: Colors.white,
                fontSize: badgeHeight * 0.52,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ),
        ),
        Positioned(
          left: circleX,
          top: circleY,
          width: circleSize,
          height: circleSize,
          child: _DecorativeCircle(imagePath: imagePath),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final String imagePath;

  const _DecorativeCircle({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF7FA2DA), width: 2.5),
      ),
      child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover)),
    );
  }
}
