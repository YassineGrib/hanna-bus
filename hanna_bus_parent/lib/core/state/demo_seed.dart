import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../theme/hanna_tokens.dart';
import 'models.dart';

abstract final class DemoSeed {
  static const List<LatLng> demoRoutePoints = [
    LatLng(36.7760, 3.0598),
    LatLng(36.7695, 3.0560),
    LatLng(36.7640, 3.0525),
    LatLng(36.7580, 3.0480),
    LatLng(36.7538, 3.0520),
    LatLng(36.7495, 3.0555),
    LatLng(36.7460, 3.0570),
    LatLng(36.7420, 3.0610),
    LatLng(36.7385, 3.0650),
    LatLng(36.7350, 3.0680),
  ];
  static const ParentUser demoUser = ParentUser(
    id: '1',
    name: 'Karim Mansouri',
    email: 'k.mansouri@mail.dz',
    phone: '+213 551 22 33 44',
    backupPhone: '+213 551 99 88 77',
    primaryBusStop: 'Hydra North - Stop 04',
    avatarPreset: 'karim',
    palette: HannaPalette.mustard,
    brightness: Brightness.light,
    locale: Locale('en'),
  );

  static const List<ChildProfile> children = [
    ChildProfile(
      id: 'c-youssef',
      studentCode: 'HB-304',
      fullName: 'Youssef Mansouri',
      birthDate: '2016-05-18',
      nationalId: '101605180041',
      stage: 'Primary',
      schoolName: 'El-Feth International School',
      grade: 'Grade 4',
      classRoom: 'Room B-12',
      homeroomTeacher: 'Mme. Nadia Haddad',
      transportCoordinator: 'Mr. Tariq Saidi',
      dismissalRule: 'Authorized Parent QR Only',
      busNumber: '04',
      seatNumber: 'A-04',
      stopName: 'Hydra North - Stop 04',
      stopTime: '07:25',
      returnTime: '15:30',
      transitStatus: 'on_bus',
      avatarPreset: 'youssef',
      bloodType: 'O+',
      insuranceNumber: 'CNAS-DZ-884210',
      allergies: 'Peanuts (Mild)',
      chronicConditions: 'None reported',
      firstAidProtocol: 'Antihistamine kit kept with escort',
      pediatricianName: 'Dr. Samira Khelifi',
      pediatricianPhone: '+213 551 88 99 00',
      schedule: {
        'sun': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
        'mon': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
        'tue': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
        'wed': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
        'thu': ScheduleSlot(pickup: '07:25', dropoff: '14:30'),
      },
      etaMinutes: 6,
      stopsAway: 2,
      progress: 0.68,
      driverName: 'Ahmed Benali',
      driverPhone: '+213 550 77 88 99',
    ),
    ChildProfile(
      id: 'c-amina',
      studentCode: 'HB-208',
      fullName: 'Amina Mansouri',
      birthDate: '2019-09-02',
      nationalId: '101909020112',
      stage: 'Primary',
      schoolName: 'El-Feth International School',
      grade: 'Grade 1',
      classRoom: 'Room A-03',
      homeroomTeacher: 'Mme. Salma Cherif',
      transportCoordinator: 'Mr. Tariq Saidi',
      dismissalRule: 'Escorted Handover at Gate 2',
      busNumber: '04',
      seatNumber: 'A-05',
      stopName: 'Hydra North - Stop 04',
      stopTime: '07:25',
      returnTime: '15:30',
      transitStatus: 'arrived',
      avatarPreset: 'amina',
      bloodType: 'A+',
      insuranceNumber: 'CNAS-DZ-884211',
      allergies: 'None reported',
      chronicConditions: 'None reported',
      firstAidProtocol: 'Standard school nurse protocol',
      pediatricianName: 'Dr. Samira Khelifi',
      pediatricianPhone: '+213 551 88 99 00',
      schedule: {
        'sun': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
        'mon': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
        'tue': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
        'wed': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
        'thu': ScheduleSlot(pickup: '07:25', dropoff: '14:30'),
      },
      etaMinutes: 0,
      stopsAway: 0,
      progress: 1.0,
      driverName: 'Ahmed Benali',
      driverPhone: '+213 550 77 88 99',
    ),
    ChildProfile(
      id: 'c-rayan',
      studentCode: 'HB-105',
      fullName: 'Rayan Mansouri',
      birthDate: '2021-02-14',
      nationalId: '102102140065',
      stage: 'Kindergarten',
      schoolName: 'Les Oliviers Nursery & Prep',
      grade: 'KG 2',
      classRoom: 'Sunshine Room',
      homeroomTeacher: 'Mme. Leila Mansour',
      transportCoordinator: 'Mr. Mourad Ziani',
      dismissalRule: 'Parent or Listed Guardian QR',
      busNumber: '02',
      seatNumber: 'B-02',
      stopName: 'El Biar Square - Stop 02',
      stopTime: '07:35',
      returnTime: '15:00',
      transitStatus: 'at_home',
      avatarPreset: 'rayan',
      bloodType: 'O+',
      insuranceNumber: 'CNAS-DZ-884212',
      allergies: 'Seasonal dust sensitivity',
      chronicConditions: 'None reported',
      firstAidProtocol: 'Keep windows filtered during spring',
      pediatricianName: 'Dr. Samira Khelifi',
      pediatricianPhone: '+213 551 88 99 00',
      schedule: {
        'sun': ScheduleSlot(pickup: '07:35', dropoff: '15:00'),
        'mon': ScheduleSlot(pickup: '07:35', dropoff: '15:00'),
        'tue': ScheduleSlot(pickup: '07:35', dropoff: '15:00'),
        'wed': ScheduleSlot(pickup: '07:35', dropoff: '15:00'),
        'thu': ScheduleSlot(pickup: '07:35', dropoff: '14:00'),
      },
      etaMinutes: 14,
      stopsAway: 4,
      progress: 0.25,
      driverName: 'Rachid Amrani',
      driverPhone: '+213 550 61 44 22',
    ),
  ];

