import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fatripy_app/l10n/app_localizations.dart';

import 'router/app_router.dart';
import 'state/app_settings_provider.dart';
import 'theme/app_theme.dart';
import 'theme/responsive_scale.dart';

class FatripyApp extends ConsumerWidget {
  const FatripyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeVariant = ref.watch(themeVariantProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appName ?? 'Fatripy',
      locale: locale,
      theme: AppTheme.themeFor(themeVariant, 1.0),
      builder: (context, child) {
        final scale = AppScale.of(context);
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(scale)),
          child: Theme(
            data: AppTheme.themeFor(themeVariant, scale),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
