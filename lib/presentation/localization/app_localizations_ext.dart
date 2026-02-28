import 'package:flutter/widgets.dart';
import 'package:fatripy_app/l10n/app_localizations.dart';

extension AppLocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
