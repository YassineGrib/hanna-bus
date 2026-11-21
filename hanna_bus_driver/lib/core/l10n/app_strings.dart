import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppStrings {
  AppStrings(this.language);
  final String language;
  static Map<String, dynamic> _design = {}, _phase2 = {};
  static Future<void> load() async {
    if (_design.isNotEmpty) return;
    _phase2 = jsonDecode(
      await rootBundle.loadString('assets/l10n/phase2_strings.json'),
    );
    _design = jsonDecode(
      await rootBundle.loadString('assets/l10n/design_strings.json'),
    );
  }

  static AppStrings of(BuildContext context) =>
      AppStrings(Localizations.localeOf(context).languageCode);
  String design(String feature, String key) =>
      _design[feature]?[language]?[key]?.toString() ?? '';
  List<dynamic> list(String feature, String key) =>
      _design[feature]?[language]?[key] as List? ?? [];
  String t(String key) =>
      (_phase2[key] ?? _extra[key])?[language == 'ar' ? 1 : 0] ?? key;
  static const _extra = <String, List<String>>{
    'appName': ['Hanna Bus Driver', 'هَنّا باص للسائق'],
    'demo': [
      'Demo session · Simulated actions',
      'جلسة تجريبية · إجراءات محاكاة',
    ],
    'demoHelp': [
      'Server unavailable? Explore with ahmed.benali@mail.dz and Password123!',
      'الخادم غير متاح؟ جرّب ahmed.benali@mail.dz وكلمة المرور Password123!',
    ],
    'credentialsError': [
      'Check your driver email and password',
      'تحقق من بريد السائق وكلمة المرور',
    ],
    'driverOnly': ['A driver account is required', 'يلزم حساب سائق'],
    'codeUnknown': [
      'Student code was not found on this trip',
      'لم يتم العثور على رمز الطالب في هذه الرحلة',
    ],
    'conflict': [
      'Action unavailable for the current bus or trip',
      'الإجراء غير متاح للحافلة أو الرحلة الحالية',
    ],
    'validation': [
      'Check the required items and student eligibility',
      'تحقق من العناصر المطلوبة وأهلية الطالب',
    ],
    'rateLimit': [
      'Please wait before trying again',
      'يرجى الانتظار قبل المحاولة مجددًا',
    ],
    'serverError': [
      'Could not complete the request. Please try again.',
      'تعذر إكمال الطلب. يرجى المحاولة مجددًا.',
    ],
    'unreachable': [
      'Server unavailable. Action was not confirmed. Refresh the trip before retrying.',
      'الخادم غير متاح. لم يتم تأكيد الإجراء. حدّث الرحلة قبل إعادة المحاولة.',
    ],
    'locationDenied': [
      'Location unavailable. Enable permission and phone location services.',
      'الموقع غير متاح. فعّل الإذن وخدمات الموقع في الهاتف.',
    ],
    'locationFailed': [
      'Location update could not be sent',
      'تعذر إرسال تحديث الموقع',
    ],
    'retry': ['Retry', 'إعادة المحاولة'],
    'inspect': ['Pre trip inspection', 'فحص ما قبل الرحلة'],
    'inspectHint': [
      'Check the vehicle before confirming each item',
      'افحص الحافلة قبل تأكيد كل عنصر',
    ],
    'tires': ['Tires', 'الإطارات'],
    'brakes': ['Brakes', 'الفرامل'],
    'lights': ['Lights', 'الأضواء'],
    'fuel': ['Fuel', 'الوقود'],
    'saveInspection': ['Confirm inspection', 'تأكيد الفحص'],
    'inspected': ['Vehicle inspected', 'تم فحص الحافلة'],
    'inspectionRequired': [
      'Inspection required before departure',
      'يلزم الفحص قبل الانطلاق',
    ],
    'start': ['Start route', 'بدء الرحلة'],
    'active': ['Route in progress', 'الرحلة جارية'],
    'scheduled': ['Ready for departure', 'جاهز للانطلاق'],
    'completed': ['Trip completed', 'اكتملت الرحلة'],
    'noTrips': ['No trips assigned today', 'لا توجد رحلات مسندة اليوم'],
    'noStudents': ['No students at this stop', 'لا يوجد طلاب في هذه المحطة'],
    'bus': ['Bus', 'الحافلة'],
    'seats': ['Seats', 'مقاعد'],
    'enrolled': ['Enrolled', 'مسجلون'],
    'absent': ['Absent', 'غائب'],
    'stops': ['Stops', 'محطات'],
    'all': ['All', 'الكل'],
    'on_bus': ['On bus', 'في الحافلة'],
    'waiting': ['Waiting', 'بانتظار الصعود'],
    'at_school': ['At school', 'في المدرسة'],
    'at_home': ['At home', 'في المنزل'],
    'boarded': ['Boarding', 'الصعود'],
    'alighted': ['Alighting', 'النزول'],
    'manual': ['Enter student code', 'إدخال رمز الطالب'],
    'studentCode': ['Student code', 'رمز الطالب'],
    'confirm': ['Confirm', 'تأكيد'],
    'cameraDenied': [
      'Camera unavailable. Allow camera access or enter a student code.',
      'الكاميرا غير متاحة. اسمح بالوصول للكاميرا أو أدخل رمز الطالب.',
    ],
    'boardSuccess': ['Boarding recorded', 'تم تسجيل الصعود'],
    'alightSuccess': ['Alighting recorded', 'تم تسجيل النزول'],
    'delaySent': ['Delay alert sent', 'تم إرسال تنبيه التأخير'],
    'arrivalSent': ['Station arrival confirmed', 'تم تأكيد الوصول للمحطة'],
    'tripEnded': [
      'Safety walk confirmed and trip completed',
      'تم تأكيد فحص السلامة وإكمال الرحلة',
    ],
    'busSwitched': [
      'Bus switched. Complete a new inspection.',
      'تم تبديل الحافلة. أكمل فحصًا جديدًا.',
    ],
    'switch': ['Switch bus', 'تبديل الحافلة'],
    'available': ['Available', 'متاحة'],
    'in_service': ['In service', 'في الخدمة'],
    'workshop': ['Workshop', 'في الورشة'],
    'today': ['Today', 'اليوم'],
    'unassigned': ['Unassigned', 'غير مسندة'],
    'end': ['End trip', 'إنهاء الرحلة'],
    'walk1': [
      'All students have safely left the bus',
      'غادر جميع الطلاب الحافلة بأمان',
    ],
    'walk2': [
      'Inspected every row and under every seat to the rear',
      'فحصت كل صف وتحت كل مقعد حتى الخلف',
    ],
    'walk3': [
      'Emergency exits and side windows are closed',
      'مخارج الطوارئ والنوافذ الجانبية مغلقة',
    ],
    'safeEnd': [
      'Confirm all clear and finish trip',
      'تأكيد خلو الحافلة وإنهاء الرحلة',
    ],
    'traffic': ['Traffic', 'ازدحام'],
    'breakdown': ['Breakdown', 'عطل'],
    'weather': ['Weather', 'طقس'],
    'other': ['Other', 'أخرى'],
    'minutes': ['Minutes', 'دقائق'],
    'broadcast': ['Broadcast delay alert', 'إرسال تنبيه التأخير'],
    'sosSent': ['SOS alert sent', 'تم إرسال نداء الطوارئ'],
    'sosHint': [
      'Hold for 3 seconds to send an alert. Call emergency services directly when needed.',
      'اضغط لمدة 3 ثوانٍ لإرسال تنبيه. اتصل بخدمات الطوارئ مباشرة عند الحاجة.',
    ],
    'sosLocation': [
      'Your latest available location is included in the alert',
      'يُرفق آخر موقع متاح لك بالتنبيه',
    ],
    'release': ['Release to cancel', 'ارفع إصبعك للإلغاء'],
    'callFailed': ['Could not open the phone dialer', 'تعذر فتح لوحة الاتصال'],
    'schoolUnavailable': [
      'School phone number is not provided by the API',
      'رقم هاتف المدرسة غير متوفر في الواجهة البرمجية',
    ],
    'signOut': ['Sign out', 'تسجيل الخروج'],
    'appearance': ['Appearance', 'المظهر'],
    'light': ['Light', 'فاتح'],
    'dark': ['Dark', 'داكن'],
    'mustard': ['Mustard', 'خردلي'],
    'tealGray': ['Teal Gray', 'رمادي مخضر'],
    'ocean': ['Ocean Blue', 'أزرق المحيط'],
    'refresh': ['Refresh trip data', 'تحديث بيانات الرحلة'],
    'routeOverview': ['Route overview', 'نظرة عامة على المسار'],
    'routeHint': [
      'Select a stop to confirm arrival. The map shows the assigned route.',
      'اختر محطة لتأكيد الوصول. تعرض الخريطة المسار المسند.',
    ],
    'current': ['Current stop', 'المحطة الحالية'],
    'stopCompleted': ['Stop completed', 'اكتملت المحطة'],
    'mapUnavailable': [
      'Map coordinates unavailable. Showing stop diagram.',
      'إحداثيات الخريطة غير متاحة. يظهر مخطط المحطات.',
    ],
    'recenterMap': ['Recenter map', 'توسيط الخريطة'],
    'driverPosition': ['Your location', 'موقعك'],
    'upcoming': ['Upcoming', 'قادمة'],
    'scanHint': [
      'Scan a student QR pass or enter their code',
      'امسح بطاقة الطالب أو أدخل رمزه',
    ],
  };
}
