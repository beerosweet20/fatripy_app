import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../theme/app_theme.dart';

final localeProvider = StateProvider<Locale?>((ref) => null);

final themeVariantProvider =
    StateProvider<AppThemeVariant>((ref) => AppThemeVariant.defaultTheme);
