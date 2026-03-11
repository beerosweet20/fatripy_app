import 'package:flutter/material.dart';

class AdminPalette {
  static const Color rose = Color(0xFFD57F99);
  static const Color blush = Color(0xFFE2BECC);
  static const Color sky = Color(0xFF7A98CC);
  static const Color navy = Color(0xFF3A4F88);
  static const Color sand = Color(0xFFF0DEB2);
  static const Color honey = Color(0xFFF2D58F);
  static const Color background = Color(0xFFFFF8EB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF2A2A2A);
  static const Color mutedText = Color(0xFF5D6B8D);

  static const List<Color> accents = <Color>[
    rose,
    blush,
    sky,
    navy,
    sand,
    honey,
  ];

  static Color accentAt(int index) => accents[index % accents.length];
}

PreferredSizeWidget adminAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 62,
    titleSpacing: 16,
    elevation: 4,
    shadowColor: AdminPalette.navy.withValues(alpha: 0.14),
    surfaceTintColor: Colors.transparent,
    foregroundColor: AdminPalette.navy,
    backgroundColor: Colors.transparent,
    title: Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, end: 6),
      child: Text(
        title.trim(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: AdminPalette.navy,
          height: 1.1,
          shadows: <Shadow>[
            Shadow(
              blurRadius: 0.6,
              color: Color(0x22FFFFFF),
              offset: Offset(0, 0.3),
            ),
          ],
        ),
      ),
    ),
    centerTitle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    actions: actions,
    flexibleSpace: ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              AdminPalette.blush,
              AdminPalette.sand,
              AdminPalette.sky,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
  );
}

class AdminHeaderPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AdminHeaderPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: <Color>[
            AdminPalette.blush,
            AdminPalette.sand,
            AdminPalette.sky,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AdminPalette.rose.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 23,
            backgroundColor: Colors.white.withValues(alpha: 0.86),
            child: Icon(icon, color: AdminPalette.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AdminPalette.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AdminPalette.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget adminEmptyState({
  required BuildContext context,
  required IconData icon,
  required String message,
}) {
  return Center(
    child: Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminPalette.blush),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 34, color: AdminPalette.navy),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AdminPalette.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

InputDecoration adminInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AdminPalette.background,
    labelStyle: const TextStyle(color: AdminPalette.navy),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AdminPalette.blush.withValues(alpha: 0.8)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AdminPalette.blush.withValues(alpha: 0.85)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AdminPalette.navy, width: 1.35),
    ),
  );
}

class AdminDecoratedBody extends StatelessWidget {
  final Widget child;

  const AdminDecoratedBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -56,
          right: -42,
          child: _Bubble(
            color: AdminPalette.rose.withValues(alpha: 0.22),
            size: 148,
          ),
        ),
        Positioned(
          top: 110,
          left: -36,
          child: _Bubble(
            color: AdminPalette.sky.withValues(alpha: 0.20),
            size: 112,
          ),
        ),
        Positioned(
          bottom: -46,
          right: 18,
          child: _Bubble(
            color: AdminPalette.honey.withValues(alpha: 0.22),
            size: 124,
          ),
        ),
        child,
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final Color color;
  final double size;

  const _Bubble({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

RoundedRectangleBorder adminCardShape({required int accentIndex}) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
    side: BorderSide(
      color: AdminPalette.accentAt(accentIndex).withValues(alpha: 0.85),
      width: 1.25,
    ),
  );
}
