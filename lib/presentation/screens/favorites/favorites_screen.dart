import 'package:flutter/material.dart';

import '../../localization/app_localizations_ext.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navFavorites)),
      body: Center(
        child: Text(
          context.l10n.navFavorites,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
