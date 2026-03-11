import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/app_localizations_ext.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _cream = Color(0xFFFFF7E5);
  static const Color _navy = Color(0xFF31487A);
  static const Color _pink = Color(0xFFE18299);
  static const Color _pinkLine = Color(0xFFF5C9D4);
  static const Color _blueLine = Color(0xFF7FA2DA);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(4, 30, 4, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.homeWelcomeTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inriaSerif(
                  color: Colors.black,
                  fontSize: 40,
                  height: 1.22,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 33),
              _HeroCard(subtitle: l10n.homeHeroSubtitle),
              const SizedBox(height: 50),
              _SectionHeader(
                label: l10n.homeMainDestination,
                fillColor: _pink,
                borderColor: _pinkLine,
                lineColor: _pinkLine,
                textColor: Colors.black,
                width: 200,
              ),
              const SizedBox(height: 12),
              _DestinationPanel(
                card1Title: l10n.homeDestination1Title,
                card1Description: l10n.homeDestination1Description,
                card2Title: l10n.homeDestination2Title,
                card2Description: l10n.homeDestination2Description,
                card3Title: l10n.homeDestination3Title,
                card3Description: l10n.homeDestination3Description,
              ),
              const SizedBox(height: 48),
              _SectionHeader(
                label: l10n.homeSeasonalAttractions,
                fillColor: _navy,
                borderColor: _blueLine,
                lineColor: _blueLine,
                textColor: Colors.white,
                width: 225,
              ),
              const SizedBox(height: 12),
              _SeasonPanel(
                card1Title: l10n.homeSeason1Title,
                card1Description: l10n.homeSeason1Description,
                card2Title: l10n.homeSeason2Title,
                card2Description: l10n.homeSeason2Description,
                card3Title: l10n.homeSeason3Title,
                card3Description: l10n.homeSeason3Description,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String subtitle;

  const _HeroCard({required this.subtitle});

  static const Color _cream = Color(0xFFFFF7E5);
  static const Color _navy = Color(0xFF31487A);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 159,
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: _navy, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 14, 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                'assets/images/home/hero_riyadh.jpg',
                width: 118,
                height: 143,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                subtitle,
                style: GoogleFonts.inriaSerif(
                  color: _navy,
                  fontSize: 40 / 1.67,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color fillColor;
  final Color borderColor;
  final Color lineColor;
  final Color textColor;
  final double width;

  const _SectionHeader({
    required this.label,
    required this.fillColor,
    required this.borderColor,
    required this.lineColor,
    required this.textColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 43,
            child: Container(height: 3, color: lineColor),
          ),
          Container(
            width: width,
            height: 85,
            padding: const EdgeInsets.only(left: 20, right: 14),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: fillColor,
              border: Border.all(color: borderColor, width: 4),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.inriaSerif(
                color: textColor,
                fontSize: 33 / 1.65,
                height: 1.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationPanel extends StatelessWidget {
  final String card1Title;
  final String card1Description;
  final String card2Title;
  final String card2Description;
  final String card3Title;
  final String card3Description;

  const _DestinationPanel({
    required this.card1Title,
    required this.card1Description,
    required this.card2Title,
    required this.card2Description,
    required this.card3Title,
    required this.card3Description,
  });

  static const Color _cream = Color(0xFFFFF7E5);
  static const Color _pinkLine = Color(0xFFF5C9D4);

  @override
  Widget build(BuildContext context) {
    final cards = [
      _DestinationCard(
        title: card1Title,
        imagePath: 'assets/images/home/destination_diriyah.jpg',
        description: card1Description,
      ),
      _DestinationCard(
        title: card2Title,
        imagePath: 'assets/images/home/destination_al_olaya.jpg',
        description: card2Description,
      ),
      _DestinationCard(
        title: card3Title,
        imagePath: 'assets/images/home/destination_jabal_tuwaiq.jpg',
        description: card3Description,
      ),
    ];

    return Container(
      height: 355,
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _pinkLine, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(15, 66, 16, 22),
          child: Row(
            children: [
              for (int i = 0; i < cards.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    right: i == cards.length - 1 ? 0 : 30,
                  ),
                  child: cards[i],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;

  const _DestinationCard({
    required this.title,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 163,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE18299), width: 4),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inriaSerif(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 131,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE18299), width: 3),
            ),
            child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover)),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inriaSerif(
              color: Colors.black,
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonPanel extends StatelessWidget {
  final String card1Title;
  final String card1Description;
  final String card2Title;
  final String card2Description;
  final String card3Title;
  final String card3Description;

  const _SeasonPanel({
    required this.card1Title,
    required this.card1Description,
    required this.card2Title,
    required this.card2Description,
    required this.card3Title,
    required this.card3Description,
  });

  static const Color _cream = Color(0xFFFFF7E5);
  static const Color _navy = Color(0xFF31487A);

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SeasonCard(
        title: card1Title,
        imagePath: 'assets/images/home/season_riyadh_season.jpg',
        description: card1Description,
      ),
      _SeasonCard(
        title: card2Title,
        imagePath: 'assets/images/home/season_boulevard.jpg',
        description: card2Description,
      ),
      _SeasonCard(
        title: card3Title,
        imagePath: 'assets/images/home/season_noor_riyadh.jpg',
        description: card3Description,
      ),
    ];

    return Container(
      height: 275,
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _navy, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 36, 24, 24),
          child: Row(
            children: [
              for (int i = 0; i < cards.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    right: i == cards.length - 1 ? 0 : 18,
                  ),
                  child: cards[i],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;

  const _SeasonCard({
    required this.title,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 297,
      height: 187,
      child: Stack(
        children: [
          Positioned(
            left: 72,
            top: 0,
            child: Container(
              width: 225,
              height: 187,
              // Keep text fully outside the overlapped circular image area.
              padding: const EdgeInsets.fromLTRB(84, 10, 10, 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF31487A), width: 4),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inriaSerif(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inriaSerif(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 20,
            child: Container(
              width: 152,
              height: 154,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF31487A), width: 3),
              ),
              child: ClipOval(child: Image.asset(imagePath, fit: BoxFit.cover)),
            ),
          ),
        ],
      ),
    );
  }
}
