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
  String get navBlog => 'Blog';

  @override
  String get navLogin => 'Log in';

  @override
  String get navShop => 'Shop';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navHome => 'Home';

  @override
  String get navPlans => 'Plans';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navCart => 'Cart';

  @override
  String get navProfile => 'Profile';

  @override
  String get navAccount => 'Account';

  @override
  String get loading => 'Loading...';

  @override
  String get accountTitle => 'My Account';

  @override
  String get accountNotifications => 'Notifications';

  @override
  String get accountDependents => 'Dependents';

  @override
  String get accountSettingsPrivacy => 'Setting&Privacy';

  @override
  String get accountBookedAttraction => 'Booked Attraction';

  @override
  String get accountDeleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account?';

  @override
  String get deleteAccountSuccess => 'Account deleted.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionSave => 'Save';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsEditProfile => 'Edit Profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get themeDefault => 'Default';

  @override
  String get themePink => 'Pink';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileName => 'Full name';

  @override
  String get editProfileEmail => 'Email';

  @override
  String get editProfileEmailHint => 'Updating email may require recent login';

  @override
  String get editProfileSuccess => 'Profile updated.';

  @override
  String get editProfileReauth => 'Please log in again to update your email.';

  @override
  String get dependentsTitle => 'Write Your Information';

  @override
  String get dependentsMyFamily => 'My Family';

  @override
  String get dependentsTripInfo => 'Trip info';

  @override
  String get dependentsAdults => 'Adults';

  @override
  String get dependentsChildren => 'Children';

  @override
  String get dependentsInfant => 'INFANT';

  @override
  String get dependentsAdultAges => 'Adult ages';

  @override
  String get dependentsChildAges => 'Child ages';

  @override
  String get dependentsInfantAges => 'Infant ages';

  @override
  String dependentsAgeField(int index) {
    return 'Age $index';
  }

  @override
  String get dependentsBudget => 'Budget';

  @override
  String get dependentsCity => 'City';

  @override
  String get dependentsDuration => 'Duration';

  @override
  String get dependentsStart => 'Start';

  @override
  String get dependentsEnd => 'End';

  @override
  String get dependentsDefaultBudget => '21000 SAR';

  @override
  String get dependentsDefaultDuration => '7 days & 6 nights';

  @override
  String get dependentsDefaultStartDate => '1 Dec 2026';

  @override
  String get dependentsDefaultEndDate => '7 Dec 2026';

  @override
  String get cityRiyadh => 'Riyadh';

  @override
  String get cityJeddah => 'Jeddah';

  @override
  String get cityMecca => 'Mecca';

  @override
  String get cityMedina => 'Medina';

  @override
  String get cityDammam => 'Dammam';

  @override
  String get cityKhobar => 'Khobar';

  @override
  String get cityAbha => 'Abha';

  @override
  String get cityTaif => 'Taif';

  @override
  String get cityJazan => 'Jazan';

  @override
  String get dependentsDone => 'Done';

  @override
  String get dependentsGeneratingPlan =>
      'Generating your trip plan... please wait.';

  @override
  String get dependentsGenerationComplete =>
      'Trip generation complete! Check your new plans.';

  @override
  String dependentsAiLatencyWarning(Object milliseconds) {
    return 'Warning: AI recommendation took $milliseconds ms (target is 3000 ms).';
  }

  @override
  String get loginWelcome => 'Welcome!';

  @override
  String get labelEmail => 'Email';

  @override
  String get labelPassword => 'Password';

  @override
  String get actionLogin => 'Login';

  @override
  String get forgotPasswordCta => 'Forgot password?';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordSend => 'Send';

  @override
  String get resetPasswordSuccess => 'Password reset email sent.';

  @override
  String get resetPasswordFailure => 'Failed to send reset email.';

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
  String get statusBooked => 'Booked';

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
  String get logout => 'Log out';

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

  @override
  String get comparePlansCta => 'Compare Plans';

  @override
  String get comparePlansTitle => 'Plan comparison';

  @override
  String get compareKindLabel => 'Kind';

  @override
  String get compareHotelLabel => 'Hotel';

  @override
  String get compareTotalCostLabel => 'Total cost';

  @override
  String get compareNearbyLabel => 'Nearby attractions';

  @override
  String get compareDistantLabel => 'Distant attractions';

  @override
  String get compareEventsLabel => 'Events';

  @override
  String get selectPlanCta => 'Select plan';

  @override
  String get plansFamilyTitle => 'Family Relax Plan';

  @override
  String get plansCulturalTitle => 'Cultural Plan';

  @override
  String get plansAdventureTitle => 'Adventure Plan';

  @override
  String plansBudgetLowBannerMessage(
    Object userBudget,
    Object minimumRequired,
  ) {
    return 'Note: Your budget (SAR $userBudget) is low for this trip. We generated the cheapest plan at approx. SAR $minimumRequired.';
  }

  @override
  String get plansDynamicEventPlaceholder => 'Dynamic event suggestions';

  @override
  String get plansDynamicEventDescription =>
      'Based on the selected coordinates';

  @override
  String get profileAdminDashboard => 'Admin Dashboard';

  @override
  String get profileAdminUsers => 'Users';

  @override
  String get profileAdminTripPlans => 'Trip plans';

  @override
  String get adminDashboardTitle => 'Admin Dashboard';

  @override
  String get adminNoAccess => 'You do not have admin access.';

  @override
  String get adminBackToProfile => 'Back to profile';

  @override
  String get adminStatsTitle => 'Dashboard stats';

  @override
  String get adminStatHotels => 'Hotels';

  @override
  String get adminStatActivities => 'Activities';

  @override
  String get adminStatBookings => 'Bookings';

  @override
  String get adminContentManagement => 'Content Management';

  @override
  String get adminManageContent => 'Manage Content';

  @override
  String get adminManageContentSubtitle =>
      'Create, edit, and delete hotels and activities.';

  @override
  String get adminManageHotelsSubtitle =>
      'Create, update, and remove hotel records.';

  @override
  String get adminManageActivitiesSubtitle =>
      'Create, update, and remove activity records.';

  @override
  String get adminManageEventsSubtitle =>
      'Create, update, and remove event records.';

  @override
  String get adminViewBookings => 'View User Bookings';

  @override
  String get adminViewBookingsSubtitle =>
      'Open bookings list to verify saved reservations.';

  @override
  String get adminManageTitle => 'Manage Content';

  @override
  String get adminManageOnlyAdmins =>
      'Only admins can access content management.';

  @override
  String get adminTabHotels => 'Hotels';

  @override
  String get adminTabActivities => 'Activities';

  @override
  String get adminAddHotel => 'Add hotel';

  @override
  String get adminAddActivity => 'Add activity';

  @override
  String get adminAddContent => 'Add content';

  @override
  String get adminEditContent => 'Edit content';

  @override
  String get adminLabelNameRequired => 'Name *';

  @override
  String get adminNameRequiredError => 'Name is required.';

  @override
  String get adminLabelLocation => 'Location';

  @override
  String get adminLabelCity => 'City';

  @override
  String get adminLabelRating => 'Rating (0-5)';

  @override
  String get adminLabelPricePerNight => 'Price per night';

  @override
  String get adminLabelPrice => 'Price';

  @override
  String get adminLabelPlanType => 'Plan type (e.g. family)';

  @override
  String get adminLabelOpenHours => 'Open hours';

  @override
  String get adminLabelCloseHours => 'Close hours';

  @override
  String get adminLabelBookingUrl => 'Booking URL';

  @override
  String get adminLabelMapsUrl => 'Maps URL';

  @override
  String get adminAddLocation => 'Add location';

  @override
  String get adminLocationPickHint =>
      'Use the button below to pick the location from Google Maps.';

  @override
  String get adminLocationRequiredError =>
      'Please pick the location from Google Maps.';

  @override
  String get adminSelectCityError => 'Please select a city.';

  @override
  String get adminSelectRatingError => 'Please select a rating.';

  @override
  String get adminSelectCategoryError => 'Please select a category.';

  @override
  String get adminCategoryFamily => 'Family';

  @override
  String get adminCategoryCultural => 'Cultural';

  @override
  String get adminCategoryAdventure => 'Adventure';

  @override
  String get adminCategoryNature => 'Nature';

  @override
  String get adminCategoryEntertainment => 'Entertainment';

  @override
  String get adminDatePickerHint => 'No date selected yet.';

  @override
  String get adminPickDate => 'Pick date';

  @override
  String get adminDateRequiredError => 'Please pick a date.';

  @override
  String get adminNavDashboard => 'Dashboard';

  @override
  String get adminNavHotels => 'Hotels';

  @override
  String get adminNavActivities => 'Activities';

  @override
  String get adminNavEvents => 'Events';

  @override
  String get adminNavBookings => 'Bookings';

  @override
  String get adminNavSettings => 'Settings';

  @override
  String get adminSettingsTitle => 'Admin Settings';

  @override
  String get adminSettingsSubtitle =>
      'Manage your admin account and app preferences.';

  @override
  String get adminSettingsGuideSubtitle => 'Open user guide instructions.';

  @override
  String get adminSettingsPrivacySubtitle => 'Review the privacy policy page.';

  @override
  String get adminLogoutConfirm =>
      'Are you sure you want to log out from the admin session?';

  @override
  String get adminAnalyticsTitle => 'Analytics';

  @override
  String get adminAnalyticsBookingStatus => 'Booking status distribution';

  @override
  String get adminAnalyticsTopCities => 'Top destination cities';

  @override
  String get adminAnalyticsSelectedPlans => 'Selected plan insights';

  @override
  String adminAnalyticsSelectedPlansCount(int count) {
    return 'Selected plans: $count';
  }

  @override
  String get adminAnalyticsAiPerformance => 'AI response performance';

  @override
  String adminAnalyticsAverageLatency(Object milliseconds) {
    return 'Average AI latency: $milliseconds ms';
  }

  @override
  String adminAnalyticsSlowResponses(int count) {
    return 'Responses above 3000 ms: $count';
  }

  @override
  String get adminAnalyticsHighLatencyNote =>
      'Target response time is 3000 ms or less.';

  @override
  String get adminStatusOther => 'Other';

  @override
  String get adminNoAnalyticsData => 'No analytics data yet.';

  @override
  String get adminMapPickerTitle => 'Pick location from map';

  @override
  String get adminMapTapHint => 'Tap the map to drop a marker on the location.';

  @override
  String get adminMapConfirmLocation => 'Use this location';

  @override
  String get adminMapPickFirst => 'Please pick a point on the map first.';

  @override
  String get adminMapFallbackNotice =>
      'Google Maps is unavailable on this device; using the built-in map picker.';

  @override
  String get adminDeleteTitle => 'Delete item';

  @override
  String get adminDeleteConfirm =>
      'Are you sure you want to delete this record?';

  @override
  String adminSaveAdded(Object collection) {
    return '$collection item added successfully.';
  }

  @override
  String adminSaveUpdated(Object collection) {
    return '$collection item updated successfully.';
  }

  @override
  String adminSaveFailed(Object details) {
    return 'Failed to save item: $details';
  }

  @override
  String adminDeleteSuccess(Object collection) {
    return '$collection item deleted.';
  }

  @override
  String adminDeleteFailed(Object details) {
    return 'Delete failed: $details';
  }

  @override
  String adminLoadError(Object collection) {
    return 'Error loading $collection.';
  }

  @override
  String adminNoRecords(Object collection) {
    return 'No records in $collection yet.';
  }

  @override
  String get adminNoExtraDetails => 'No extra details';

  @override
  String get adminUnknownName => 'Unnamed';

  @override
  String adminLocationValue(Object value) {
    return 'Location: $value';
  }

  @override
  String adminPriceValue(Object value) {
    return 'Price: $value';
  }

  @override
  String adminRatingValue(Object value) {
    return 'Rating: $value';
  }

  @override
  String get adminPerNightSuffix => ' /night';

  @override
  String get adminTooltipEdit => 'Edit';

  @override
  String get adminTooltipDelete => 'Delete';

  @override
  String dependentsAiLatencyExceeded(Object milliseconds) {
    return 'AI response took $milliseconds ms. This exceeds the 3000 ms limit, so the plan was not saved. Please retry.';
  }

  @override
  String get settingsUserGuide => 'User Guide';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get helpTitle => 'User Guide';

  @override
  String get helpSubtitle => 'Simple steps to plan a family trip';

  @override
  String get helpStep1 => '1) Enter family size and ages.';

  @override
  String get helpStep2 => '2) Set budget, city, and trip duration.';

  @override
  String get helpStep3 => '3) Generate plans and compare them.';

  @override
  String get helpStep4 => '4) Open maps or booking links when available.';

  @override
  String get helpStep5 => '5) Save your plan and view it later.';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacySection1Title => '1. Data We Collect';

  @override
  String get privacySection1Body =>
      'We collect account information (name, email), family trip inputs, generated plans, and booking logs needed to provide the service.';

  @override
  String get privacySection2Title => '2. Why We Use Data';

  @override
  String get privacySection2Body =>
      'Your data is used to generate personalized trip plans, show plan history, and provide booking confirmations.';

  @override
  String get privacySection3Title => '3. Storage and Security';

  @override
  String get privacySection3Body =>
      'Data is stored in Firebase services with authenticated access controls. Passwords are handled by Firebase Authentication and are not stored in plain text by the app.';

  @override
  String get privacySection4Title => '4. Booking and External Links';

  @override
  String get privacySection4Body =>
      'Bookings may open external providers or maps links. Payments, if any, are completed outside this application.';

  @override
  String get privacySection5Title => '5. Your Controls';

  @override
  String get privacySection5Body =>
      'You can edit profile data, update trip preferences, and request account deletion from the account screen.';

  @override
  String get privacySection6Title => '6. Contact and Updates';

  @override
  String get privacySection6Body =>
      'This policy can be updated with new app releases. Continued use means acceptance of the latest policy.';

  @override
  String get bookingsReceiptTitle => 'Booking Receipt';

  @override
  String get bookingsReceiptId => 'ID';

  @override
  String get bookingsReceiptReference => 'Reference';

  @override
  String get bookingsReceiptItem => 'Item';

  @override
  String get bookingsReceiptType => 'Type';

  @override
  String get bookingsReceiptStatus => 'Status';

  @override
  String get bookingsReceiptDate => 'Date';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDone => 'Done';

  @override
  String get bookingViewBookings => 'View bookings';

  @override
  String get bookingConfirmedTitle => 'Booking Confirmed';

  @override
  String get bookingConfirmedBody =>
      'Your reservation has been recorded successfully.';

  @override
  String get bookingSuccessDefaultItemType => 'Attraction';

  @override
  String get bookingSuccessTitle => 'Success';

  @override
  String bookingSuccessBody(Object itemType) {
    return '$itemType has been successfully booked.';
  }

  @override
  String bookingSuccessViewAllPrompt(Object itemType) {
    return 'Want to see all your $itemType? ';
  }

  @override
  String get bookingSuccessClickHere => 'Click here.';

  @override
  String get bookingSuccessBackToPlan => 'Back to plan';

  @override
  String get bookingPlanUnavailable =>
      'This booking cannot be saved because the selected plan is missing.';

  @override
  String get plansGeneratedPlanTitle => 'Generated Plan';

  @override
  String get plansGeneratedDynamically => 'Generated dynamically';

  @override
  String plansDurationValue(int days) {
    return '$days days';
  }

  @override
  String plansDayLabel(int day) {
    return 'Day $day';
  }

  @override
  String plansPricePerNight(Object amount) {
    return '$amount SAR/night';
  }

  @override
  String plansTotalPrice(Object amount) {
    return 'Total $amount SAR';
  }

  @override
  String get plansTimeLabel => 'Time';

  @override
  String get plansDescriptionLabel => 'Description';

  @override
  String get plansNoGeneratedPlans => 'No generated plans found in database.';

  @override
  String get plansGenerateNewPlan => 'Generate a new plan';

  @override
  String get plansSelectFavoriteHeader => 'Select your favorite plan:';

  @override
  String plansSaveSelectionError(Object details) {
    return 'Could not save selected plan: $details';
  }

  @override
  String get plansLabelSelectedCity => 'Selected city';

  @override
  String get plansLabelDates => 'Dates';

  @override
  String get plansLabelTripDuration => 'Trip duration';

  @override
  String get plansLabelHotel => 'Hotel';

  @override
  String get plansLabelNearbyAttractions => 'Nearby attractions';

  @override
  String get plansLabelDistantAttractions => 'Distant attractions';

  @override
  String get plansLabelEvents => 'Events';

  @override
  String get plansLabelTotalBudget => 'Total budget for this plan';

  @override
  String get plansTableDays => 'Days';

  @override
  String get plansTableMorning => 'Morning';

  @override
  String get plansTableAfternoon => 'Afternoon';

  @override
  String get plansTableEvening => 'Evening';

  @override
  String get actionOpenInMaps => 'Open in Maps';

  @override
  String get actionBookNow => 'Book now';

  @override
  String planDetailTitle(Object title) {
    return '$title details';
  }

  @override
  String get planDetailHotelSection => 'Hotel information';

  @override
  String get planDetailLocationLabel => 'Location';

  @override
  String get planDetailPriceLabel => 'Price';

  @override
  String get planDetailRatingLabel => 'Rating';

  @override
  String get planDetailAmenities => 'Amenities';

  @override
  String get planDetailWhyPlan => 'Why this plan';

  @override
  String get planDetailWhyHotel => 'Why this hotel';

  @override
  String get planDetailSelectHotelHint =>
      'Switch between the recommended hotels';

  @override
  String get planDetailPreviousHotel => 'Previous';

  @override
  String get planDetailNextHotel => 'Next';

  @override
  String planDetailHotelPosition(int current, int total) {
    return 'Hotel $current of $total';
  }

  @override
  String get planDetailOpenClose => 'Open | Close';

  @override
  String get planDetailDistance => 'Distance';

  @override
  String get planDetailTourGuideSection => 'Tour Guide';

  @override
  String get planDetailShareSummary => 'Share summary';

  @override
  String get planDetailShareFailed => 'Could not share the plan summary.';

  @override
  String get planDetailPdfPreview => 'PDF preview';

  @override
  String planDetailDayRouteTitle(Object day) {
    return 'Route for $day';
  }

  @override
  String get planDetailRouteStops => 'Stops';

  @override
  String get planDetailOpenRoute => 'Open route';

  @override
  String get planDetailNoRoutePreview =>
      'Map preview is not available for this day.';

  @override
  String get planDetailNavigateToPlace => 'Navigate to Place';

  @override
  String get planDetailBookHotelViaMaps => 'Book Hotel via Maps';

  @override
  String get bookingLoginRequiredSaveFailed =>
      'Please log in. Booking was not saved.';

  @override
  String get planDetailNoEvents => 'No events available.';

  @override
  String get planDetailNoActivities => 'No activities available.';

  @override
  String get planDetailHotelItemType => 'Hotel';

  @override
  String get planDetailActivityItemType => 'Activity';

  @override
  String get homeWelcomeTitle => 'Welcome to\nFATRIPY';

  @override
  String get homeHeroSubtitle => 'Discover Saudi cities,\none trip at a time';

  @override
  String get homeMainDestination => 'Explore Cities';

  @override
  String get homeSeasonalAttractions => 'Trip Styles';

  @override
  String get homeDestination1Title => 'Cultural Discovery';

  @override
  String get homeDestination1Description =>
      'Historic districts, museums, and heritage landmarks for curious travelers.';

  @override
  String get homeDestination2Title => 'Coastal Escapes';

  @override
  String get homeDestination2Description =>
      'Seafront walks, island vibes, and family-friendly waterfront experiences.';

  @override
  String get homeDestination3Title => 'Mountain Nature';

  @override
  String get homeDestination3Description =>
      'Cool weather, scenic heights, and nature-driven moments across the Kingdom.';

  @override
  String get homeSeason1Title => 'Family Friendly';

  @override
  String get homeSeason1Description =>
      'Balanced plans with comfortable pacing for all family members.';

  @override
  String get homeSeason2Title => 'Adventure & Outdoors';

  @override
  String get homeSeason2Description =>
      'Action-filled itineraries with trails, viewpoints, and active attractions.';

  @override
  String get homeSeason3Title => 'Relax & Leisure';

  @override
  String get homeSeason3Description =>
      'Calm stays, scenic dining, and smooth city experiences.';

  @override
  String get homeCityCardHint => 'Hotels, activities, and events available';

  @override
  String get blogTitle => 'BLOG';

  @override
  String get blogSubtitle => 'All supported cities in FATRIPY';

  @override
  String get blogFutureNotice => 'More city content is coming soon.';

  @override
  String get blogRiyadhDescription =>
      'Riyadh is located in the heart of the Kingdom on the Najd plateau, and it is the capital and largest city of Saudi Arabia. It is distinguished by a rich Najdi heritage visible in Masmak Palace and the historic Diriyah, which is registered with UNESCO and where the Saudi state began. Today, Riyadh is known for its unique blend of past and modernity, from its famous towers such as the Kingdom Tower and Al Faisaliah Tower to its museums and traditional markets, making it a center for culture, economy, and contemporary life.';

  @override
  String get blogJeddahDescription =>
      'Jeddah is located in the west of the Kingdom on the Red Sea coast and is known as the gateway to the Two Holy Mosques. Historic Jeddah (Al-Balad) is one of its most prominent heritage sites, containing over 600 heritage buildings and old houses such as Nassif House, and it is registered as a UNESCO site. Jeddah is famous for its maritime spirit, its long corniche, and its cultural diversity, making it a city that combines tradition, modernity, and coastal life.';

  @override
  String get blogMeccaDescription =>
      'Mecca is located in the western region of Saudi Arabia and is the holiest city in Islam. It is home to Al-Masjid Al-Haram and the Kaaba, the direction Muslims face during their daily prayers. The city holds immense religious significance and welcomes millions of Muslims every year who come to perform Hajj and Umrah. Mecca combines deep spiritual heritage with modern urban development, making it one of the most important religious and cultural centers in the Islamic world.';

  @override
  String get blogMadinahTitle => 'Madinah';

  @override
  String get blogMadinahDescription =>
      'Madinah is located in the western region of Saudi Arabia and is one of the holiest cities in Islam. It is home to Al-Masjid An-Nabawi, the Prophet’s Mosque, and holds a special place in Islamic history. The city is known for its spiritual atmosphere, rich heritage, and important religious landmarks. Madinah also combines historical significance with modern urban development, making it a unique religious and cultural destination.';

  @override
  String get blogDammamDescription =>
      'Dammam is located in the Eastern Province of Saudi Arabia and is one of the Kingdom’s major coastal cities overlooking the Arabian Gulf. It is known for its beautiful waterfront, lively atmosphere, and strong economic importance. As a key center for business, trade, and industry, Dammam combines modern urban living with attractive leisure destinations, making it a notable city for both residents and visitors.';

  @override
  String get blogAbhaDescription =>
      'Abha is located in the Asir region in southwestern Saudi Arabia and is famous for its stunning mountain landscapes and mild weather throughout the year. The city is known for its natural beauty, green parks, and cultural heritage, making it one of the Kingdom’s most attractive destinations for nature lovers and tourists. Abha offers a unique experience that blends scenic charm with rich local identity and tradition.';

  @override
  String get blogTaifDescription =>
      'Taif is located in the western region of Saudi Arabia and is well known for its pleasant weather, mountain scenery, and fragrant roses. It is considered one of the Kingdom’s top summer destinations thanks to its beautiful highlands, traditional markets, and diverse natural attractions. Taif combines historical charm with modern development, offering visitors a relaxing and memorable experience.';

  @override
  String blogCityGenericDescription(Object city) {
    return '$city is available in FATRIPY with city-based planning for hotels, activities, and events.';
  }

  @override
  String get blogCityJazan => 'Jazan';

  @override
  String get blogJazanDescription =>
      'Jazan is located in the far southwest of the Kingdom on the Red Sea coast and is distinguished by a great natural diversity, from the green Faifa mountains to the enchanting Farasan Islands. It has an ancient history reflected in archaeological sites that span thousands of years and the Dawsari Castle. Jazan is famous for its popular heritage, such as the Jazan dance (Ardah), for growing coffee and bananas, and for its warm climate and the authentic culture of its people.';

  @override
  String get blogCityAlKhobar => 'Al Khobar';

  @override
  String get blogAlKhobarDescription =>
      'Al Khobar is located in the eastern part of the Kingdom on the Arabian Gulf coast, about 17 km south of Dammam. It flourished after the discovery of oil and has become one of the most beautiful cities in the Eastern Province. It is famous for the long Al Khobar Corniche, the modern waterfront, and the King Fahd Bridge that connects Saudi Arabia to Bahrain. Al Khobar is characterized by its modern style, upscale markets, cafes, and parks, making it a distinctive tourist and urban destination.';
}
