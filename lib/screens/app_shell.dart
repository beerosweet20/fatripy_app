import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';

class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows content to scroll behind the floating bar
      body: widget.navigationShell,
      bottomNavigationBar: _buildPremiumBottomNav(context),
    );
  }

  Widget _buildPremiumBottomNav(BuildContext context) {
    final int currentIndex = widget.navigationShell.currentIndex;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withAlpha(25), // Elegant subtle shadow
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              0,
              Icons.home_rounded,
              Icons.home_outlined,
              AppStrings.navHome,
              currentIndex,
              colorScheme,
            ),
            _buildNavItem(
              1,
              Icons.map_rounded,
              Icons.map_outlined,
              AppStrings.navPlans,
              currentIndex,
              colorScheme,
            ),
            _buildNavItem(
              2,
              Icons.confirmation_number_rounded,
              Icons.confirmation_number_outlined,
              AppStrings.navBookings,
              currentIndex,
              colorScheme,
            ),
            _buildNavItem(
              3,
              Icons.person_rounded,
              Icons.person_outline,
              AppStrings.navProfile,
              currentIndex,
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int currentIndex,
    ColorScheme colorScheme,
  ) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withAlpha(100),
                size: 26,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
