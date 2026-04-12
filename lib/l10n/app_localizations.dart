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

  /// No description provided for @navBlog.
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get navBlog;

  /// No description provided for @navLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get navLogin;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

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

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get accountTitle;

  /// No description provided for @accountNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get accountNotifications;

  /// No description provided for @accountDependents.
  ///
  /// In en, this message translates to:
  /// **'Dependents'**
  String get accountDependents;

  /// No description provided for @accountSettingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Setting&Privacy'**
  String get accountSettingsPrivacy;

  /// No description provided for @accountBookedAttraction.
  ///
  /// In en, this message translates to:
  /// **'Booked Attraction'**
  String get accountBookedAttraction;

  /// No description provided for @accountDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get accountDeleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get deleteAccountSuccess;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get settingsEditProfile;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @themeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get themeDefault;

  /// No description provided for @themePink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get themePink;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get editProfileName;

  /// No description provided for @editProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get editProfileEmail;

  /// No description provided for @editProfileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Updating email may require recent login'**
  String get editProfileEmailHint;

  /// No description provided for @editProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get editProfileSuccess;

  /// No description provided for @editProfileReauth.
  ///
  /// In en, this message translates to:
  /// **'Please log in again to update your email.'**
  String get editProfileReauth;

  /// No description provided for @dependentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Write Your Information'**
  String get dependentsTitle;

  /// No description provided for @dependentsMyFamily.
  ///
  /// In en, this message translates to:
  /// **'My Family'**
  String get dependentsMyFamily;

  /// No description provided for @dependentsTripInfo.
  ///
  /// In en, this message translates to:
  /// **'Trip info'**
  String get dependentsTripInfo;

  /// No description provided for @dependentsAdults.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get dependentsAdults;

  /// No description provided for @dependentsChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get dependentsChildren;

  /// No description provided for @dependentsInfant.
  ///
  /// In en, this message translates to:
  /// **'INFANT'**
  String get dependentsInfant;

  /// No description provided for @dependentsAdultAges.
  ///
  /// In en, this message translates to:
  /// **'Adult ages'**
  String get dependentsAdultAges;

  /// No description provided for @dependentsChildAges.
  ///
  /// In en, this message translates to:
  /// **'Child ages'**
  String get dependentsChildAges;

  /// No description provided for @dependentsInfantAges.
  ///
  /// In en, this message translates to:
  /// **'Infant ages'**
  String get dependentsInfantAges;

  /// No description provided for @dependentsAgeField.
  ///
  /// In en, this message translates to:
  /// **'Age {index}'**
  String dependentsAgeField(int index);

  /// No description provided for @dependentsBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get dependentsBudget;

  /// No description provided for @dependentsCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get dependentsCity;

  /// No description provided for @dependentsDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get dependentsDuration;

  /// No description provided for @dependentsStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dependentsStart;

  /// No description provided for @dependentsEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get dependentsEnd;

  /// No description provided for @dependentsDefaultBudget.
  ///
  /// In en, this message translates to:
  /// **'21000 SAR'**
  String get dependentsDefaultBudget;

  /// No description provided for @dependentsDefaultDuration.
  ///
  /// In en, this message translates to:
  /// **'7 days & 6 nights'**
  String get dependentsDefaultDuration;

  /// No description provided for @dependentsDefaultStartDate.
  ///
  /// In en, this message translates to:
  /// **'1 Dec 2026'**
  String get dependentsDefaultStartDate;

  /// No description provided for @dependentsDefaultEndDate.
  ///
  /// In en, this message translates to:
  /// **'7 Dec 2026'**
  String get dependentsDefaultEndDate;

  /// No description provided for @cityRiyadh.
  ///
  /// In en, this message translates to:
  /// **'Riyadh'**
  String get cityRiyadh;

  /// No description provided for @cityJeddah.
  ///
  /// In en, this message translates to:
  /// **'Jeddah'**
  String get cityJeddah;

  /// No description provided for @cityMecca.
  ///
  /// In en, this message translates to:
  /// **'Mecca'**
  String get cityMecca;

  /// No description provided for @cityMedina.
  ///
  /// In en, this message translates to:
  /// **'Medina'**
  String get cityMedina;

  /// No description provided for @cityDammam.
  ///
  /// In en, this message translates to:
  /// **'Dammam'**
  String get cityDammam;

  /// No description provided for @cityKhobar.
  ///
  /// In en, this message translates to:
  /// **'Khobar'**
  String get cityKhobar;

  /// No description provided for @cityAbha.
  ///
  /// In en, this message translates to:
  /// **'Abha'**
  String get cityAbha;

  /// No description provided for @cityTaif.
  ///
  /// In en, this message translates to:
  /// **'Taif'**
  String get cityTaif;

  /// No description provided for @cityJazan.
  ///
  /// In en, this message translates to:
  /// **'Jazan'**
  String get cityJazan;

  /// No description provided for @dependentsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dependentsDone;

  /// No description provided for @dependentsGeneratingPlan.
  ///
  /// In en, this message translates to:
  /// **'Generating your trip plan... please wait.'**
  String get dependentsGeneratingPlan;

  /// No description provided for @dependentsGenerationComplete.
  ///
  /// In en, this message translates to:
  /// **'Trip generation complete! Check your new plans.'**
  String get dependentsGenerationComplete;

  /// No description provided for @dependentsAiLatencyWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: AI recommendation took {milliseconds} ms (target is 3000 ms).'**
  String dependentsAiLatencyWarning(Object milliseconds);

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

  /// No description provided for @forgotPasswordCta.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordCta;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get resetPasswordSend;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get resetPasswordSuccess;

  /// No description provided for @resetPasswordFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email.'**
  String get resetPasswordFailure;

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

  /// No description provided for @statusBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get statusBooked;

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
  /// **'Log out'**
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

  /// No description provided for @comparePlansCta.
  ///
  /// In en, this message translates to:
  /// **'Compare Plans'**
  String get comparePlansCta;

  /// No description provided for @comparePlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan comparison'**
  String get comparePlansTitle;

  /// No description provided for @compareKindLabel.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get compareKindLabel;

  /// No description provided for @compareHotelLabel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get compareHotelLabel;

  /// No description provided for @compareTotalCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get compareTotalCostLabel;

  /// No description provided for @compareNearbyLabel.
  ///
  /// In en, this message translates to:
  /// **'Nearby attractions'**
  String get compareNearbyLabel;

  /// No description provided for @compareDistantLabel.
  ///
  /// In en, this message translates to:
  /// **'Distant attractions'**
  String get compareDistantLabel;

  /// No description provided for @compareEventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get compareEventsLabel;

  /// No description provided for @selectPlanCta.
  ///
  /// In en, this message translates to:
  /// **'Select plan'**
  String get selectPlanCta;

  /// No description provided for @plansFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Relax Plan'**
  String get plansFamilyTitle;

  /// No description provided for @plansCulturalTitle.
  ///
  /// In en, this message translates to:
  /// **'Cultural Plan'**
  String get plansCulturalTitle;

  /// No description provided for @plansAdventureTitle.
  ///
  /// In en, this message translates to:
  /// **'Adventure Plan'**
  String get plansAdventureTitle;

  /// No description provided for @plansBudgetLowBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Note: Your budget (SAR {userBudget}) is low for this trip. We generated the cheapest plan at approx. SAR {minimumRequired}.'**
  String plansBudgetLowBannerMessage(Object userBudget, Object minimumRequired);

  /// No description provided for @plansDynamicEventPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Dynamic event suggestions'**
  String get plansDynamicEventPlaceholder;

  /// No description provided for @plansDynamicEventDescription.
  ///
  /// In en, this message translates to:
  /// **'Based on the selected coordinates'**
  String get plansDynamicEventDescription;

  /// No description provided for @profileAdminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get profileAdminDashboard;

  /// No description provided for @profileAdminUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get profileAdminUsers;

  /// No description provided for @profileAdminTripPlans.
  ///
  /// In en, this message translates to:
  /// **'Trip plans'**
  String get profileAdminTripPlans;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboardTitle;

  /// No description provided for @adminNoAccess.
  ///
  /// In en, this message translates to:
  /// **'You do not have admin access.'**
  String get adminNoAccess;

  /// No description provided for @adminBackToProfile.
  ///
  /// In en, this message translates to:
  /// **'Back to profile'**
  String get adminBackToProfile;

  /// No description provided for @adminStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard stats'**
  String get adminStatsTitle;

  /// No description provided for @adminStatHotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get adminStatHotels;

  /// No description provided for @adminStatActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get adminStatActivities;

  /// No description provided for @adminStatBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get adminStatBookings;

  /// No description provided for @adminContentManagement.
  ///
  /// In en, this message translates to:
  /// **'Content Management'**
  String get adminContentManagement;

  /// No description provided for @adminManageContent.
  ///
  /// In en, this message translates to:
  /// **'Manage Content'**
  String get adminManageContent;

  /// No description provided for @adminManageContentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, edit, and delete hotels and activities.'**
  String get adminManageContentSubtitle;

  /// No description provided for @adminManageHotelsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, update, and remove hotel records.'**
  String get adminManageHotelsSubtitle;

  /// No description provided for @adminManageActivitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, update, and remove activity records.'**
  String get adminManageActivitiesSubtitle;

  /// No description provided for @adminManageEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, update, and remove event records.'**
  String get adminManageEventsSubtitle;

  /// No description provided for @adminViewBookings.
  ///
  /// In en, this message translates to:
  /// **'View User Bookings'**
  String get adminViewBookings;

  /// No description provided for @adminViewBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open bookings list to verify saved reservations.'**
  String get adminViewBookingsSubtitle;

  /// No description provided for @adminManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Content'**
  String get adminManageTitle;

  /// No description provided for @adminManageOnlyAdmins.
  ///
  /// In en, this message translates to:
  /// **'Only admins can access content management.'**
  String get adminManageOnlyAdmins;

  /// No description provided for @adminTabHotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get adminTabHotels;

  /// No description provided for @adminTabActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get adminTabActivities;

  /// No description provided for @adminAddHotel.
  ///
  /// In en, this message translates to:
  /// **'Add hotel'**
  String get adminAddHotel;

  /// No description provided for @adminAddActivity.
  ///
  /// In en, this message translates to:
  /// **'Add activity'**
  String get adminAddActivity;

  /// No description provided for @adminAddContent.
  ///
  /// In en, this message translates to:
  /// **'Add content'**
  String get adminAddContent;

  /// No description provided for @adminEditContent.
  ///
  /// In en, this message translates to:
  /// **'Edit content'**
  String get adminEditContent;

  /// No description provided for @adminLabelNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get adminLabelNameRequired;

  /// No description provided for @adminNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get adminNameRequiredError;

  /// No description provided for @adminLabelLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get adminLabelLocation;

  /// No description provided for @adminLabelCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get adminLabelCity;

  /// No description provided for @adminLabelRating.
  ///
  /// In en, this message translates to:
  /// **'Rating (0-5)'**
  String get adminLabelRating;

  /// No description provided for @adminLabelPricePerNight.
  ///
  /// In en, this message translates to:
  /// **'Price per night'**
  String get adminLabelPricePerNight;

  /// No description provided for @adminLabelPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get adminLabelPrice;

  /// No description provided for @adminLabelPlanType.
  ///
  /// In en, this message translates to:
  /// **'Plan type (e.g. family)'**
  String get adminLabelPlanType;

  /// No description provided for @adminLabelOpenHours.
  ///
  /// In en, this message translates to:
  /// **'Open hours'**
  String get adminLabelOpenHours;

  /// No description provided for @adminLabelCloseHours.
  ///
  /// In en, this message translates to:
  /// **'Close hours'**
  String get adminLabelCloseHours;

  /// No description provided for @adminLabelBookingUrl.
  ///
  /// In en, this message translates to:
  /// **'Booking URL'**
  String get adminLabelBookingUrl;

  /// No description provided for @adminLabelMapsUrl.
  ///
  /// In en, this message translates to:
  /// **'Maps URL'**
  String get adminLabelMapsUrl;

  /// No description provided for @adminAddLocation.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get adminAddLocation;

  /// No description provided for @adminLocationPickHint.
  ///
  /// In en, this message translates to:
  /// **'Use the button below to pick the location from Google Maps.'**
  String get adminLocationPickHint;

  /// No description provided for @adminLocationRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please pick the location from Google Maps.'**
  String get adminLocationRequiredError;

  /// No description provided for @adminSelectCityError.
  ///
  /// In en, this message translates to:
  /// **'Please select a city.'**
  String get adminSelectCityError;

  /// No description provided for @adminSelectRatingError.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating.'**
  String get adminSelectRatingError;

  /// No description provided for @adminSelectCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Please select a category.'**
  String get adminSelectCategoryError;

  /// No description provided for @adminCategoryFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get adminCategoryFamily;

  /// No description provided for @adminCategoryCultural.
  ///
  /// In en, this message translates to:
  /// **'Cultural'**
  String get adminCategoryCultural;

  /// No description provided for @adminCategoryAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get adminCategoryAdventure;

  /// No description provided for @adminCategoryNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get adminCategoryNature;

  /// No description provided for @adminCategoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get adminCategoryEntertainment;

  /// No description provided for @adminDatePickerHint.
  ///
  /// In en, this message translates to:
  /// **'No date selected yet.'**
  String get adminDatePickerHint;

  /// No description provided for @adminPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get adminPickDate;

  /// No description provided for @adminDateRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please pick a date.'**
  String get adminDateRequiredError;

  /// No description provided for @adminNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminNavDashboard;

  /// No description provided for @adminNavHotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get adminNavHotels;

  /// No description provided for @adminNavActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get adminNavActivities;

  /// No description provided for @adminNavEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get adminNavEvents;

  /// No description provided for @adminNavBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get adminNavBookings;

  /// No description provided for @adminNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get adminNavSettings;

  /// No description provided for @adminSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Settings'**
  String get adminSettingsTitle;

  /// No description provided for @adminSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your admin account and app preferences.'**
  String get adminSettingsSubtitle;

  /// No description provided for @adminSettingsGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open user guide instructions.'**
  String get adminSettingsGuideSubtitle;

  /// No description provided for @adminSettingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the privacy policy page.'**
  String get adminSettingsPrivacySubtitle;

  /// No description provided for @adminLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out from the admin session?'**
  String get adminLogoutConfirm;

  /// No description provided for @adminAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get adminAnalyticsTitle;

  /// No description provided for @adminAnalyticsBookingStatus.
  ///
  /// In en, this message translates to:
  /// **'Booking status distribution'**
  String get adminAnalyticsBookingStatus;

  /// No description provided for @adminAnalyticsTopCities.
  ///
  /// In en, this message translates to:
  /// **'Top destination cities'**
  String get adminAnalyticsTopCities;

  /// No description provided for @adminAnalyticsSelectedPlans.
  ///
  /// In en, this message translates to:
  /// **'Selected plan insights'**
  String get adminAnalyticsSelectedPlans;

  /// No description provided for @adminAnalyticsSelectedPlansCount.
  ///
  /// In en, this message translates to:
  /// **'Selected plans: {count}'**
  String adminAnalyticsSelectedPlansCount(int count);

  /// No description provided for @adminAnalyticsAiPerformance.
  ///
  /// In en, this message translates to:
  /// **'AI response performance'**
  String get adminAnalyticsAiPerformance;

  /// No description provided for @adminAnalyticsAverageLatency.
  ///
  /// In en, this message translates to:
  /// **'Average AI latency: {milliseconds} ms'**
  String adminAnalyticsAverageLatency(Object milliseconds);

  /// No description provided for @adminAnalyticsSlowResponses.
  ///
  /// In en, this message translates to:
  /// **'Responses above 3000 ms: {count}'**
  String adminAnalyticsSlowResponses(int count);

  /// No description provided for @adminAnalyticsHighLatencyNote.
  ///
  /// In en, this message translates to:
  /// **'Target response time is 3000 ms or less.'**
  String get adminAnalyticsHighLatencyNote;

  /// No description provided for @adminStatusOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get adminStatusOther;

  /// No description provided for @adminNoAnalyticsData.
  ///
  /// In en, this message translates to:
  /// **'No analytics data yet.'**
  String get adminNoAnalyticsData;

  /// No description provided for @adminMapPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick location from map'**
  String get adminMapPickerTitle;

  /// No description provided for @adminMapTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to drop a marker on the location.'**
  String get adminMapTapHint;

  /// No description provided for @adminMapConfirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get adminMapConfirmLocation;

  /// No description provided for @adminMapPickFirst.
  ///
  /// In en, this message translates to:
  /// **'Please pick a point on the map first.'**
  String get adminMapPickFirst;

  /// No description provided for @adminMapFallbackNotice.
  ///
  /// In en, this message translates to:
  /// **'Google Maps is unavailable on this device; using the built-in map picker.'**
  String get adminMapFallbackNotice;

  /// No description provided for @adminDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get adminDeleteTitle;

  /// No description provided for @adminDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get adminDeleteConfirm;

  /// No description provided for @adminSaveAdded.
  ///
  /// In en, this message translates to:
  /// **'{collection} item added successfully.'**
  String adminSaveAdded(Object collection);

  /// No description provided for @adminSaveUpdated.
  ///
  /// In en, this message translates to:
  /// **'{collection} item updated successfully.'**
  String adminSaveUpdated(Object collection);

  /// No description provided for @adminSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save item: {details}'**
  String adminSaveFailed(Object details);

  /// No description provided for @adminDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'{collection} item deleted.'**
  String adminDeleteSuccess(Object collection);

  /// No description provided for @adminDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {details}'**
  String adminDeleteFailed(Object details);

  /// No description provided for @adminLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading {collection}.'**
  String adminLoadError(Object collection);

  /// No description provided for @adminNoRecords.
  ///
  /// In en, this message translates to:
  /// **'No records in {collection} yet.'**
  String adminNoRecords(Object collection);

  /// No description provided for @adminNoExtraDetails.
  ///
  /// In en, this message translates to:
  /// **'No extra details'**
  String get adminNoExtraDetails;

  /// No description provided for @adminUnknownName.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get adminUnknownName;

  /// No description provided for @adminLocationValue.
  ///
  /// In en, this message translates to:
  /// **'Location: {value}'**
  String adminLocationValue(Object value);

  /// No description provided for @adminPriceValue.
  ///
  /// In en, this message translates to:
  /// **'Price: {value}'**
  String adminPriceValue(Object value);

  /// No description provided for @adminRatingValue.
  ///
  /// In en, this message translates to:
  /// **'Rating: {value}'**
  String adminRatingValue(Object value);

  /// No description provided for @adminPerNightSuffix.
  ///
  /// In en, this message translates to:
  /// **' /night'**
  String get adminPerNightSuffix;

  /// No description provided for @adminTooltipEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminTooltipEdit;

  /// No description provided for @adminTooltipDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminTooltipDelete;

  /// No description provided for @dependentsAiLatencyExceeded.
  ///
  /// In en, this message translates to:
  /// **'AI response took {milliseconds} ms. This exceeds the 3000 ms limit, so the plan was not saved. Please retry.'**
  String dependentsAiLatencyExceeded(Object milliseconds);

  /// No description provided for @settingsUserGuide.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get settingsUserGuide;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get helpTitle;

  /// No description provided for @helpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simple steps to plan a family trip'**
  String get helpSubtitle;

  /// No description provided for @helpStep1.
  ///
  /// In en, this message translates to:
  /// **'1) Enter family size and ages.'**
  String get helpStep1;

  /// No description provided for @helpStep2.
  ///
  /// In en, this message translates to:
  /// **'2) Set budget, city, and trip duration.'**
  String get helpStep2;

  /// No description provided for @helpStep3.
  ///
  /// In en, this message translates to:
  /// **'3) Generate plans and compare them.'**
  String get helpStep3;

  /// No description provided for @helpStep4.
  ///
  /// In en, this message translates to:
  /// **'4) Open maps or booking links when available.'**
  String get helpStep4;

  /// No description provided for @helpStep5.
  ///
  /// In en, this message translates to:
  /// **'5) Save your plan and view it later.'**
  String get helpStep5;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Data We Collect'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Body.
  ///
  /// In en, this message translates to:
  /// **'We collect account information (name, email), family trip inputs, generated plans, and booking logs needed to provide the service.'**
  String get privacySection1Body;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Why We Use Data'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Body.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to generate personalized trip plans, show plan history, and provide booking confirmations.'**
  String get privacySection2Body;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Storage and Security'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Body.
  ///
  /// In en, this message translates to:
  /// **'Data is stored in Firebase services with authenticated access controls. Passwords are handled by Firebase Authentication and are not stored in plain text by the app.'**
  String get privacySection3Body;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Booking and External Links'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Body.
  ///
  /// In en, this message translates to:
  /// **'Bookings may open external providers or maps links. Payments, if any, are completed outside this application.'**
  String get privacySection4Body;

  /// No description provided for @privacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Your Controls'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Body.
  ///
  /// In en, this message translates to:
  /// **'You can edit profile data, update trip preferences, and request account deletion from the account screen.'**
  String get privacySection5Body;

  /// No description provided for @privacySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Contact and Updates'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Body.
  ///
  /// In en, this message translates to:
  /// **'This policy can be updated with new app releases. Continued use means acceptance of the latest policy.'**
  String get privacySection6Body;

  /// No description provided for @bookingsReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Receipt'**
  String get bookingsReceiptTitle;

  /// No description provided for @bookingsReceiptId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get bookingsReceiptId;

  /// No description provided for @bookingsReceiptReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get bookingsReceiptReference;

  /// No description provided for @bookingsReceiptItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get bookingsReceiptItem;

  /// No description provided for @bookingsReceiptType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get bookingsReceiptType;

  /// No description provided for @bookingsReceiptStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get bookingsReceiptStatus;

  /// No description provided for @bookingsReceiptDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get bookingsReceiptDate;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @bookingViewBookings.
  ///
  /// In en, this message translates to:
  /// **'View bookings'**
  String get bookingViewBookings;

  /// No description provided for @bookingConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bookingConfirmedTitle;

  /// No description provided for @bookingConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'Your reservation has been recorded successfully.'**
  String get bookingConfirmedBody;

  /// No description provided for @bookingSuccessDefaultItemType.
  ///
  /// In en, this message translates to:
  /// **'Attraction'**
  String get bookingSuccessDefaultItemType;

  /// No description provided for @bookingSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get bookingSuccessTitle;

  /// No description provided for @bookingSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'{itemType} has been successfully booked.'**
  String bookingSuccessBody(Object itemType);

  /// No description provided for @bookingSuccessViewAllPrompt.
  ///
  /// In en, this message translates to:
  /// **'Want to see all your {itemType}? '**
  String bookingSuccessViewAllPrompt(Object itemType);

  /// No description provided for @bookingSuccessClickHere.
  ///
  /// In en, this message translates to:
  /// **'Click here.'**
  String get bookingSuccessClickHere;

  /// No description provided for @bookingSuccessBackToPlan.
  ///
  /// In en, this message translates to:
  /// **'Back to plan'**
  String get bookingSuccessBackToPlan;

  /// No description provided for @bookingPlanUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This booking cannot be saved because the selected plan is missing.'**
  String get bookingPlanUnavailable;

  /// No description provided for @plansGeneratedPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Generated Plan'**
  String get plansGeneratedPlanTitle;

  /// No description provided for @plansGeneratedDynamically.
  ///
  /// In en, this message translates to:
  /// **'Generated dynamically'**
  String get plansGeneratedDynamically;

  /// No description provided for @plansDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String plansDurationValue(int days);

  /// No description provided for @plansDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String plansDayLabel(int day);

  /// No description provided for @plansPricePerNight.
  ///
  /// In en, this message translates to:
  /// **'{amount} SAR/night'**
  String plansPricePerNight(Object amount);

  /// No description provided for @plansTotalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total {amount} SAR'**
  String plansTotalPrice(Object amount);

  /// No description provided for @plansTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get plansTimeLabel;

  /// No description provided for @plansDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get plansDescriptionLabel;

  /// No description provided for @plansNoGeneratedPlans.
  ///
  /// In en, this message translates to:
  /// **'No generated plans found in database.'**
  String get plansNoGeneratedPlans;

  /// No description provided for @plansGenerateNewPlan.
  ///
  /// In en, this message translates to:
  /// **'Generate a new plan'**
  String get plansGenerateNewPlan;

  /// No description provided for @plansSelectFavoriteHeader.
  ///
  /// In en, this message translates to:
  /// **'Select your favorite plan:'**
  String get plansSelectFavoriteHeader;

  /// No description provided for @plansSaveSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not save selected plan: {details}'**
  String plansSaveSelectionError(Object details);

  /// No description provided for @plansLabelSelectedCity.
  ///
  /// In en, this message translates to:
  /// **'Selected city'**
  String get plansLabelSelectedCity;

  /// No description provided for @plansLabelDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get plansLabelDates;

  /// No description provided for @plansLabelTripDuration.
  ///
  /// In en, this message translates to:
  /// **'Trip duration'**
  String get plansLabelTripDuration;

  /// No description provided for @plansLabelHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get plansLabelHotel;

  /// No description provided for @plansLabelNearbyAttractions.
  ///
  /// In en, this message translates to:
  /// **'Nearby attractions'**
  String get plansLabelNearbyAttractions;

  /// No description provided for @plansLabelDistantAttractions.
  ///
  /// In en, this message translates to:
  /// **'Distant attractions'**
  String get plansLabelDistantAttractions;

  /// No description provided for @plansLabelEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get plansLabelEvents;

  /// No description provided for @plansLabelTotalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total budget for this plan'**
  String get plansLabelTotalBudget;

  /// No description provided for @plansTableDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get plansTableDays;

  /// No description provided for @plansTableMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get plansTableMorning;

  /// No description provided for @plansTableAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get plansTableAfternoon;

  /// No description provided for @plansTableEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get plansTableEvening;

  /// No description provided for @actionOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get actionOpenInMaps;

  /// No description provided for @actionBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get actionBookNow;

  /// No description provided for @planDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} details'**
  String planDetailTitle(Object title);

  /// No description provided for @planDetailHotelSection.
  ///
  /// In en, this message translates to:
  /// **'Hotel information'**
  String get planDetailHotelSection;

  /// No description provided for @planDetailLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get planDetailLocationLabel;

  /// No description provided for @planDetailPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get planDetailPriceLabel;

  /// No description provided for @planDetailRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get planDetailRatingLabel;

  /// No description provided for @planDetailAmenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get planDetailAmenities;

  /// No description provided for @planDetailWhyPlan.
  ///
  /// In en, this message translates to:
  /// **'Why this plan'**
  String get planDetailWhyPlan;

  /// No description provided for @planDetailWhyHotel.
  ///
  /// In en, this message translates to:
  /// **'Why this hotel'**
  String get planDetailWhyHotel;

  /// No description provided for @planDetailSelectHotelHint.
  ///
  /// In en, this message translates to:
  /// **'Switch between the recommended hotels'**
  String get planDetailSelectHotelHint;

  /// No description provided for @planDetailPreviousHotel.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get planDetailPreviousHotel;

  /// No description provided for @planDetailNextHotel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get planDetailNextHotel;

  /// No description provided for @planDetailHotelPosition.
  ///
  /// In en, this message translates to:
  /// **'Hotel {current} of {total}'**
  String planDetailHotelPosition(int current, int total);

  /// No description provided for @planDetailOpenClose.
  ///
  /// In en, this message translates to:
  /// **'Open | Close'**
  String get planDetailOpenClose;

  /// No description provided for @planDetailDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get planDetailDistance;

  /// No description provided for @planDetailTourGuideSection.
  ///
  /// In en, this message translates to:
  /// **'Tour Guide'**
  String get planDetailTourGuideSection;

  /// No description provided for @planDetailShareSummary.
  ///
  /// In en, this message translates to:
  /// **'Share summary'**
  String get planDetailShareSummary;

  /// No description provided for @planDetailShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share the plan summary.'**
  String get planDetailShareFailed;

  /// No description provided for @planDetailPdfPreview.
  ///
  /// In en, this message translates to:
  /// **'PDF preview'**
  String get planDetailPdfPreview;

  /// No description provided for @planDetailDayRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Route for {day}'**
  String planDetailDayRouteTitle(Object day);

  /// No description provided for @planDetailRouteStops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get planDetailRouteStops;

  /// No description provided for @planDetailOpenRoute.
  ///
  /// In en, this message translates to:
  /// **'Open route'**
  String get planDetailOpenRoute;

  /// No description provided for @planDetailNoRoutePreview.
  ///
  /// In en, this message translates to:
  /// **'Map preview is not available for this day.'**
  String get planDetailNoRoutePreview;

  /// No description provided for @planDetailNavigateToPlace.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Place'**
  String get planDetailNavigateToPlace;

  /// No description provided for @planDetailBookHotelViaMaps.
  ///
  /// In en, this message translates to:
  /// **'Book Hotel via Maps'**
  String get planDetailBookHotelViaMaps;

  /// No description provided for @bookingLoginRequiredSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Please log in. Booking was not saved.'**
  String get bookingLoginRequiredSaveFailed;

  /// No description provided for @planDetailNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events available.'**
  String get planDetailNoEvents;

  /// No description provided for @planDetailNoActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities available.'**
  String get planDetailNoActivities;

  /// No description provided for @planDetailHotelItemType.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get planDetailHotelItemType;

  /// No description provided for @planDetailActivityItemType.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get planDetailActivityItemType;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nFATRIPY'**
  String get homeWelcomeTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Saudi cities,\none trip at a time'**
  String get homeHeroSubtitle;

  /// No description provided for @homeMainDestination.
  ///
  /// In en, this message translates to:
  /// **'Explore Cities'**
  String get homeMainDestination;

  /// No description provided for @homeSeasonalAttractions.
  ///
  /// In en, this message translates to:
  /// **'Trip Styles'**
  String get homeSeasonalAttractions;

  /// No description provided for @homeDestination1Title.
  ///
  /// In en, this message translates to:
  /// **'Cultural Discovery'**
  String get homeDestination1Title;

  /// No description provided for @homeDestination1Description.
  ///
  /// In en, this message translates to:
  /// **'Historic districts, museums, and heritage landmarks for curious travelers.'**
  String get homeDestination1Description;

  /// No description provided for @homeDestination2Title.
  ///
  /// In en, this message translates to:
  /// **'Coastal Escapes'**
  String get homeDestination2Title;

  /// No description provided for @homeDestination2Description.
  ///
  /// In en, this message translates to:
  /// **'Seafront walks, island vibes, and family-friendly waterfront experiences.'**
  String get homeDestination2Description;

  /// No description provided for @homeDestination3Title.
  ///
  /// In en, this message translates to:
  /// **'Mountain Nature'**
  String get homeDestination3Title;

  /// No description provided for @homeDestination3Description.
  ///
  /// In en, this message translates to:
  /// **'Cool weather, scenic heights, and nature-driven moments across the Kingdom.'**
  String get homeDestination3Description;

  /// No description provided for @homeSeason1Title.
  ///
  /// In en, this message translates to:
  /// **'Family Friendly'**
  String get homeSeason1Title;

  /// No description provided for @homeSeason1Description.
  ///
  /// In en, this message translates to:
  /// **'Balanced plans with comfortable pacing for all family members.'**
  String get homeSeason1Description;

  /// No description provided for @homeSeason2Title.
  ///
  /// In en, this message translates to:
  /// **'Adventure & Outdoors'**
  String get homeSeason2Title;

  /// No description provided for @homeSeason2Description.
  ///
  /// In en, this message translates to:
  /// **'Action-filled itineraries with trails, viewpoints, and active attractions.'**
  String get homeSeason2Description;

  /// No description provided for @homeSeason3Title.
  ///
  /// In en, this message translates to:
  /// **'Relax & Leisure'**
  String get homeSeason3Title;

  /// No description provided for @homeSeason3Description.
  ///
  /// In en, this message translates to:
  /// **'Calm stays, scenic dining, and smooth city experiences.'**
  String get homeSeason3Description;

  /// No description provided for @homeCityCardHint.
  ///
  /// In en, this message translates to:
  /// **'Hotels, activities, and events available'**
  String get homeCityCardHint;

  /// No description provided for @blogTitle.
  ///
  /// In en, this message translates to:
  /// **'BLOG'**
  String get blogTitle;

  /// No description provided for @blogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All supported cities in FATRIPY'**
  String get blogSubtitle;

  /// No description provided for @blogFutureNotice.
  ///
  /// In en, this message translates to:
  /// **'More city content is coming soon.'**
  String get blogFutureNotice;

  /// No description provided for @blogRiyadhDescription.
  ///
  /// In en, this message translates to:
  /// **'Riyadh is located in the heart of the Kingdom on the Najd plateau, and it is the capital and largest city of Saudi Arabia. It is distinguished by a rich Najdi heritage visible in Masmak Palace and the historic Diriyah, which is registered with UNESCO and where the Saudi state began. Today, Riyadh is known for its unique blend of past and modernity, from its famous towers such as the Kingdom Tower and Al Faisaliah Tower to its museums and traditional markets, making it a center for culture, economy, and contemporary life.'**
  String get blogRiyadhDescription;

  /// No description provided for @blogJeddahDescription.
  ///
  /// In en, this message translates to:
  /// **'Jeddah is located in the west of the Kingdom on the Red Sea coast and is known as the gateway to the Two Holy Mosques. Historic Jeddah (Al-Balad) is one of its most prominent heritage sites, containing over 600 heritage buildings and old houses such as Nassif House, and it is registered as a UNESCO site. Jeddah is famous for its maritime spirit, its long corniche, and its cultural diversity, making it a city that combines tradition, modernity, and coastal life.'**
  String get blogJeddahDescription;

  /// No description provided for @blogMeccaDescription.
  ///
  /// In en, this message translates to:
  /// **'Mecca is located in the western region of Saudi Arabia and is the holiest city in Islam. It is home to Al-Masjid Al-Haram and the Kaaba, the direction Muslims face during their daily prayers. The city holds immense religious significance and welcomes millions of Muslims every year who come to perform Hajj and Umrah. Mecca combines deep spiritual heritage with modern urban development, making it one of the most important religious and cultural centers in the Islamic world.'**
  String get blogMeccaDescription;

  /// No description provided for @blogMadinahTitle.
  ///
  /// In en, this message translates to:
  /// **'Madinah'**
  String get blogMadinahTitle;

  /// No description provided for @blogMadinahDescription.
  ///
  /// In en, this message translates to:
  /// **'Madinah is located in the western region of Saudi Arabia and is one of the holiest cities in Islam. It is home to Al-Masjid An-Nabawi, the Prophet’s Mosque, and holds a special place in Islamic history. The city is known for its spiritual atmosphere, rich heritage, and important religious landmarks. Madinah also combines historical significance with modern urban development, making it a unique religious and cultural destination.'**
  String get blogMadinahDescription;

  /// No description provided for @blogDammamDescription.
  ///
  /// In en, this message translates to:
  /// **'Dammam is located in the Eastern Province of Saudi Arabia and is one of the Kingdom’s major coastal cities overlooking the Arabian Gulf. It is known for its beautiful waterfront, lively atmosphere, and strong economic importance. As a key center for business, trade, and industry, Dammam combines modern urban living with attractive leisure destinations, making it a notable city for both residents and visitors.'**
  String get blogDammamDescription;

  /// No description provided for @blogAbhaDescription.
  ///
  /// In en, this message translates to:
  /// **'Abha is located in the Asir region in southwestern Saudi Arabia and is famous for its stunning mountain landscapes and mild weather throughout the year. The city is known for its natural beauty, green parks, and cultural heritage, making it one of the Kingdom’s most attractive destinations for nature lovers and tourists. Abha offers a unique experience that blends scenic charm with rich local identity and tradition.'**
  String get blogAbhaDescription;

  /// No description provided for @blogTaifDescription.
  ///
  /// In en, this message translates to:
  /// **'Taif is located in the western region of Saudi Arabia and is well known for its pleasant weather, mountain scenery, and fragrant roses. It is considered one of the Kingdom’s top summer destinations thanks to its beautiful highlands, traditional markets, and diverse natural attractions. Taif combines historical charm with modern development, offering visitors a relaxing and memorable experience.'**
  String get blogTaifDescription;

  /// No description provided for @blogCityGenericDescription.
  ///
  /// In en, this message translates to:
  /// **'{city} is available in FATRIPY with city-based planning for hotels, activities, and events.'**
  String blogCityGenericDescription(Object city);

  /// No description provided for @blogCityJazan.
  ///
  /// In en, this message translates to:
  /// **'Jazan'**
  String get blogCityJazan;

  /// No description provided for @blogJazanDescription.
  ///
  /// In en, this message translates to:
  /// **'Jazan is located in the far southwest of the Kingdom on the Red Sea coast and is distinguished by a great natural diversity, from the green Faifa mountains to the enchanting Farasan Islands. It has an ancient history reflected in archaeological sites that span thousands of years and the Dawsari Castle. Jazan is famous for its popular heritage, such as the Jazan dance (Ardah), for growing coffee and bananas, and for its warm climate and the authentic culture of its people.'**
  String get blogJazanDescription;

  /// No description provided for @blogCityAlKhobar.
  ///
  /// In en, this message translates to:
  /// **'Al Khobar'**
  String get blogCityAlKhobar;

  /// No description provided for @blogAlKhobarDescription.
  ///
  /// In en, this message translates to:
  /// **'Al Khobar is located in the eastern part of the Kingdom on the Arabian Gulf coast, about 17 km south of Dammam. It flourished after the discovery of oil and has become one of the most beautiful cities in the Eastern Province. It is famous for the long Al Khobar Corniche, the modern waterfront, and the King Fahd Bridge that connects Saudi Arabia to Bahrain. Al Khobar is characterized by its modern style, upscale markets, cafes, and parks, making it a distinctive tourist and urban destination.'**
  String get blogAlKhobarDescription;
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
