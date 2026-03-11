import 'package:flutter/material.dart';

import '../../localization/app_localizations_ext.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navShop)),
      body: Center(
        child: Text(
          context.l10n.navShop,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
