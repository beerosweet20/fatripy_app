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
  String get navHome => 'الرئيسية';

  @override
  String get navPlans => 'الخطط';

  @override
  String get navBookings => 'الحجوزات';

  @override
  String get navProfile => 'حسابي';

  @override
  String get loginWelcome => 'مرحبًا!';

  @override
  String get labelEmail => 'البريد الإلكتروني';

  @override
  String get labelPassword => 'كلمة المرور';

  @override
  String get actionLogin => 'تسجيل الدخول';

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
}
