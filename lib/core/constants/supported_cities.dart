import '../../l10n/app_localizations.dart';

abstract final class AppCities {
  static const List<String> values = <String>[
    'Riyadh',
    'Jeddah',
    'Mecca',
    'Medina',
    'Dammam',
    'Khobar',
    'Abha',
    'Taif',
    'Jazan',
  ];
}

String localizeCityLabel(AppLocalizations l10n, String city) {
  switch (city.trim()) {
    case 'Riyadh':
      return l10n.cityRiyadh;
    case 'Jeddah':
      return l10n.cityJeddah;
    case 'Mecca':
      return l10n.cityMecca;
    case 'Medina':
      return l10n.cityMedina;
    case 'Dammam':
      return l10n.cityDammam;
    case 'Khobar':
      return l10n.cityKhobar;
    case 'Abha':
      return l10n.cityAbha;
    case 'Taif':
      return l10n.cityTaif;
    case 'Jazan':
      return l10n.cityJazan;
    default:
      return city;
  }
}

String cityImageAsset(String city) {
  switch (city.trim()) {
    case 'Riyadh':
      return 'assets/images/home/hero_riyadh.jpg';
    case 'Jeddah':
      return 'assets/images/home/season_boulevard.jpg';
    case 'Mecca':
      return 'assets/images/home/mecca.jpg';
    case 'Medina':
      return 'assets/images/home/madinah.jpg';
    case 'Dammam':
      return 'assets/images/home/dammam.jpg';
    case 'Khobar':
      return 'assets/images/home/destination_al_olaya.jpg';
    case 'Abha':
      return 'assets/images/home/abha.jpg';
    case 'Taif':
      return 'assets/images/home/taif.jpg';
    case 'Jazan':
      return 'assets/images/home/season_noor_riyadh.jpg';
    default:
      return 'assets/images/home/hero_riyadh.jpg';
  }
}