  static const ChildProfile linkableLina = ChildProfile(
    id: 'c-lina',
    studentCode: 'HB-2026-9911',
    fullName: 'Lina Mansouri',
    birthDate: '2018-11-21',
    nationalId: '101811210099',
    stage: 'Primary',
    schoolName: 'El-Feth International School',
    grade: 'Grade 2',
    classRoom: 'Room A-08',
    homeroomTeacher: 'Mme. Nadia Haddad',
    transportCoordinator: 'Mr. Tariq Saidi',
    dismissalRule: 'Authorized Parent QR Only',
    busNumber: '04',
    seatNumber: 'A-06',
    stopName: 'Hydra North - Stop 04',
    stopTime: '07:25',
    returnTime: '15:30',
    transitStatus: 'at_home',
    avatarPreset: 'amina',
    bloodType: 'O+',
    insuranceNumber: 'CNAS-DZ-884219',
    allergies: 'None reported',
    chronicConditions: 'None reported',
    firstAidProtocol: 'Standard school nurse protocol',
    pediatricianName: 'Dr. Samira Khelifi',
    pediatricianPhone: '+213 551 88 99 00',
    schedule: {
      'sun': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
      'mon': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
      'tue': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
      'wed': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
      'thu': ScheduleSlot(pickup: '07:25', dropoff: '14:30'),
    },
    etaMinutes: 6,
    stopsAway: 2,
    progress: 0.68,
    driverName: 'Ahmed Benali',
    driverPhone: '+213 550 77 88 99',
  );

