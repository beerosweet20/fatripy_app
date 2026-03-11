import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../localization/app_localizations_ext.dart';
import '../../state/app_settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/responsive_scale.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scale = AppScale.of(context);
    final locale = ref.watch(localeProvider);
    final themeVariant = ref.watch(themeVariantProvider);

    final currentLocale = locale ?? Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: EdgeInsets.all(scale * 20),
        children: [
          _SettingsTile(
            label: l10n.settingsEditProfile,
            onTap: () => context.push('/edit-profile'),
            trailing: Icon(Icons.chevron_right, size: scale * 26),
          ),
          SizedBox(height: scale * 16),
          _SettingsTile(
            label: l10n.settingsUserGuide,
            onTap: () => context.push('/help'),
            trailing: Icon(Icons.chevron_right, size: scale * 26),
          ),
          SizedBox(height: scale * 16),
          _SettingsTile(
            label: l10n.settingsPrivacyPolicy,
            onTap: () => context.push('/privacy-policy'),
            trailing: Icon(Icons.chevron_right, size: scale * 26),
          ),
          SizedBox(height: scale * 16),
          _SettingsSection(
            title: l10n.settingsLanguage,
            child: DropdownButton<Locale>(
              value: currentLocale.languageCode == 'ar'
                  ? const Locale('ar')
                  : const Locale('en'),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
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
          SizedBox(height: scale * 16),
          _SettingsSection(
            title: l10n.settingsTheme,
            child: DropdownButton<AppThemeVariant>(
              value: themeVariant,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                ref.read(themeVariantProvider.notifier).state = value;
              },
              items: [
                DropdownMenuItem(
                  value: AppThemeVariant.defaultTheme,
                  child: Text(l10n.themeDefault),
                ),
                DropdownMenuItem(
                  value: AppThemeVariant.pinkTheme,
                  child: Text(l10n.themePink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(scale * 16),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: scale * 16,
          vertical: scale * 14,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(scale * 16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(fontSize: scale * 16)),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale * 16,
        vertical: scale * 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(scale * 16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: TextStyle(fontSize: scale * 16)),
          ),
          child,
        ],
      ),
    );
  }
}
