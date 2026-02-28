import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Fatripy'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get navPlans;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get loginWelcome;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @labelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// No description provided for @actionLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get actionLogin;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// No description provided for @actionRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get actionRegister;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Please fill out the form to register'**
  String get registerTitle;

  /// No description provided for @labelFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get labelFullName;

  /// No description provided for @labelUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get labelUsername;

  /// No description provided for @labelConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get labelConfirmPassword;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccount;

  /// No description provided for @errorFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get errorFillAllFields;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get errorLoginFailed;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorUsernameNoSpaces.
  ///
  /// In en, this message translates to:
  /// **'Username cannot contain spaces.'**
  String get errorUsernameNoSpaces;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @errorUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username already taken.'**
  String get errorUsernameTaken;

  /// No description provided for @errorRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get errorRegistrationFailed;

  /// No description provided for @homeGreetingName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String homeGreetingName(Object name);

  /// No description provided for @homeFriendName.
  ///
  /// In en, this message translates to:
  /// **'friend'**
  String get homeFriendName;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s plan your next family trip'**
  String get homeSubtitle;

  /// No description provided for @familyCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Family members: {count}'**
  String familyCountLabel(int count);

  /// No description provided for @familyManagement.
  ///
  /// In en, this message translates to:
  /// **'Family management'**
  String get familyManagement;

  /// No description provided for @startPlanning.
  ///
  /// In en, this message translates to:
  /// **'Start planning'**
  String get startPlanning;

  /// No description provided for @homeAiTeaser.
  ///
  /// In en, this message translates to:
  /// **'Smart planning builds your family trip'**
  String get homeAiTeaser;

  /// No description provided for @latestPlans.
  ///
  /// In en, this message translates to:
  /// **'Latest plans'**
  String get latestPlans;

  /// No description provided for @recentBookings.
  ///
  /// In en, this message translates to:
  /// **'Recent bookings'**
  String get recentBookings;

  /// No description provided for @createPlan.
  ///
  /// In en, this message translates to:
  /// **'Create plan'**
  String get createPlan;

  /// No description provided for @emptyPlans.
  ///
  /// In en, this message translates to:
  /// **'No plans yet.'**
  String get emptyPlans;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @errorPleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue.'**
  String get errorPleaseLogin;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String errorWithDetails(Object details);

  /// No description provided for @planSummary.
  ///
  /// In en, this message translates to:
  /// **'{days} days • {budget} SAR'**
  String planSummary(int days, Object budget);

  /// No description provided for @bookingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading bookings.'**
  String get bookingsLoadError;

  /// No description provided for @bookingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet.'**
  String get bookingsEmpty;

  /// No description provided for @bookingItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking: {itemType}'**
  String bookingItemTitle(Object itemType);

  /// No description provided for @bookingPlacedOn.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String bookingPlacedOn(Object date);

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @planListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Budget: {budget} • {status}'**
  String planListSubtitle(Object budget, Object status);

  /// No description provided for @bookingListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Status: {status} • Placed: {date}'**
  String bookingListSubtitle(Object status, Object date);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @debugExplorer.
  ///
  /// In en, this message translates to:
  /// **'Data Explorer (Debug)'**
  String get debugExplorer;

  /// No description provided for @hotelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotelsTitle;

  /// No description provided for @hotelsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data.'**
  String get hotelsLoadError;

  /// No description provided for @hotelsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get hotelsNoData;

  /// No description provided for @hotelsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No hotels to show.'**
  String get hotelsEmpty;

  /// No description provided for @hotelNameUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown hotel'**
  String get hotelNameUnknown;

  /// No description provided for @hotelLocationUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get hotelLocationUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