  static ActiveTripData activeTrip(Locale locale) {
    final ar = locale.languageCode == 'ar';
    final fr = locale.languageCode == 'fr';
    return ActiveTripData(
      id: 'trip-04-am',
      busNumber: '04',
      routeName: ar
          ? 'حيدرة شمال - مدرسة الفتح'
          : (fr ? 'Hydra Nord - Ecole El-Feth' : 'Hydra North - El-Feth School'),
      driverName: 'Ahmed Benali',
      driverPhone: '+213 550 77 88 99',
      vehicleModel: 'Mercedes Sprinter 2024',
      plateNumber: '00412-116-16',
      isMorning: true,
      etaMinutes: 6,
      distanceKm: 1.8,
      speedKmh: 34,
      progress: 0.68,
      onboardCount: 14,
      capacity: 22,
      currentStreet: 'Rue Didouche Mourad',
      status: 'en_route',
      location: null,
      routePoints: demoRoutePoints,
      stations: [
        TripStation(
          id: 1,
          sortOrder: 1,
          name: ar ? 'ساحة الشهداء' : (fr ? 'Place des Martyrs' : 'Martyrs Square'),
          scheduledTime: '07:10',
          subtitle: ar ? 'غادرت في الموعد' : (fr ? 'Depart a l heure' : 'Departed on schedule'),
          status: 'passed',
          lat: 36.7760,
          lng: 3.0598,
        ),
        TripStation(
          id: 2,
          sortOrder: 2,
          name: ar ? 'حيدرة شمال - محطة 04' : (fr ? 'Hydra Nord - Arret 04' : 'Hydra North - Stop 04'),
          scheduledTime: '07:25',
          subtitle: ar ? 'تم مسح صعود يوسف' : (fr ? 'Embarquement Youssef scanne' : 'Youssef QR scanned'),
          status: 'passed',
          lat: 36.7580,
          lng: 3.0480,
        ),
        TripStation(
          id: 3,
          sortOrder: 3,
          name: ar ? 'المرادية العالية' : (fr ? 'El Mouradia Haut' : 'El Mouradia Upper'),
          scheduledTime: '07:38',
          subtitle: ar ? 'المحطة الحالية' : (fr ? 'Arret en cours' : 'Approaching stop now'),
          status: 'current',
          lat: 36.7460,
          lng: 3.0570,
        ),
        TripStation(
          id: 4,
          sortOrder: 4,
          name: ar ? 'بوابة مدرسة الفتح' : (fr ? 'Portail Ecole El-Feth' : 'El-Feth Main Gate'),
          scheduledTime: '07:50',
          subtitle: ar ? 'الوصول المتوقع خلال 6 د' : (fr ? 'Arrivee prevue dans 6 min' : 'Estimated arrival in 6 min'),
          status: 'upcoming',
          lat: 36.7350,
          lng: 3.0680,
        ),
      ],
    );
  }

  static List<TripHistorySummary> tripHistory(Locale locale) {
    final ar = locale.languageCode == 'ar';
    final fr = locale.languageCode == 'fr';
    final today = ar ? 'اليوم' : (fr ? 'Aujourd hui' : 'Today');
    final yesterday = ar ? 'أمس' : (fr ? 'Hier' : 'Yesterday');

    return [
      TripHistorySummary(
        id: '9042',
        childId: 'c-youssef',
        busNumber: '04',
        period: 'morning',
        tripDate: '2026-11-10',
        dateGroup: today,
        departureTime: '07:25',
        arrivalTime: '07:51',
        durationMinutes: 26,
        distanceKm: 6.4,
        avgSpeedKmh: 31,
        statusCode: 'arrived',
        delayMinutes: 0,
        driverName: 'Ahmed Benali',
        routePoints: demoRoutePoints,
        qrAudit: const [
          {'event': 'Boarded Bus 04', 'time': '07:25', 'gate': 'Hydra North'},
          {'event': 'School Gate Scan', 'time': '07:51', 'gate': 'Gate 1'},
        ],
      ),
      TripHistorySummary(
        id: '9041',
        childId: 'c-youssef',
        busNumber: '04',
        period: 'return',
        tripDate: '2026-11-09',
        dateGroup: yesterday,
        departureTime: '15:30',
        arrivalTime: '16:04',
        durationMinutes: 34,
        distanceKm: 6.5,
        avgSpeedKmh: 27,
        statusCode: 'delayed',
        delayMinutes: 4,
        driverName: 'Ahmed Benali',
        routePoints: demoRoutePoints,
        qrAudit: const [
          {'event': 'Boarded Bus 04', 'time': '15:32', 'gate': 'School Bay'},
          {'event': 'Parent QR Handover', 'time': '16:04', 'gate': 'Hydra North'},
        ],
      ),
      TripHistorySummary(
        id: '9039',
        childId: 'c-amina',
        busNumber: '04',
        period: 'morning',
        tripDate: '2026-11-09',
        dateGroup: yesterday,
        departureTime: '07:25',
        arrivalTime: '07:49',
        durationMinutes: 24,
        distanceKm: 6.4,
        avgSpeedKmh: 33,
        statusCode: 'arrived',
        delayMinutes: 0,
        driverName: 'Ahmed Benali',
        routePoints: demoRoutePoints,
        qrAudit: const [
          {'event': 'Boarded Bus 04', 'time': '07:25', 'gate': 'Hydra North'},
          {'event': 'School Gate Scan', 'time': '07:49', 'gate': 'Gate 2'},
        ],
      ),
    ];
  }

