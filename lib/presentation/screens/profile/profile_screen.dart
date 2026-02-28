import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/firebase/auth_service.dart';
import '../../localization/app_localizations_ext.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navProfile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.family_restroom),
            title: Text(context.l10n.familyManagement),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(context.l10n.settings),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          if (kDebugMode) ...[
            const Divider(),
            ListTile(
              tileColor: Colors.red.withValues(alpha: 0.1),
              leading: const Icon(Icons.bug_report, color: Colors.red),
              title: Text(
                context.l10n.debugExplorer,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                assert(kDebugMode);
                context.go('/profile/debug-explorer');
              },
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(
              context.l10n.logout,
              style: const TextStyle(color: Colors.redAccent),
            ),
            onTap: () async {
              await AuthService().signOut();
              if (context.mounted) {
                // Router redirect handles sign-out.
              }
            },
          ),
        ],
      ),
    );
  }
}
