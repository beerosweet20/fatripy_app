import 'package:flutter/material.dart';

import '../../localization/app_localizations_ext.dart';

class DebugExplorerScreen extends StatelessWidget {
  const DebugExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.debugExplorer)),
      body: Center(
        child: Text(
          context.l10n.debugExplorer,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
