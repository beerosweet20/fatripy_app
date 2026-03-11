import 'package:flutter/material.dart';
import '../../localization/app_localizations_ext.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionTitle(l10n.privacySection1Title),
          _SectionBody(
            l10n.privacySection1Body,
          ),
          const SizedBox(height: 16),
          _SectionTitle(l10n.privacySection2Title),
          _SectionBody(
            l10n.privacySection2Body,
          ),
          const SizedBox(height: 16),
          _SectionTitle(l10n.privacySection3Title),
          _SectionBody(
            l10n.privacySection3Body,
          ),
          const SizedBox(height: 16),
          _SectionTitle(l10n.privacySection4Title),
          _SectionBody(
            l10n.privacySection4Body,
          ),
          const SizedBox(height: 16),
          _SectionTitle(l10n.privacySection5Title),
          _SectionBody(
            l10n.privacySection5Body,
          ),
          const SizedBox(height: 16),
          _SectionTitle(l10n.privacySection6Title),
          _SectionBody(
            l10n.privacySection6Body,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;

  const _SectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 15, height: 1.45));
  }
}
