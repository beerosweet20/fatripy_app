import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/firebase/auth_service.dart';
import '../../localization/app_localizations_ext.dart';
import 'admin_bottom_nav.dart';
import 'admin_design.dart';

class ManageContentScreen extends StatefulWidget {
  const ManageContentScreen({super.key});

  @override
  State<ManageContentScreen> createState() => _ManageContentScreenState();
}

class _ManageContentScreenState extends State<ManageContentScreen> {
  late final Future<bool> _isAdminFuture;

  @override
  void initState() {
    super.initState();
    _isAdminFuture = AuthService().isAdmin();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<bool>(
      future: _isAdminFuture,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final isAdmin = snapshot.data == true;

        if (loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!isAdmin) {
          return Scaffold(
            backgroundColor: AdminPalette.background,
            appBar: adminAppBar(context, title: l10n.adminManageTitle),
            body: AdminDecoratedBody(
              child: adminEmptyState(
                context: context,
                icon: Icons.lock_outline,
                message: l10n.adminManageOnlyAdmins,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AdminPalette.background,
          appBar: adminAppBar(context, title: l10n.adminManageTitle),
          body: AdminDecoratedBody(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ManageTile(
                  icon: Icons.hotel_outlined,
                  title: l10n.adminTabHotels,
                  subtitle: l10n.adminManageHotelsSubtitle,
                  accentIndex: 0,
                  onTap: () => context.go('/admin/hotels'),
                ),
                const SizedBox(height: 12),
                _ManageTile(
                  icon: Icons.local_activity_outlined,
                  title: l10n.adminTabActivities,
                  subtitle: l10n.adminManageActivitiesSubtitle,
                  accentIndex: 1,
                  onTap: () => context.go('/admin/activities'),
                ),
                const SizedBox(height: 12),
                _ManageTile(
                  icon: Icons.event_outlined,
                  title: l10n.plansLabelEvents,
                  subtitle: l10n.adminManageEventsSubtitle,
                  accentIndex: 2,
                  onTap: () => context.go('/admin/events'),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AdminBottomNav(
            current: AdminNavTab.dashboard,
          ),
        );
      },
    );
  }
}

class _ManageTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int accentIndex;
  final VoidCallback onTap;

  const _ManageTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: adminCardShape(accentIndex: accentIndex),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AdminPalette.accentAt(
            accentIndex,
          ).withValues(alpha: 0.16),
          child: Icon(icon, color: AdminPalette.accentAt(accentIndex)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.chevron_right,
          color: AdminPalette.accentAt(accentIndex),
        ),
        onTap: onTap,
      ),
    );
  }
}
