import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/app_localizations_ext.dart';
import '../../state/auth_providers.dart';
import '../auth/login_screen.dart';
import 'profile_screen.dart';

class AccountEntryScreen extends ConsumerWidget {
  const AccountEntryScreen({super.key});

  static String? _nameFromEmail(String email) {
    if (email.isEmpty || !email.contains('@')) {
      return null;
    }
    final localPart = email.split('@').first;
    if (localPart.isEmpty) {
      return null;
    }
    return localPart.replaceAll(RegExp(r'[._-]+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }
        final email = (user.email ?? '').trim();
        final displayName = (user.displayName ?? '').trim();
        final resolvedName =
            displayName.isNotEmpty ? displayName : (_nameFromEmail(email) ?? context.l10n.labelUsername);
        return ProfileScreen(
          displayName: resolvedName,
          email: email.isNotEmpty ? email : null,
        );
      },
      loading: () => Scaffold(
        body: Center(
          child: Text(context.l10n.loading),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text(
            context.l10n.errorWithDetails(error.toString()),
          ),
        ),
      ),
    );
  }
}
