import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/firebase/auth_service.dart';
import '../../localization/app_localizations_ext.dart';
import '../../state/app_settings_provider.dart';
import 'admin_bottom_nav.dart';
import 'admin_design.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final AuthService _authService = AuthService();
  late final Future<bool> _isAdminFuture;

  @override
  void initState() {
    super.initState();
    _isAdminFuture = _authService.isAdmin();
  }

  Future<void> _logout() async {
    final l10n = context.l10n;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AdminPalette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.logout),
        content: Text(l10n.adminLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (shouldLogout != true) {
      return;
    }

    await _authService.signOut();
    if (!mounted) {
      return;
    }
    context.go('/account');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentUser = FirebaseAuth.instance.currentUser;
    final email = currentUser?.email ?? '-';
    final locale = ref.watch(localeProvider);
    final currentLocale = locale ?? Localizations.localeOf(context);

    return FutureBuilder<bool>(
      future: _isAdminFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != true) {
          return Scaffold(
            backgroundColor: AdminPalette.background,
            appBar: adminAppBar(context, title: l10n.adminSettingsTitle),
            body: AdminDecoratedBody(
              child: adminEmptyState(
                context: context,
                icon: Icons.lock_outline,
                message: l10n.adminNoAccess,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AdminPalette.background,
          appBar: adminAppBar(context, title: l10n.adminSettingsTitle),
          body: AdminDecoratedBody(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                AdminHeaderPanel(
                  icon: Icons.admin_panel_settings_outlined,
                  title: l10n.adminSettingsTitle,
                  subtitle: l10n.adminSettingsSubtitle,
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: adminCardShape(accentIndex: 1),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE7D7E3),
                      child: Icon(
                        Icons.alternate_email_rounded,
                        color: AdminPalette.navy,
                      ),
                    ),
                    title: Text(
                      l10n.labelEmail,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AdminPalette.text,
                      ),
                    ),
                    subtitle: Text(
                      email,
                      style: const TextStyle(color: AdminPalette.navy),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: adminCardShape(accentIndex: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AdminPalette.accentAt(
                        4,
                      ).withValues(alpha: 0.16),
                      child: Icon(
                        Icons.language_outlined,
                        color: AdminPalette.accentAt(4),
                      ),
                    ),
                    title: Text(
                      l10n.settingsLanguage,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AdminPalette.text,
                      ),
                    ),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<Locale>(
                        value: currentLocale.languageCode == 'ar'
                            ? const Locale('ar')
                            : const Locale('en'),
                        onChanged: (value) {
                          if (value == null) return;
                          ref.read(localeProvider.notifier).state = value;
                        },
                        items: [
                          DropdownMenuItem(
                            value: const Locale('ar'),
                            child: Text(l10n.languageArabic),
                          ),
                          DropdownMenuItem(
                            value: const Locale('en'),
                            child: Text(l10n.languageEnglish),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: l10n.settingsUserGuide,
                  subtitle: l10n.adminSettingsGuideSubtitle,
                  accentIndex: 2,
                  onTap: () => context.push('/help'),
                ),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.settingsPrivacyPolicy,
                  subtitle: l10n.adminSettingsPrivacySubtitle,
                  accentIndex: 5,
                  onTap: () => context.push('/privacy-policy'),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.logout),
                  style: FilledButton.styleFrom(
                    backgroundColor: AdminPalette.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AdminBottomNav(
            current: AdminNavTab.settings,
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int accentIndex;
  final VoidCallback onTap;

  const _SettingsTile({
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AdminPalette.accentAt(
            accentIndex,
          ).withValues(alpha: 0.16),
          child: Icon(icon, color: AdminPalette.accentAt(accentIndex)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AdminPalette.text,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AdminPalette.navy),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AdminPalette.accentAt(accentIndex),
        ),
        onTap: onTap,
      ),
    );
  }
}
