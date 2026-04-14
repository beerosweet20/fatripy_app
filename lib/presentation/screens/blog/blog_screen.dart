import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/supported_cities.dart';
import '../../localization/app_localizations_ext.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  static const double _designWidth = 412;

  static const Color _bg = Color(0xFFFFF7E5);
  static const Color _header = Color(0xFFFFDC91);
  static const Color _blue = Color(0xFF7FA2DA);
  static const Color _pinkLight = Color(0xFFF5C9D4);

  String _descriptionForCity(BuildContext context, String city) {
    final l10n = context.l10n;
    switch (city) {
      case 'Riyadh':
        return l10n.blogRiyadhDescription;
      case 'Jeddah':
        return l10n.blogJeddahDescription;
      case 'Mecca':
        return l10n.blogMeccaDescription;
      case 'Medina':
        return l10n.blogMadinahDescription;
      case 'Dammam':
        return l10n.blogDammamDescription;
      case 'Abha':
        return l10n.blogAbhaDescription;
      case 'Taif':
        return l10n.blogTaifDescription;
      case 'Jazan':
        return l10n.blogJazanDescription;
      case 'Khobar':
        return l10n.blogAlKhobarDescription;
      default:
        return l10n.blogCityGenericDescription(localizeCityLabel(l10n, city));
    }
  }

  String _badgeTitleForCity(BuildContext context, String city) {
    final l10n = context.l10n;
    switch (city) {
      case 'Medina':
        return l10n.blogMadinahTitle;
      default:
        return localizeCityLabel(l10n, city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showBack = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: false,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _designWidth;
            double s(double value) => value * scale;

            final cities = <String>[
              ...AppCities.values.where(
                (city) =>
                    city != 'Mecca' &&
                    city != 'Medina' &&
                    city != 'Dammam' &&
                    city != 'Abha' &&
                    city != 'Taif',
              ),
              'Mecca',
              'Medina',
              'Dammam',
              'Abha',
              'Taif',
            ];
            const double cardTopBase = 190;
            const double cardStep = 372;
            const double badgeOffset = -20;
            const double circleOffset = 205;
            final designHeight = cardTopBase + (cities.length * cardStep) + 220;

            return SingleChildScrollView(
              child: SizedBox(
                width: constraints.maxWidth,
                height: s(designHeight.toDouble()),
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
                      PositionedDirectional(
                        start: s(12),
                        top: s(78),
                        width: s(24),
                        height: s(24),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: s(24),
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          },
                          icon: const BackButtonIcon(),
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
                    PositionedDirectional(
                      start: s(42),
                      end: s(42),
                      top: s(93),
                      child: Text(
                        l10n.blogSubtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inriaSerif(
                          fontSize: s(12).clamp(11.0, 14.0),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          height: 1.15,
                        ),
                      ),
                    ),
                    for (int i = 0; i < cities.length; i++)
                      Builder(
                        builder: (context) {
                          final city = cities[i];
                          final isMecca = city == 'Mecca';
                          return _BlogCityCard(
                            start: i.isOdd ? s(74) : s(1),
                            y: s(cardTopBase + (i * cardStep)),
                            width: s(338),
                            height: s(248),
                            badgeStart: i.isOdd ? s(293) : s(1),
                            badgeY: s(
                              cardTopBase + (i * cardStep) + badgeOffset,
                            ),
                            badgeWidth: s(120),
                            badgeHeight: s(40),
                            badgeText: _badgeTitleForCity(context, city),
                            badgeColor: _blue,
                            borderColor: isMecca
                                ? const Color(0xFFE6A9B3)
                                : _pinkLight,
                            backgroundColor: isMecca
                                ? const Color(0xFFF3E8D7)
                                : const Color(0xFFFFF7E5),
                            borderRadius: isMecca ? s(20) : s(10),
                            circleStart: i.isOdd ? s(24) : s(289),
                            circleY: s(
                              cardTopBase + (i * cardStep) + circleOffset,
                            ),
                            circleSize: s(100),
                            imagePath: cityImageAsset(city),
                            contentPadding: isMecca
                                ? EdgeInsetsDirectional.all(s(20))
                                : EdgeInsetsDirectional.fromSTEB(
                                    i.isOdd ? s(56) : s(13),
                                    s(24),
                                    i.isOdd ? s(14) : s(56),
                                    s(12),
                                  ),
                            description: _descriptionForCity(context, city),
                          );
                        },
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
  final double start;
  final double y;
  final double width;
  final double height;
  final double badgeStart;
  final double badgeY;
  final double badgeWidth;
  final double badgeHeight;
  final String badgeText;
  final Color badgeColor;
  final Color borderColor;
  final Color backgroundColor;
  final double borderRadius;
  final double circleStart;
  final double circleY;
  final double circleSize;
  final String imagePath;
  final EdgeInsetsGeometry contentPadding;
  final String description;

  const _BlogCityCard({
    required this.start,
    required this.y,
    required this.width,
    required this.height,
    required this.badgeStart,
    required this.badgeY,
    required this.badgeWidth,
    required this.badgeHeight,
    required this.badgeText,
    required this.badgeColor,
    required this.borderColor,
    required this.backgroundColor,
    required this.borderRadius,
    required this.circleStart,
    required this.circleY,
    required this.circleSize,
    required this.imagePath,
    required this.contentPadding,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final descriptionFontSize = (width * 0.036).clamp(11.0, 14.0);
    final badgeFontSize = (badgeHeight * 0.52).clamp(16.0, 24.0);

    return Stack(
      children: [
        PositionedDirectional(
          start: start,
          top: y,
          width: width,
          height: height,
          child: Container(
            padding: contentPadding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Text(
              description,
              textAlign: TextAlign.start,
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inriaSerif(
                color: Colors.black,
                fontSize: descriptionFontSize,
                height: 1.25,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: badgeStart,
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
                fontSize: badgeFontSize,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: circleStart,
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