  static AttendanceAnalyticsData analytics(String childId, String childName) {
    return AttendanceAnalyticsData(
      childId: childId,
      childName: childName,
      monthLabel: 'November 2026',
      completed: 38,
      absences: 1,
      missedQr: 0,
      onTimeRate: 98.4,
      qrHandoffRate: 100.0,
      weeklyRegularity: const [
        WeeklyRegularityPoint(day: 'sun', morning: 1.0, returnTrip: 0.96),
        WeeklyRegularityPoint(day: 'mon', morning: 1.0, returnTrip: 1.0),
        WeeklyRegularityPoint(day: 'tue', morning: 0.95, returnTrip: 0.92),
        WeeklyRegularityPoint(day: 'wed', morning: 1.0, returnTrip: 0.55),
        WeeklyRegularityPoint(day: 'thu', morning: 0.98, returnTrip: 0.96),
      ],
    );
  }

  static List<SafetyNotificationItem> notifications(Locale locale) {
    final ar = locale.languageCode == 'ar';
    final fr = locale.languageCode == 'fr';
    final today = ar ? 'اليوم' : (fr ? 'Aujourd hui' : 'Today');
    final yesterday = ar ? 'أمس' : (fr ? 'Hier' : 'Yesterday');

    return [
      SafetyNotificationItem(
        id: 1,
        childId: 'c-youssef',
        category: 'boarding',
        title: ar
            ? 'صعد يوسف إلى الحافلة 04'
            : (fr ? 'Youssef a monte dans le Bus 04' : 'Youssef boarded Bus 04'),
        body: ar
            ? 'تم التحقق عبر رمز QR في محطة حيدرة شمال.'
            : (fr
                ? 'Embarquement verifie par QR a Hydra Nord.'
                : 'Boarding QR verified at Hydra North - Stop 04.'),
        dayGroup: today,
        timeLabel: '07:25',
        isRead: false,
      ),
      SafetyNotificationItem(
        id: 2,
        childId: 'c-amina',
        category: 'arrival',
        title: ar
            ? 'وصلت أمينة إلى المدرسة بأمان'
            : (fr ? 'Amina est arrivee a l ecole' : 'Amina arrived safely at school'),
        body: ar
            ? 'تم تسجيل الوصول عند البوابة 2 مع المرافقة.'
            : (fr
                ? 'Presence enregistree au portail 2 avec escorte.'
                : 'Checked in at El-Feth Gate 2 with bus escort.'),
        dayGroup: today,
        timeLabel: '07:49',
        isRead: false,
      ),
      SafetyNotificationItem(
        id: 3,
        childId: 'c-youssef',
        category: 'delay',
        title: ar
            ? 'تحديث طفيف في وقت العودة'
            : (fr ? 'Leger ajustement sur le trajet retour' : 'Minor traffic delay on afternoon route'),
        body: ar
            ? 'تأخير 4 دقائق بسبب حركة المرور في المرادية.'
            : (fr
                ? 'Retard de 4 min du au trafic sur El Mouradia.'
                : 'Bus 04 is running 4 minutes behind on Rue Didouche.'),
        dayGroup: yesterday,
        timeLabel: '15:52',
        isRead: true,
      ),
    ];
  }

  static List<SchoolBulletinItem> bulletins(Locale locale) {
    final ar = locale.languageCode == 'ar';
    final fr = locale.languageCode == 'fr';
    return [
      SchoolBulletinItem(
        id: 1,
        tag: 'schedule',
        title: ar
            ? 'توقيت يوم الخميس المخفض'
            : (fr ? 'Horaire reduit du jeudi' : 'Thursday Early Dismissal Schedule'),
        body: ar
            ? 'تغادر حافلات المسار الصباحي المدرسة الساعة 14:30 كل خميس طوال الشهر.'
            : (fr
                ? 'Les bus quittent l ecole a 14h30 chaque jeudi ce mois-ci.'
                : 'Afternoon departure moves to 14:30 every Thursday during November.'),
        publishedAt: '2026-11-10',
      ),
      SchoolBulletinItem(
        id: 2,
        tag: 'safety',
        title: ar
            ? 'فحص السلامة الشهري لأسطول حنّة باص'
            : (fr ? 'Inspection securite mensuelle de la flotte' : 'Monthly Fleet Safety Inspection Passed'),
        body: ar
            ? 'جميع أحزمة الأمان وأجهزة المسح الحراري ورموز الاستجابة مفعلة على الحافلة 04 و 02.'
            : (fr
                ? 'Ceintures, scanners QR et balises GPS verifies sur les Bus 04 et 02.'
                : 'Seatbelts, live GPS beacons, and QR scanners cleared safety checks on Buses 04 and 02.'),
        publishedAt: '2026-11-08',
      ),
    ];
  }

