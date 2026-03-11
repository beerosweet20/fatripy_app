import 'package:flutter/material.dart';

import '../../localization/app_localizations_ext.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navCart)),
      body: Center(
        child: Text(
          context.l10n.navCart,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
