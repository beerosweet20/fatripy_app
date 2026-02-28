// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Fatripy';

  @override
  String get navHome => 'Home';

  @override
  String get navPlans => 'Plans';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navProfile => 'Profile';

  @override
  String get loginWelcome => 'Welcome!';

  @override
  String get labelEmail => 'Email';

  @override
  String get labelPassword => 'Password';

  @override
  String get actionLogin => 'Login';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get actionRegister => 'Register';

  @override
  String get registerTitle => 'Please fill out the form to register';

  @override
  String get labelFullName => 'Full name';

  @override
  String get labelUsername => 'Username';

  @override
  String get labelConfirmPassword => 'Confirm password';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get errorFillAllFields => 'Please fill in all fields.';

  @override
  String get errorLoginFailed => 'Login failed. Please try again.';

  @override
  String get errorGeneric => 'An error occurred. Please try again.';

  @override
  String get errorUsernameNoSpaces => 'Username cannot contain spaces.';

  @override
  String get errorPasswordTooShort => 'Password must be at least 6 characters.';

  @override
  String get errorPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get errorUsernameTaken => 'Username already taken.';

  @override
  String get errorRegistrationFailed =>
      'Registration failed. Please try again.';

  @override
  String homeGreetingName(Object name) {
    return 'Hello, $name!';
  }

  @override
  String get homeFriendName => 'friend';

  @override
  String get homeSubtitle => 'Let\'s plan your next family trip';

  @override
  String familyCountLabel(int count) {
    return 'Family members: $count';
  }

  @override
  String get familyManagement => 'Family management';

  @override
  String get startPlanning => 'Start planning';

  @override
  String get homeAiTeaser => 'Smart planning builds your family trip';

  @override
  String get latestPlans => 'Latest plans';

  @override
  String get recentBookings => 'Recent bookings';

  @override
  String get createPlan => 'Create plan';

  @override
  String get emptyPlans => 'No plans yet.';

  @override
  String get seeAll => 'See all';

  @override
  String get errorPleaseLogin => 'Please log in to continue.';

  @override
  String errorWithDetails(Object details) {
    return 'Error: $details';
  }

  @override
  String planSummary(int days, Object budget) {
    return '$days days • $budget SAR';
  }

  @override
  String get bookingsLoadError => 'Error loading bookings.';

  @override
  String get bookingsEmpty => 'No bookings yet.';

  @override
  String bookingItemTitle(Object itemType) {
    return 'Booking: $itemType';
  }

  @override
  String bookingPlacedOn(Object date) {
    return 'Date: $date';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String planListSubtitle(Object budget, Object status) {
    return 'Budget: $budget • $status';
  }

  @override
  String bookingListSubtitle(Object status, Object date) {
    return 'Status: $status • Placed: $date';
  }

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get debugExplorer => 'Data Explorer (Debug)';

  @override
  String get hotelsTitle => 'Hotels';

  @override
  String get hotelsLoadError => 'Error loading data.';

  @override
  String get hotelsNoData => 'No data available.';

  @override
  String get hotelsEmpty => 'No hotels to show.';

  @override
  String get hotelNameUnknown => 'Unknown hotel';

  @override
  String get hotelLocationUnknown => 'Unknown location';
}
