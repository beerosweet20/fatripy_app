// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'فطريبي';

  @override
  String get navBlog => 'المدونة';

  @override
  String get navLogin => 'تسجيل الدخول';

  @override
  String get navShop => 'المتجر';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navPlans => 'الخطط';

  @override
  String get navBookings => 'الحجوزات';

  @override
  String get navCart => 'السلة';

  @override
  String get navProfile => 'حسابي';

  @override
  String get navAccount => 'الحساب';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get accountTitle => 'حسابي';

  @override
  String get accountNotifications => 'الإشعارات';

  @override
  String get accountDependents => 'المعالين';

  @override
  String get accountSettingsPrivacy => 'الإعدادات والخصوصية';

  @override
  String get accountBookedAttraction => 'حجوزات المعالم';

  @override
  String get accountDeleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirm => 'هل أنت متأكد من حذف الحساب؟';

  @override
  String get deleteAccountSuccess => 'تم حذف الحساب.';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionRefresh => 'تحديث';

  @override
  String get actionSave => 'حفظ';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsEditProfile => 'تعديل الملف الشخصي';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'الثيم';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get themeDefault => 'افتراضي';

  @override
  String get themePink => 'وردي';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get editProfileName => 'الاسم الكامل';

  @override
  String get editProfileEmail => 'البريد الإلكتروني';

  @override
  String get editProfileEmailHint =>
      'تحديث البريد قد يتطلب تسجيل الدخول مرة أخرى';

  @override
  String get editProfileSuccess => 'تم تحديث البيانات.';

  @override
  String get editProfileReauth => 'يرجى تسجيل الدخول مرة أخرى لتحديث البريد.';

  @override
  String get dependentsTitle => 'اكتب معلوماتك';

  @override
  String get dependentsMyFamily => 'عائلتي';

  @override
  String get dependentsTripInfo => 'معلومات الرحلة';

  @override
  String get dependentsAdults => 'بالغين';

  @override
  String get dependentsChildren => 'أطفال';

  @override
  String get dependentsInfant => 'رضيع';

  @override
  String get dependentsAdultAges => 'أعمار البالغين';

  @override
  String get dependentsChildAges => 'أعمار الأطفال';

  @override
  String get dependentsInfantAges => 'أعمار الرضع';

  @override
  String dependentsAgeField(int index) {
    return 'العمر $index';
  }

  @override
  String get dependentsBudget => 'الميزانية';

  @override
  String get dependentsCity => 'المدينة';

  @override
  String get dependentsDuration => 'المدة';

  @override
  String get dependentsStart => 'البداية';

  @override
  String get dependentsEnd => 'النهاية';

  @override
  String get dependentsDefaultBudget => '21000 ريال';

  @override
  String get dependentsDefaultDuration => '7 أيام و 6 ليالٍ';

  @override
  String get dependentsDefaultStartDate => '1 ديسمبر 2026';

  @override
  String get dependentsDefaultEndDate => '7 ديسمبر 2026';

  @override
  String get cityRiyadh => 'الرياض';

  @override
  String get cityJeddah => 'جدة';

  @override
  String get cityMecca => 'مكة';

  @override
  String get cityMedina => 'المدينة';

  @override
  String get cityDammam => 'الدمام';

  @override
  String get cityKhobar => 'الخبر';

  @override
  String get cityAbha => 'أبها';

  @override
  String get cityTaif => 'الطائف';

  @override
  String get dependentsDone => 'تم';

  @override
  String get dependentsGeneratingPlan =>
      'جارٍ إنشاء خطة الرحلة... يرجى الانتظار.';

  @override
  String get dependentsGenerationComplete =>
      'اكتمل إنشاء الرحلة! راجِع خططك الجديدة.';

  @override
  String dependentsAiLatencyWarning(Object milliseconds) {
    return 'تنبيه: استغرق التوصية الذكية $milliseconds مللي ثانية (المستهدف 3000 مللي ثانية).';
  }

  @override
  String get loginWelcome => 'مرحبًا!';

  @override
  String get labelEmail => 'البريد الإلكتروني';

  @override
  String get labelPassword => 'كلمة المرور';

  @override
  String get actionLogin => 'تسجيل الدخول';

  @override
  String get forgotPasswordCta => 'نسيت كلمة المرور؟';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordSend => 'إرسال';

  @override
  String get resetPasswordSuccess => 'تم إرسال رابط إعادة تعيين كلمة المرور.';

  @override
  String get resetPasswordFailure => 'فشل إرسال رابط إعادة التعيين.';

  @override
  String get loginNoAccount => 'ليس لديك حساب؟ ';

  @override
  String get actionRegister => 'إنشاء حساب';

  @override
  String get registerTitle => 'يرجى تعبئة النموذج للتسجيل';

  @override
  String get labelFullName => 'الاسم الكامل';

  @override
  String get labelUsername => 'اسم المستخدم';

  @override
  String get labelConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get registerHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get errorFillAllFields => 'يرجى تعبئة جميع الحقول.';

  @override
  String get errorLoginFailed => 'فشل تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get errorGeneric => 'حدث خطأ. حاول مرة أخرى.';

  @override
  String get errorUsernameNoSpaces =>
      'اسم المستخدم لا يمكن أن يحتوي على مسافات.';

  @override
  String get errorPasswordTooShort => 'كلمة المرور يجب ألا تقل عن 6 أحرف.';

  @override
  String get errorPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get errorUsernameTaken => 'اسم المستخدم مستخدم بالفعل.';

  @override
  String get errorRegistrationFailed => 'فشل التسجيل. حاول مرة أخرى.';

  @override
  String homeGreetingName(Object name) {
    return 'مرحبًا، $name!';
  }

  @override
  String get homeFriendName => 'يا صديق';

  @override
  String get homeSubtitle => 'لنخطط رحلتكم القادمة';

  @override
  String familyCountLabel(int count) {
    return 'عدد أفراد العائلة: $count';
  }

  @override
  String get familyManagement => 'إدارة العائلة';

  @override
  String get startPlanning => 'ابدأ التخطيط';

  @override
  String get homeAiTeaser => 'ذكاء ذكي يجهز رحلتك';

  @override
  String get latestPlans => 'أحدث الخطط';

  @override
  String get recentBookings => 'الحجوزات الأخيرة';

  @override
  String get createPlan => 'إنشاء خطة';

  @override
  String get emptyPlans => 'لا توجد خطط حتى الآن.';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get errorPleaseLogin => 'يرجى تسجيل الدخول للمتابعة.';

  @override
  String errorWithDetails(Object details) {
    return 'خطأ: $details';
  }

  @override
  String planSummary(int days, Object budget) {
    return '$days أيام • $budget ريال';
  }

  @override
  String get bookingsLoadError => 'حدث خطأ أثناء تحميل الحجوزات.';

  @override
  String get bookingsEmpty => 'لا توجد حجوزات حتى الآن.';

  @override
  String bookingItemTitle(Object itemType) {
    return 'حجز: $itemType';
  }

  @override
  String bookingPlacedOn(Object date) {
    return 'التاريخ: $date';
  }

  @override
  String get statusPending => 'قيد المراجعة';

  @override
  String get statusBooked => 'محجوز';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String planListSubtitle(Object budget, Object status) {
    return 'الميزانية: $budget • $status';
  }

  @override
  String bookingListSubtitle(Object status, Object date) {
    return 'الحالة: $status • تم في: $date';
  }

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get debugExplorer => 'مستكشف البيانات (Debug)';

  @override
  String get hotelsTitle => 'الفنادق';

  @override
  String get hotelsLoadError => 'حدث خطأ أثناء تحميل البيانات.';

  @override
  String get hotelsNoData => 'لا توجد بيانات حالياً.';

  @override
  String get hotelsEmpty => 'لا توجد فنادق للعرض.';

  @override
  String get hotelNameUnknown => 'اسم غير متوفر';

  @override
  String get hotelLocationUnknown => 'موقع غير معروف';

  @override
  String get comparePlansCta => 'قارن الخطط';

  @override
  String get comparePlansTitle => 'مقارنة الخطط';

  @override
  String get compareKindLabel => 'النوع';

  @override
  String get compareHotelLabel => 'الفندق';

  @override
  String get compareTotalCostLabel => 'الإجمالي';

  @override
  String get compareNearbyLabel => 'المعالم القريبة';

  @override
  String get compareDistantLabel => 'المعالم البعيدة';

  @override
  String get compareEventsLabel => 'الفعاليات';

  @override
  String get selectPlanCta => 'اختيار الخطة';

  @override
  String get plansFamilyTitle => 'الخطة العائلية الهادئة';

  @override
  String get plansCulturalTitle => 'الخطة الثقافية';

  @override
  String get plansAdventureTitle => 'خطة المغامرة';

  @override
  String plansBudgetLowBannerMessage(
    Object userBudget,
    Object minimumRequired,
  ) {
    return 'نلاحظ أن ميزانيتك منخفضة جداً ($userBudget ريال) لتغطية هذه الرحلة. لقد قمنا بتوليد أقل خطة تكلفة ممكنة لك بسعر تقديري: $minimumRequired ريال.';
  }

  @override
  String get plansDynamicEventPlaceholder => 'مقترحات فعاليات ديناميكية';

  @override
  String get plansDynamicEventDescription => 'مبنية على الإحداثيات المختارة';

  @override
  String get profileAdminDashboard => 'لوحة التحكم';

  @override
  String get profileAdminUsers => 'المستخدمون';

  @override
  String get profileAdminTripPlans => 'خطط الرحلات';

  @override
  String get adminDashboardTitle => 'لوحة تحكم المشرف';

  @override
  String get adminNoAccess => 'ليس لديك صلاحية المشرف.';

  @override
  String get adminBackToProfile => 'العودة للحساب';

  @override
  String get adminStatsTitle => 'إحصائيات اللوحة';

  @override
  String get adminStatHotels => 'الفنادق';

  @override
  String get adminStatActivities => 'الأنشطة';

  @override
  String get adminStatBookings => 'الحجوزات';

  @override
  String get adminContentManagement => 'إدارة المحتوى';

  @override
  String get adminManageContent => 'إدارة المحتوى';

  @override
  String get adminManageContentSubtitle =>
      'إضافة وتعديل وحذف الفنادق والأنشطة.';

  @override
  String get adminManageHotelsSubtitle => 'إضافة وتعديل وحذف بيانات الفنادق.';

  @override
  String get adminManageActivitiesSubtitle =>
      'إضافة وتعديل وحذف بيانات الأنشطة.';

  @override
  String get adminManageEventsSubtitle => 'إضافة وتعديل وحذف بيانات الفعاليات.';

  @override
  String get adminViewBookings => 'عرض حجوزات المستخدمين';

  @override
  String get adminViewBookingsSubtitle =>
      'افتح قائمة الحجوزات للتحقق من الحجوزات المحفوظة.';

  @override
  String get adminManageTitle => 'إدارة المحتوى';

  @override
  String get adminManageOnlyAdmins =>
      'يمكن للمشرفين فقط الوصول لإدارة المحتوى.';

  @override
  String get adminTabHotels => 'الفنادق';

  @override
  String get adminTabActivities => 'الأنشطة';

  @override
  String get adminAddHotel => 'إضافة فندق';

  @override
  String get adminAddActivity => 'إضافة نشاط';

  @override
  String get adminAddContent => 'إضافة محتوى';

  @override
  String get adminEditContent => 'تعديل المحتوى';

  @override
  String get adminLabelNameRequired => 'الاسم *';

  @override
  String get adminNameRequiredError => 'الاسم مطلوب.';

  @override
  String get adminLabelLocation => 'الموقع';

  @override
  String get adminLabelCity => 'المدينة';

  @override
  String get adminLabelRating => 'التقييم (0-5)';

  @override
  String get adminLabelPricePerNight => 'سعر الليلة';

  @override
  String get adminLabelPrice => 'السعر';

  @override
  String get adminLabelPlanType => 'نوع الخطة (مثل عائلي)';

  @override
  String get adminLabelOpenHours => 'ساعات الفتح';

  @override
  String get adminLabelCloseHours => 'ساعات الإغلاق';

  @override
  String get adminLabelBookingUrl => 'رابط الحجز';

  @override
  String get adminLabelMapsUrl => 'رابط الخرائط';

  @override
  String get adminAddLocation => 'إضافة الموقع';

  @override
  String get adminLocationPickHint =>
      'استخدم الزر أدناه لتحديد الموقع من خرائط Google.';

  @override
  String get adminLocationRequiredError => 'يرجى تحديد الموقع من خرائط Google.';

  @override
  String get adminSelectCityError => 'يرجى اختيار المدينة.';

  @override
  String get adminSelectRatingError => 'يرجى اختيار التقييم.';

  @override
  String get adminSelectCategoryError => 'يرجى اختيار التصنيف.';

  @override
  String get adminCategoryFamily => 'عائلي';

  @override
  String get adminCategoryCultural => 'ثقافي';

  @override
  String get adminCategoryAdventure => 'مغامرة';

  @override
  String get adminCategoryNature => 'طبيعة';

  @override
  String get adminCategoryEntertainment => 'ترفيهي';

  @override
  String get adminDatePickerHint => 'لم يتم اختيار تاريخ بعد.';

  @override
  String get adminPickDate => 'اختيار التاريخ';

  @override
  String get adminDateRequiredError => 'يرجى اختيار التاريخ.';

  @override
  String get adminNavDashboard => 'اللوحة';

  @override
  String get adminNavHotels => 'فنادق';

  @override
  String get adminNavActivities => 'أنشطة';

  @override
  String get adminNavEvents => 'فعاليات';

  @override
  String get adminNavBookings => 'حجوزات';

  @override
  String get adminNavSettings => 'الإعدادات';

  @override
  String get adminSettingsTitle => 'إعدادات المشرف';

  @override
  String get adminSettingsSubtitle => 'إدارة حساب المشرف وتفضيلات التطبيق.';

  @override
  String get adminSettingsGuideSubtitle => 'فتح إرشادات الاستخدام.';

  @override
  String get adminSettingsPrivacySubtitle => 'مراجعة صفحة سياسة الخصوصية.';

  @override
  String get adminLogoutConfirm =>
      'هل أنت متأكد أنك تريد تسجيل الخروج من جلسة المشرف؟';

  @override
  String get adminAnalyticsTitle => 'التحليلات';

  @override
  String get adminAnalyticsBookingStatus => 'توزيع حالات الحجوزات';

  @override
  String get adminAnalyticsTopCities => 'المدن الأكثر اختيارًا';

  @override
  String get adminAnalyticsSelectedPlans => 'تحليل الخطط المختارة';

  @override
  String adminAnalyticsSelectedPlansCount(int count) {
    return 'عدد الخطط المختارة: $count';
  }

  @override
  String get adminAnalyticsAiPerformance => 'أداء استجابة الذكاء';

  @override
  String adminAnalyticsAverageLatency(Object milliseconds) {
    return 'متوسط زمن استجابة الذكاء: $milliseconds مللي ثانية';
  }

  @override
  String adminAnalyticsSlowResponses(int count) {
    return 'الاستجابات التي تجاوزت 3000 مللي ثانية: $count';
  }

  @override
  String get adminAnalyticsHighLatencyNote =>
      'الزمن المستهدف للاستجابة هو 3000 مللي ثانية أو أقل.';

  @override
  String get adminStatusOther => 'أخرى';

  @override
  String get adminNoAnalyticsData => 'لا توجد بيانات تحليلية حتى الآن.';

  @override
  String get adminMapPickerTitle => 'تحديد الموقع من الخريطة';

  @override
  String get adminMapTapHint => 'اضغط على الخريطة لوضع العلامة على الموقع.';

  @override
  String get adminMapConfirmLocation => 'اعتماد هذا الموقع';

  @override
  String get adminMapPickFirst => 'يرجى اختيار نقطة على الخريطة أولاً.';

  @override
  String get adminMapFallbackNotice =>
      'خرائط Google غير متاحة على هذا الجهاز؛ سيتم استخدام خريطة بديلة داخل التطبيق.';

  @override
  String get adminDeleteTitle => 'حذف العنصر';

  @override
  String get adminDeleteConfirm => 'هل أنت متأكد من حذف هذا السجل؟';

  @override
  String adminSaveAdded(Object collection) {
    return 'تمت إضافة عنصر $collection بنجاح.';
  }

  @override
  String adminSaveUpdated(Object collection) {
    return 'تم تحديث عنصر $collection بنجاح.';
  }

  @override
  String adminSaveFailed(Object details) {
    return 'فشل حفظ العنصر: $details';
  }

  @override
  String adminDeleteSuccess(Object collection) {
    return 'تم حذف عنصر $collection.';
  }

  @override
  String adminDeleteFailed(Object details) {
    return 'فشل الحذف: $details';
  }

  @override
  String adminLoadError(Object collection) {
    return 'حدث خطأ أثناء تحميل $collection.';
  }

  @override
  String adminNoRecords(Object collection) {
    return 'لا توجد سجلات في $collection حتى الآن.';
  }

  @override
  String get adminNoExtraDetails => 'لا توجد تفاصيل إضافية';

  @override
  String get adminUnknownName => 'بدون اسم';

  @override
  String adminLocationValue(Object value) {
    return 'الموقع: $value';
  }

  @override
  String adminPriceValue(Object value) {
    return 'السعر: $value';
  }

  @override
  String adminRatingValue(Object value) {
    return 'التقييم: $value';
  }

  @override
  String get adminPerNightSuffix => ' /لليلة';

  @override
  String get adminTooltipEdit => 'تعديل';

  @override
  String get adminTooltipDelete => 'حذف';

  @override
  String dependentsAiLatencyExceeded(Object milliseconds) {
    return 'استغرقت استجابة الذكاء الاصطناعي $milliseconds مللي ثانية. تم تجاوز حد 3000 مللي ثانية لذلك لم يتم حفظ الخطة. يرجى المحاولة مرة أخرى.';
  }

  @override
  String get settingsUserGuide => 'دليل المستخدم';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get helpTitle => 'دليل المستخدم';

  @override
  String get helpSubtitle => 'خطوات بسيطة لتخطيط رحلة عائلية';

  @override
  String get helpStep1 => '1) أدخل عدد أفراد العائلة وأعمارهم.';

  @override
  String get helpStep2 => '2) حدّد الميزانية والمدينة ومدة الرحلة.';

  @override
  String get helpStep3 => '3) أنشئ الخطط وقارن بينها.';

  @override
  String get helpStep4 => '4) افتح الخرائط أو روابط الحجز عند توفرها.';

  @override
  String get helpStep5 => '5) احفظ خطتك وراجعها لاحقًا.';

  @override
  String get privacyTitle => 'سياسة الخصوصية';

  @override
  String get privacySection1Title => '1. البيانات التي نجمعها';

  @override
  String get privacySection1Body =>
      'نجمع معلومات الحساب (الاسم، البريد الإلكتروني)، ومدخلات الرحلة العائلية، والخطط المولدة، وسجلات الحجز اللازمة لتقديم الخدمة.';

  @override
  String get privacySection2Title => '2. لماذا نستخدم البيانات';

  @override
  String get privacySection2Body =>
      'تُستخدم بياناتك لإنشاء خطط رحلات مخصصة، وعرض سجل الخطط، وتقديم تأكيدات الحجز.';

  @override
  String get privacySection3Title => '3. التخزين والأمان';

  @override
  String get privacySection3Body =>
      'يتم تخزين البيانات في خدمات Firebase مع ضوابط وصول للمستخدمين المصرح لهم. تتم إدارة كلمات المرور عبر Firebase Authentication ولا يتم تخزينها كنص صريح داخل التطبيق.';

  @override
  String get privacySection4Title => '4. الحجز والروابط الخارجية';

  @override
  String get privacySection4Body =>
      'قد تفتح الحجوزات مزودي خدمات خارجيين أو روابط خرائط. تتم عمليات الدفع - إن وجدت - خارج هذا التطبيق.';

  @override
  String get privacySection5Title => '5. تحكمك ببياناتك';

  @override
  String get privacySection5Body =>
      'يمكنك تعديل بيانات الملف الشخصي، وتحديث تفضيلات الرحلة، وطلب حذف الحساب من شاشة الحساب.';

  @override
  String get privacySection6Title => '6. التواصل والتحديثات';

  @override
  String get privacySection6Body =>
      'قد يتم تحديث هذه السياسة مع إصدارات التطبيق الجديدة. استمرارك في الاستخدام يعني قبول أحدث نسخة من السياسة.';

  @override
  String get bookingsReceiptTitle => 'إيصال الحجز';

  @override
  String get bookingsReceiptId => 'المعرف';

  @override
  String get bookingsReceiptReference => 'المرجع';

  @override
  String get bookingsReceiptItem => 'العنصر';

  @override
  String get bookingsReceiptType => 'النوع';

  @override
  String get bookingsReceiptStatus => 'الحالة';

  @override
  String get bookingsReceiptDate => 'التاريخ';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionDone => 'تم';

  @override
  String get bookingViewBookings => 'عرض الحجوزات';

  @override
  String get bookingConfirmedTitle => 'تم تأكيد الحجز';

  @override
  String get bookingConfirmedBody => 'تم تسجيل الحجز بنجاح.';

  @override
  String get bookingSuccessDefaultItemType => 'معلم';

  @override
  String get bookingSuccessTitle => 'نجاح';

  @override
  String bookingSuccessBody(Object itemType) {
    return 'تم حجز $itemType بنجاح.';
  }

  @override
  String bookingSuccessViewAllPrompt(Object itemType) {
    return 'هل تريد رؤية جميع $itemType الخاصة بك؟ ';
  }

  @override
  String get bookingSuccessClickHere => 'اضغط هنا.';

  @override
  String get bookingSuccessBackToPlan => 'العودة إلى الخطة';

  @override
  String get bookingPlanUnavailable =>
      'لا يمكن حفظ هذا الحجز لأن الخطة المختارة غير متوفرة.';

  @override
  String get plansGeneratedPlanTitle => 'خطة مولدة';

  @override
  String get plansGeneratedDynamically => 'مولدة ديناميكيًا';

  @override
  String plansDurationValue(int days) {
    return '$days أيام';
  }

  @override
  String plansPricePerNight(Object amount) {
    return '$amount ريال/ليلة';
  }

  @override
  String plansTotalPrice(Object amount) {
    return 'الإجمالي $amount ريال';
  }

  @override
  String get plansTimeLabel => 'الوقت';

  @override
  String get plansDescriptionLabel => 'الوصف';

  @override
  String get plansNoGeneratedPlans => 'لا توجد خطط مولدة في قاعدة البيانات.';

  @override
  String get plansGenerateNewPlan => 'إنشاء خطة جديدة';

  @override
  String get plansSelectFavoriteHeader => 'اختر خطتك المفضلة:';

  @override
  String plansSaveSelectionError(Object details) {
    return 'تعذر حفظ الخطة المختارة: $details';
  }

  @override
  String get plansLabelSelectedCity => 'المدينة المختارة';

  @override
  String get plansLabelDates => 'التواريخ';

  @override
  String get plansLabelTripDuration => 'مدة الرحلة';

  @override
  String get plansLabelHotel => 'الفندق';

  @override
  String get plansLabelNearbyAttractions => 'المعالم القريبة';

  @override
  String get plansLabelDistantAttractions => 'المعالم البعيدة';

  @override
  String get plansLabelEvents => 'الفعاليات';

  @override
  String get plansLabelTotalBudget => 'إجمالي ميزانية هذه الخطة';

  @override
  String get plansTableDays => 'الأيام';

  @override
  String get plansTableMorning => 'الصباح';

  @override
  String get plansTableAfternoon => 'الظهيرة';

  @override
  String get plansTableEvening => 'المساء';

  @override
  String get actionOpenInMaps => 'فتح في الخرائط';

  @override
  String get actionBookNow => 'احجز الآن';

  @override
  String planDetailTitle(Object title) {
    return 'تفاصيل $title';
  }

  @override
  String get planDetailHotelSection => 'معلومات الفندق';

  @override
  String get planDetailLocationLabel => 'الموقع';

  @override
  String get planDetailPriceLabel => 'السعر';

  @override
  String get planDetailRatingLabel => 'التقييم';

  @override
  String get planDetailAmenities => 'المرافق';

  @override
  String get planDetailOpenClose => 'الفتح | الإغلاق';

  @override
  String get planDetailDistance => 'المسافة';

  @override
  String get planDetailNavigateToPlace => 'الانتقال إلى المكان';

  @override
  String get planDetailBookHotelViaMaps => 'احجز الفندق عبر الخرائط';

  @override
  String get bookingLoginRequiredSaveFailed =>
      'يرجى تسجيل الدخول. لم يتم حفظ الحجز.';

  @override
  String get planDetailNoEvents => 'لا توجد فعاليات متاحة.';

  @override
  String get planDetailNoActivities => 'لا توجد أنشطة متاحة.';

  @override
  String get planDetailHotelItemType => 'فندق';

  @override
  String get planDetailActivityItemType => 'نشاط';

  @override
  String get homeWelcomeTitle => 'مرحبًا بك في\nFATRIPY';

  @override
  String get homeHeroSubtitle => 'قلب الرياض\nينتظرك';

  @override
  String get homeMainDestination => 'الوجهات الرئيسية';

  @override
  String get homeSeasonalAttractions => 'الفعاليات الموسمية';

  @override
  String get homeDestination1Title => 'الدرعية';

  @override
  String get homeDestination1Description =>
      'مهد الدولة السعودية الأولى وتجربة تاريخية بطابع تراثي أصيل.';

  @override
  String get homeDestination2Title => 'العليا';

  @override
  String get homeDestination2Description =>
      'قلب الرياض العصري الذي يجمع التسوق الراقي والأبراج المميزة وحيوية المدينة.';

  @override
  String get homeDestination3Title => 'جبل طويق';

  @override
  String get homeDestination3Description =>
      'منحدرات أيقونية وإطلالات خلابة لمغامرات لا تُنسى.';

  @override
  String get homeSeason1Title => 'موسم الرياض';

  @override
  String get homeSeason1Description =>
      'أكبر موسم ترفيهي في المملكة بتجارب عالمية المستوى.';

  @override
  String get homeSeason2Title => 'بوليفارد رياض سيتي';

  @override
  String get homeSeason2Description =>
      'وجهة نابضة بالمطاعم والعروض والترفيه المتواصل.';

  @override
  String get homeSeason3Title => 'نور الرياض';

  @override
  String get homeSeason3Description =>
      'مهرجان فني ضوئي يحول الرياض إلى معرض مفتوح في جميع أنحاء المدينة.';

  @override
  String get blogTitle => 'المدونة';

  @override
  String get blogSubtitle => 'نبذة مختصرة عن المدن داخل تطبيقنا';

  @override
  String get blogFutureNotice => 'ستتوفر قريبًا! ترقبوا.';

  @override
  String get blogRiyadhDescription =>
      'تقع الرياض في قلب المملكة على هضبة نجد، وهي عاصمة المملكة العربية السعودية وأكبر مدنها. تتميز بإرث نجدي عريق يظهر في قصر المصمك والدرعية التاريخية المسجلة في اليونسكو، ومنها بدأت الدولة السعودية. اليوم تُعرف الرياض بمزيجها الفريد بين الأصالة والحداثة، من أبراجها الشهيرة مثل برج المملكة وبرج الفيصلية إلى متاحفها وأسواقها التقليدية، مما يجعلها مركزًا للثقافة والاقتصاد والحياة المعاصرة.';

  @override
  String get blogJeddahDescription =>
      'تقع جدة غرب المملكة على ساحل البحر الأحمر وتُعرف ببوابة الحرمين الشريفين. جدة التاريخية (البلد) من أبرز معالمها التراثية، وتضم أكثر من 600 مبنى تراثي وبيوتًا قديمة مثل بيت نصيف، وهي مسجلة ضمن مواقع اليونسكو. تشتهر جدة بطابعها البحري وكورنيشها الطويل وتنوعها الثقافي، ما يجعلها مدينة تجمع بين التراث والحداثة والحياة الساحلية.';

  @override
  String get blogCityJazan => 'جازان';

  @override
  String get blogJazanDescription =>
      'تقع جازان في أقصى جنوب غرب المملكة على ساحل البحر الأحمر، وتتميز بتنوع طبيعي كبير من جبال فيفا الخضراء إلى جزر فرسان الساحرة. ولها تاريخ عريق يظهر في المواقع الأثرية الممتدة لآلاف السنين وقلعة الدوسرية. تشتهر جازان بتراثها الشعبي مثل الرقصة الجازانية (العرضة)، وبزراعة البن والموز، ومناخها الدافئ وثقافة أهلها الأصيلة.';

  @override
  String get blogCityAlKhobar => 'الخبر';

  @override
  String get blogAlKhobarDescription =>
      'تقع الخبر في شرق المملكة على ساحل الخليج العربي، على بُعد نحو 17 كم جنوب الدمام. ازدهرت بعد اكتشاف النفط وأصبحت من أجمل مدن المنطقة الشرقية. تشتهر بكورنيش الخبر الطويل والواجهة البحرية الحديثة وجسر الملك فهد الذي يربط السعودية بالبحرين. وتمتاز بطابعها العصري وأسواقها الراقية ومقاهيها وحدائقها، مما يجعلها وجهة سياحية وحضرية مميزة.';
}
