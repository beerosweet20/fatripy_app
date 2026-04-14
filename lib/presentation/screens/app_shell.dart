import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localization/app_localizations_ext.dart';
import '../state/auth_providers.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final int currentIndex = widget.navigationShell.currentIndex;
    const barColor = Color(0xFF7FA2DA);
    const borderColor = Color(0xFF31487A);
    final loggedIn = ref.watch(authStateProvider).asData?.value != null;
    final l10n = context.l10n;

    return Container(
      decoration: const BoxDecoration(
        color: barColor,
        border: Border(top: BorderSide(color: borderColor, width: 3)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: barColor,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          selectedIconTheme: const IconThemeData(size: 24),
          unselectedIconTheme: const IconThemeData(size: 24),
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          onTap: (index) {
            widget.navigationShell.goBranch(index, initialLocation: true);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bookmarks_outlined),
              label: l10n.navBlog,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_rounded),
              label: l10n.navPlans,
            ),
            BottomNavigationBarItem(
              icon: Icon(loggedIn ? Icons.account_circle : Icons.login),
              label: loggedIn ? l10n.navAccount : l10n.navLogin,
            ),
          ],
        ),
      ),
    );
  }
}
