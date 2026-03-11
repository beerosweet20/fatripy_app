import 'package:flutter/material.dart';
import '../../localization/app_localizations_ext.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final items = [
      l10n.helpStep1,
      l10n.helpStep2,
      l10n.helpStep3,
      l10n.helpStep4,
      l10n.helpStep5,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.helpSubtitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          for (final line in items) ...[
            _HelpCard(text: line),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final String text;
  const _HelpCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
