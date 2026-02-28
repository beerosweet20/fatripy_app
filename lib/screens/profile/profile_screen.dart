import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navProfile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.family_restroom),
            title: const Text(AppStrings.familyManagement),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(AppStrings.settings),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right),
          ),

          // Debug only Firestore Explorer Gateway
          if (kDebugMode) ...[
            const Divider(),
            ListTile(
              tileColor: Colors.red.withOpacity(0.1),
              leading: const Icon(Icons.bug_report, color: Colors.red),
              title: const Text(
                AppStrings.debugExplorer,
                style: TextStyle(
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
            title: const Text(
              AppStrings.logout,
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () async {
              await AuthService().signOut();
              if (context.mounted) {
                // AuthGate will naturally catch this, but we can force redirect if needed
              }
            },
          ),
        ],
      ),
    );
  }
}