  static const List<EmergencyContactItem> emergencyContacts = [
    EmergencyContactItem(
      id: 'sos-driver-04',
      type: 'driver',
      title: LocalizedText(
        en: 'Call Bus 04 Driver',
        ar: 'اتصال بسائق الحافلة 04',
        fr: 'Appeler chauffeur Bus 04',
      ),
      subtitle: LocalizedText(
        en: 'Ahmed Benali, Direct cab phone',
        ar: 'أحمد بن علي، هاتف المقصورة المباشر',
        fr: 'Ahmed Benali, Ligne directe cabine',
      ),
      phone: '+213 550 77 88 99',
      isUrgent: false,
    ),
    EmergencyContactItem(
      id: 'sos-supervisor',
      type: 'supervisor',
      title: LocalizedText(
        en: 'Transport Supervisor',
        ar: 'مشرف النقل المدرسي',
        fr: 'Superviseur transport',
      ),
      subtitle: LocalizedText(
        en: 'Central safety desk, Priority line',
        ar: 'مكتب الأمان المركزي، خط أولوية',
        fr: 'Bureau securite central, Ligne prioritaire',
      ),
      phone: '+213 550 00 11 22',
      isUrgent: false,
    ),
    EmergencyContactItem(
      id: 'sos-school-gate',
      type: 'school',
      title: LocalizedText(
        en: 'El-Feth School Gate Desk',
        ar: 'بوابة مدرسة الفتح',
        fr: 'Accueil Portail El-Feth',
      ),
      subtitle: LocalizedText(
        en: 'Mr. Tariq Saidi, Dismissal office',
        ar: 'السيد طارق سعيدي، مكتب الاستلام',
        fr: 'M. Tariq Saidi, Bureau de sortie',
      ),
      phone: '+213 21 60 44 55',
      isUrgent: false,
    ),
    EmergencyContactItem(
      id: 'sos-dispatch',
      type: 'sos',
      title: LocalizedText(
        en: 'Emergency 24/7 Dispatch',
        ar: 'طوارئ الإرسال 24/7',
        fr: 'Urgence Dispatch 24/7',
      ),
      subtitle: LocalizedText(
        en: 'Immediate safety alert and fleet override',
        ar: 'تنبيه أمان فوري وتدخل الأسطول',
        fr: 'Alerte securite immediate et intervention flotte',
      ),
      phone: '1044',
      isUrgent: true,
    ),
  ];

  static List<DriverMessageItem> driverMessages(Locale locale) {
    final ar = locale.languageCode == 'ar';
    final fr = locale.languageCode == 'fr';
    return [
      DriverMessageItem(
        id: 'msg-1',
        direction: 'parent_to_driver',
        message: ar
            ? 'صباح الخير عمي أحمد، نحن في المحطة الآن'
            : (fr
                ? 'Bonjour M. Ahmed, nous sommes a l arret'
                : 'Good morning Mr. Ahmed, we are at the stop'),
        createdAt: '2026-11-21T07:12:00Z',
        readAt: '2026-11-21T07:13:00Z',
      ),
      DriverMessageItem(
        id: 'msg-2',
        direction: 'driver_to_parent',
        message: ar
            ? 'صباح النور، سأصل خلال 3 دقائق تقريبًا'
            : (fr
                ? 'Bonjour, j arrive dans environ 3 minutes'
                : 'Good morning, arriving in about 3 minutes'),
        createdAt: '2026-11-21T07:14:00Z',
        readAt: '2026-11-21T07:15:00Z',
      ),
      DriverMessageItem(
        id: 'msg-3',
        direction: 'parent_to_driver',
        message: ar
            ? 'شكرا لك، يوسف جاهز'
            : (fr
                ? 'Merci, Youssef est pret'
                : 'Thank you, Youssef is ready'),
        createdAt: '2026-11-21T07:16:00Z',
        readAt: '2026-11-21T07:17:00Z',
      ),
      DriverMessageItem(
        id: 'msg-4',
        direction: 'driver_to_parent',
        message: ar
            ? 'تم صعود يوسف بسلام وهو جالس في مقعده'
            : (fr
                ? 'Youssef est bien monte et assis a sa place'
                : 'Youssef has safely boarded and is in his seat'),
        createdAt: '2026-11-21T07:22:00Z',
        readAt: null,
      ),
    ];
  }
}
