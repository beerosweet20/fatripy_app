import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../localization/app_localizations_ext.dart';
import 'admin_design.dart';

enum AdminNavTab { dashboard, hotels, activities, events, bookings, settings }

class AdminBottomNav extends StatelessWidget {
  final AdminNavTab current;

  const AdminBottomNav({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AdminPalette.sky.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AdminPalette.navy : AdminPalette.mutedText,
          );
        }),
      ),
      child: NavigationBar(
        height: 72,
        selectedIndex: current.index,
        onDestinationSelected: (index) {
          final target = AdminNavTab.values[index];
          if (target == current) {
            return;
          }
          context.go(_routeOf(target));
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.adminNavDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.hotel_outlined),
            selectedIcon: const Icon(Icons.hotel),
            label: l10n.adminNavHotels,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_activity_outlined),
            selectedIcon: const Icon(Icons.local_activity),
            label: l10n.adminNavActivities,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: l10n.adminNavEvents,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.adminNavBookings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.adminNavSettings,
          ),
        ],
      ),
    );
  }

  String _routeOf(AdminNavTab tab) {
    switch (tab) {
      case AdminNavTab.dashboard:
        return '/admin';
      case AdminNavTab.hotels:
        return '/admin/hotels';
      case AdminNavTab.activities:
        return '/admin/activities';
      case AdminNavTab.events:
        return '/admin/events';
      case AdminNavTab.bookings:
        return '/admin/bookings';
      case AdminNavTab.settings:
        return '/admin/settings';
    }
  }
}
