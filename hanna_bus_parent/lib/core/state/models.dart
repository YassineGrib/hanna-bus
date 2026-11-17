import 'package:flutter/material.dart';
import '../theme/hanna_tokens.dart';

class LocalizedText {
  const LocalizedText({
    required this.en,
    required this.ar,
    required this.fr,
  });

  final String en;
  final String ar;
  final String fr;

  factory LocalizedText.same(String value) {
    return LocalizedText(en: value, ar: value, fr: value);
  }

  factory LocalizedText.fromJson(Map<String, dynamic> json, String keyPrefix) {
    final base = json[keyPrefix]?.toString();
    final en = json['${keyPrefix}_en']?.toString() ?? base ?? '';
    final ar = json['${keyPrefix}_ar']?.toString() ?? base ?? en;
    final fr = json['${keyPrefix}_fr']?.toString() ?? base ?? en;
    return LocalizedText(en: en, ar: ar, fr: fr);
  }

  String resolve(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return ar.isNotEmpty ? ar : en;
      case 'fr':
        return fr.isNotEmpty ? fr : en;
      default:
        return en;
    }
  }
}

class ParentUser {
  const ParentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.backupPhone = '',
    required this.primaryBusStop,
    this.avatarPreset = 'karim',
    required this.palette,
    required this.brightness,
    required this.locale,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String backupPhone;
  final String primaryBusStop;
  final String avatarPreset;
  final HannaPalette palette;
  final Brightness brightness;
  final Locale locale;

  factory ParentUser.fromJson(Map<String, dynamic> json) {
    final brightnessStr = json['brightness_mode']?.toString() ?? 'light';
    final localeStr = json['locale']?.toString() ?? 'en';
    return ParentUser(
      id: (json['id'] ?? '1').toString(),
      name: (json['name'] ?? 'Karim Mansouri').toString(),
      email: (json['email'] ?? 'k.mansouri@mail.dz').toString(),
      phone: (json['phone'] ?? '').toString(),
      backupPhone: (json['backup_phone'] ?? '').toString(),
      primaryBusStop: (json['primary_bus_stop'] ?? 'Hydra North - Stop 04').toString(),
      avatarPreset: (json['avatar_preset'] ?? 'karim').toString(),
      palette: HannaPalette.fromApi(json['theme_palette']?.toString()),
      brightness: brightnessStr == 'dark' ? Brightness.dark : Brightness.light,
      locale: Locale(localeStr),
    );
  }

  ParentUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? backupPhone,
    String? primaryBusStop,
    String? avatarPreset,
    HannaPalette? palette,
    Brightness? brightness,
    Locale? locale,
  }) {
    return ParentUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      backupPhone: backupPhone ?? this.backupPhone,
      primaryBusStop: primaryBusStop ?? this.primaryBusStop,
      avatarPreset: avatarPreset ?? this.avatarPreset,
      palette: palette ?? this.palette,
      brightness: brightness ?? this.brightness,
      locale: locale ?? this.locale,
    );
  }
}

class ScheduleSlot {
  const ScheduleSlot({required this.pickup, required this.dropoff});
  final String pickup;
  final String dropoff;

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      pickup: (json['pickup'] ?? '07:25').toString(),
      dropoff: (json['dropoff'] ?? '15:30').toString(),
    );
  }
}

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.birthDate,
    required this.nationalId,
    required this.stage,
    required this.schoolName,
    required this.grade,
    required this.classRoom,
    required this.homeroomTeacher,
    required this.transportCoordinator,
    required this.dismissalRule,
    required this.busNumber,
    required this.seatNumber,
    required this.stopName,
    required this.stopTime,
    required this.returnTime,
    required this.transitStatus,
    required this.avatarPreset,
    required this.bloodType,
    required this.insuranceNumber,
    required this.allergies,
    required this.chronicConditions,
    required this.firstAidProtocol,
    required this.pediatricianName,
    required this.pediatricianPhone,
    required this.schedule,
    this.etaMinutes = 6,
    this.stopsAway = 2,
    this.progress = 0.68,
    this.driverName = 'Ahmed Benali',
    this.driverPhone = '+213 550 77 88 99',
  });

  final String id;
  final String studentCode;
  final String fullName;
  final String birthDate;
  final String nationalId;
  final String stage;
  final String schoolName;
  final String grade;
  final String classRoom;
  final String homeroomTeacher;
  final String transportCoordinator;
  final String dismissalRule;
  final String busNumber;
  final String seatNumber;
  final String stopName;
  final String stopTime;
  final String returnTime;
  final String transitStatus;
  final String avatarPreset;
  final String bloodType;
  final String insuranceNumber;
  final String allergies;
  final String chronicConditions;
  final String firstAidProtocol;
  final String pediatricianName;
  final String pediatricianPhone;
  final Map<String, ScheduleSlot> schedule;
  final int etaMinutes;
  final int stopsAway;
  final double progress;
  final String driverName;
  final String driverPhone;

  bool get isAbsentToday => transitStatus == 'absent';

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'H';
  }

  factory ChildProfile.fromJson(Map<String, dynamic> raw) {
    final json = raw.containsKey('data') && raw['data'] is Map<String, dynamic>
        ? raw['data'] as Map<String, dynamic>
        : raw;
    final rawSchedule = json['schedule'];
    final Map<String, ScheduleSlot> parsedSchedule = {};
    if (rawSchedule is Map) {
      rawSchedule.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          parsedSchedule[k.toString()] = ScheduleSlot.fromJson(v);
        } else if (v is Map) {
          parsedSchedule[k.toString()] = ScheduleSlot.fromJson(Map<String, dynamic>.from(v));
        }
      });
    }
    final status = (json['transit_status'] ?? 'at_home').toString();
    return ChildProfile(
      id: (json['id'] ?? '').toString(),
      studentCode: (json['student_code'] ?? 'HB-304').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      birthDate: (json['birth_date'] ?? '2017-04-12').toString(),
      nationalId: (json['national_id'] ?? '101704120089').toString(),
      stage: (json['stage'] ?? 'Primary').toString(),
      schoolName: (json['school_name'] ?? 'El-Feth International School').toString(),
      grade: (json['grade'] ?? 'Grade 4').toString(),
      classRoom: (json['class_room'] ?? 'Room B-12').toString(),
      homeroomTeacher: (json['homeroom_teacher'] ?? 'Mme. Nadia Haddad').toString(),
      transportCoordinator: (json['transport_coordinator'] ?? 'Mr. Tariq Saidi').toString(),
      dismissalRule: (json['dismissal_rule'] ?? 'Authorized Parent QR Only').toString(),
      busNumber: (json['bus_number'] ?? '04').toString(),
      seatNumber: (json['seat_number'] ?? 'A-04').toString(),
      stopName: (json['stop_name'] ?? 'Hydra North - Stop 04').toString(),
      stopTime: (json['stop_time'] ?? '07:25').toString(),
      returnTime: (json['return_time'] ?? '15:30').toString(),
      transitStatus: status,
      avatarPreset: (json['avatar_preset'] ?? 'child').toString(),
      bloodType: (json['blood_type'] ?? 'O+').toString(),
      insuranceNumber: (json['insurance_number'] ?? 'CNAS-DZ-884210').toString(),
      allergies: (json['allergies'] ?? 'None reported').toString(),
      chronicConditions: (json['chronic_conditions'] ?? 'None').toString(),
      firstAidProtocol: (json['first_aid_protocol'] ?? 'Standard school nurse protocol').toString(),
      pediatricianName: (json['pediatrician_name'] ?? 'Dr. Samira Khelifi').toString(),
      pediatricianPhone: (json['pediatrician_phone'] ?? '+213 551 88 99 00').toString(),
      schedule: parsedSchedule.isNotEmpty
          ? parsedSchedule
          : const {
              'sun': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
              'mon': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
              'tue': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
              'wed': ScheduleSlot(pickup: '07:25', dropoff: '15:30'),
              'thu': ScheduleSlot(pickup: '07:25', dropoff: '14:30'),
            },
      etaMinutes: (json['eta_minutes'] as num?)?.toInt() ?? 6,
      stopsAway: (json['stops_away'] as num?)?.toInt() ?? 2,
      progress: (json['progress'] as num?)?.toDouble() ?? (status == 'arrived' ? 1.0 : 0.68),
      driverName: (json['driver_name'] ?? 'Ahmed Benali').toString(),
      driverPhone: (json['driver_phone'] ?? '+213 550 77 88 99').toString(),
    );
  }

  ChildProfile copyWith({
    String? studentCode,
    String? fullName,
    String? schoolName,
    String? grade,
    String? busNumber,
    String? seatNumber,
    String? stopName,
    String? stopTime,
    String? returnTime,
    String? transitStatus,
    String? allergies,
    String? chronicConditions,
    String? firstAidProtocol,
    String? pediatricianName,
    String? pediatricianPhone,
    String? dismissalRule,
  }) {
    return ChildProfile(
      id: id,
      studentCode: studentCode ?? this.studentCode,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate,
      nationalId: nationalId,
      stage: stage,
      schoolName: schoolName ?? this.schoolName,
      grade: grade ?? this.grade,
      classRoom: classRoom,
      homeroomTeacher: homeroomTeacher,
      transportCoordinator: transportCoordinator,
      dismissalRule: dismissalRule ?? this.dismissalRule,
      busNumber: busNumber ?? this.busNumber,
      seatNumber: seatNumber ?? this.seatNumber,
      stopName: stopName ?? this.stopName,
      stopTime: stopTime ?? this.stopTime,
      returnTime: returnTime ?? this.returnTime,
      transitStatus: transitStatus ?? this.transitStatus,
      avatarPreset: avatarPreset,
      bloodType: bloodType,
      insuranceNumber: insuranceNumber,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      firstAidProtocol: firstAidProtocol ?? this.firstAidProtocol,
      pediatricianName: pediatricianName ?? this.pediatricianName,
      pediatricianPhone: pediatricianPhone ?? this.pediatricianPhone,
      schedule: schedule,
      etaMinutes: etaMinutes,
      stopsAway: stopsAway,
      progress: progress,
      driverName: driverName,
      driverPhone: driverPhone,
    );
  }
}

class TripStation {
  const TripStation({
    required this.id,
    required this.sortOrder,
    required this.name,
    required this.scheduledTime,
    required this.subtitle,
    required this.status,
  });

  final int id;
  final int sortOrder;
  final String name;
  final String scheduledTime;
  final String subtitle;
  final String status; // passed | current | upcoming

  factory TripStation.fromJson(Map<String, dynamic> json) {
    return TripStation(
      id: (json['id'] as num?)?.toInt() ?? 0,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      scheduledTime: (json['scheduled_time'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      status: (json['status'] ?? 'upcoming').toString(),
    );
  }
}

class ActiveTripData {
  const ActiveTripData({
    required this.id,
    required this.busNumber,
    required this.routeName,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleModel,
    required this.plateNumber,
    required this.isMorning,
    required this.etaMinutes,
    required this.distanceKm,
    required this.speedKmh,
    required this.progress,
    required this.onboardCount,
    required this.capacity,
    required this.currentStreet,
    required this.status,
    required this.stations,
  });

  final String id;
  final String busNumber;
  final String routeName;
  final String driverName;
  final String driverPhone;
  final String vehicleModel;
  final String plateNumber;
  final bool isMorning;
  final int etaMinutes;
  final double distanceKm;
  final int speedKmh;
  final double progress;
  final int onboardCount;
  final int capacity;
  final String currentStreet;
  final String status;
  final List<TripStation> stations;

  factory ActiveTripData.fromJson(Map<String, dynamic> json) {
    final list = (json['stations'] as List? ?? [])
        .whereType<Map>()
        .map((e) => TripStation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return ActiveTripData(
      id: (json['id'] ?? 'trip-04-am').toString(),
      busNumber: (json['bus_number'] ?? '04').toString(),
      routeName: (json['route_name'] ?? 'Hydra North - El-Feth').toString(),
      driverName: (json['driver_name'] ?? 'Ahmed Benali').toString(),
      driverPhone: (json['driver_phone'] ?? '+213 550 77 88 99').toString(),
      vehicleModel: (json['vehicle_model'] ?? 'Mercedes Sprinter 2024').toString(),
      plateNumber: (json['plate_number'] ?? '00412-116-16').toString(),
      isMorning: json['is_morning'] == true || json['is_morning'] == 1,
      etaMinutes: (json['eta_minutes'] as num?)?.toInt() ?? 6,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 1.8,
      speedKmh: (json['speed_kmh'] as num?)?.toInt() ?? 34,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.68,
      onboardCount: (json['onboard_count'] as num?)?.toInt() ?? 14,
      capacity: (json['capacity'] as num?)?.toInt() ?? 22,
      currentStreet: (json['current_street'] ?? 'Rue Didouche Mourad').toString(),
      status: (json['status'] ?? 'en_route').toString(),
      stations: list,
    );
  }
}

class TripHistorySummary {
  const TripHistorySummary({
    required this.id,
    required this.childId,
    required this.busNumber,
    required this.period,
    required this.tripDate,
    required this.dateGroup,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.distanceKm,
    required this.avgSpeedKmh,
    required this.statusCode,
    required this.delayMinutes,
    required this.driverName,
    this.driverRating = 4.9,
    this.vehicleModel = 'Mercedes Sprinter 2024',
    this.waypoints = const [
      Offset(0.14, 0.78),
      Offset(0.32, 0.62),
      Offset(0.55, 0.45),
      Offset(0.84, 0.22),
    ],
    this.qrAudit = const [],
  });

  final String id;
  final String childId;
  final String busNumber;
  final String period; // morning | return
  final String tripDate;
  final String dateGroup;
  final String departureTime;
  final String arrivalTime;
  final int durationMinutes;
  final double distanceKm;
  final int avgSpeedKmh;
  final String statusCode;
  final int delayMinutes;
  final String driverName;
  final double driverRating;
  final String vehicleModel;
  final List<Offset> waypoints;
  final List<Map<String, dynamic>> qrAudit;

  factory TripHistorySummary.fromJson(Map<String, dynamic> json) {
    final rawWaypoints = json['waypoints'] as List? ?? [];
    final pts = <Offset>[];
    for (final item in rawWaypoints) {
      if (item is List && item.length >= 2) {
        pts.add(Offset(
          (item[0] as num).toDouble(),
          (item[1] as num).toDouble(),
        ));
      }
    }
    final rawQr = (json['qr_audit'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return TripHistorySummary(
      id: (json['id'] ?? '').toString(),
      childId: (json['child_id'] ?? '').toString(),
      busNumber: (json['bus_number'] ?? '04').toString(),
      period: (json['period'] ?? 'morning').toString(),
      tripDate: (json['trip_date'] ?? '2026-11-10').toString(),
      dateGroup: (json['date_group'] ?? 'Today').toString(),
      departureTime: (json['departure_time'] ?? '07:25').toString(),
      arrivalTime: (json['arrival_time'] ?? '07:53').toString(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 28,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 6.4,
      avgSpeedKmh: (json['avg_speed_kmh'] as num?)?.toInt() ?? 31,
      statusCode: (json['status_code'] ?? 'arrived').toString(),
      delayMinutes: (json['delay_minutes'] as num?)?.toInt() ?? 0,
      driverName: (json['driver_name'] ?? 'Ahmed Benali').toString(),
      driverRating: (json['driver_rating'] as num?)?.toDouble() ?? 4.9,
      vehicleModel: (json['vehicle_model'] ?? 'Mercedes Sprinter 2024').toString(),
      waypoints: pts.isNotEmpty
          ? pts
          : const [
              Offset(0.14, 0.78),
              Offset(0.35, 0.58),
              Offset(0.62, 0.36),
              Offset(0.84, 0.22),
            ],
      qrAudit: rawQr,
    );
  }
}

class AttendanceAnalyticsData {
  const AttendanceAnalyticsData({
    required this.childId,
    required this.childName,
    required this.monthLabel,
    required this.completed,
    required this.absences,
    required this.missedQr,
    required this.onTimeRate,
    required this.qrHandoffRate,
    required this.weeklyRegularity,
  });

  final String childId;
  final String childName;
  final String monthLabel;
  final int completed;
  final int absences;
  final int missedQr;
  final double onTimeRate;
  final double qrHandoffRate;
  final List<WeeklyRegularityPoint> weeklyRegularity;

  factory AttendanceAnalyticsData.fromJson(Map<String, dynamic> json) {
    final kpis = (json['kpis'] as Map?) ?? {};
    final weekly = (json['weekly_regularity'] as List? ?? [])
        .whereType<Map>()
        .map((e) => WeeklyRegularityPoint.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return AttendanceAnalyticsData(
      childId: (json['child_id'] ?? '').toString(),
      childName: (json['child_name'] ?? 'Youssef Mansouri').toString(),
      monthLabel: (json['month_label'] ?? 'November 2026').toString(),
      completed: (kpis['completed'] as num?)?.toInt() ?? 38,
      absences: (kpis['absences'] as num?)?.toInt() ?? 1,
      missedQr: (kpis['missed_qr'] as num?)?.toInt() ?? 0,
      onTimeRate: (kpis['on_time_rate'] as num?)?.toDouble() ?? 98.4,
      qrHandoffRate: (kpis['qr_handoff_rate'] as num?)?.toDouble() ?? 100.0,
      weeklyRegularity: weekly,
    );
  }
}

class WeeklyRegularityPoint {
  const WeeklyRegularityPoint({
    required this.day,
    required this.morning,
    required this.returnTrip,
  });

  final String day;
  final double morning;
  final double returnTrip;

  factory WeeklyRegularityPoint.fromJson(Map<String, dynamic> json) {
    return WeeklyRegularityPoint(
      day: (json['day'] ?? 'sun').toString(),
      morning: (json['morning'] as num?)?.toDouble() ?? 1.0,
      returnTrip: (json['return'] as num?)?.toDouble() ?? 0.95,
    );
  }
}

class SafetyNotificationItem {
  const SafetyNotificationItem({
    required this.id,
    required this.childId,
    required this.category,
    required this.title,
    required this.body,
    required this.dayGroup,
    required this.timeLabel,
    required this.isRead,
  });

  final int id;
  final String childId;
  final String category; // arrival | boarding | delay | qr
  final String title;
  final String body;
  final String dayGroup;
  final String timeLabel;
  final bool isRead;

  factory SafetyNotificationItem.fromJson(Map<String, dynamic> json) {
    return SafetyNotificationItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      childId: (json['child_id'] ?? '').toString(),
      category: (json['category'] ?? 'boarding').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      dayGroup: (json['day_group'] ?? 'Today').toString(),
      timeLabel: (json['time_label'] ?? '').toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
    );
  }

  SafetyNotificationItem copyWith({bool? isRead}) {
    return SafetyNotificationItem(
      id: id,
      childId: childId,
      category: category,
      title: title,
      body: body,
      dayGroup: dayGroup,
      timeLabel: timeLabel,
      isRead: isRead ?? this.isRead,
    );
  }
}

class SchoolBulletinItem {
  const SchoolBulletinItem({
    required this.id,
    required this.tag,
    required this.title,
    required this.body,
    required this.publishedAt,
  });

  final int id;
  final String tag;
  final String title;
  final String body;
  final String publishedAt;

  factory SchoolBulletinItem.fromJson(Map<String, dynamic> json) {
    return SchoolBulletinItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tag: (json['tag'] ?? 'notice').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      publishedAt: (json['published_at'] ?? '').toString(),
    );
  }
}

class TransitAlertSettings {
  const TransitAlertSettings({
    this.globalRadiusMeters = 350,
    this.busApproaching = true,
    this.childBoarded = true,
    this.arrivedSafely = true,
    this.routeDelays = true,
    this.criticalSosSound = true,
    this.smsBackup = false,
  });

  final int globalRadiusMeters;
  final bool busApproaching;
  final bool childBoarded;
  final bool arrivedSafely;
  final bool routeDelays;
  final bool criticalSosSound;
  final bool smsBackup;

  factory TransitAlertSettings.fromJson(Map<String, dynamic> json) {
    return TransitAlertSettings(
      globalRadiusMeters: (json['global_radius_meters'] as num?)?.toInt() ?? 350,
      busApproaching: json['bus_approaching'] != false && json['bus_approaching'] != 0,
      childBoarded: json['child_boarded'] != false && json['child_boarded'] != 0,
      arrivedSafely: json['arrived_safely'] != false && json['arrived_safely'] != 0,
      routeDelays: json['route_delays'] != false && json['route_delays'] != 0,
      criticalSosSound: json['critical_sos_sound'] != false && json['critical_sos_sound'] != 0,
      smsBackup: json['sms_backup'] == true || json['sms_backup'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'global_radius_meters': globalRadiusMeters,
      'bus_approaching': busApproaching,
      'child_boarded': childBoarded,
      'arrived_safely': arrivedSafely,
      'route_delays': routeDelays,
      'critical_sos_sound': criticalSosSound,
      'sms_backup': smsBackup,
    };
  }

  TransitAlertSettings copyWith({
    int? globalRadiusMeters,
    bool? busApproaching,
    bool? childBoarded,
    bool? arrivedSafely,
    bool? routeDelays,
    bool? criticalSosSound,
    bool? smsBackup,
  }) {
    return TransitAlertSettings(
      globalRadiusMeters: globalRadiusMeters ?? this.globalRadiusMeters,
      busApproaching: busApproaching ?? this.busApproaching,
      childBoarded: childBoarded ?? this.childBoarded,
      arrivedSafely: arrivedSafely ?? this.arrivedSafely,
      routeDelays: routeDelays ?? this.routeDelays,
      criticalSosSound: criticalSosSound ?? this.criticalSosSound,
      smsBackup: smsBackup ?? this.smsBackup,
    );
  }
}

class EmergencyContactItem {
  const EmergencyContactItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.phone,
    required this.isUrgent,
  });

  final String id;
  final String type;
  final LocalizedText title;
  final LocalizedText subtitle;
  final String phone;
  final bool isUrgent;

  factory EmergencyContactItem.fromJson(Map<String, dynamic> json) {
    return EmergencyContactItem(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? 'driver').toString(),
      title: LocalizedText.fromJson(json, 'title'),
      subtitle: LocalizedText.fromJson(json, 'subtitle'),
      phone: (json['phone'] ?? '').toString(),
      isUrgent: json['is_urgent'] == true || json['is_urgent'] == 1,
    );
  }
}

class CachedQrPassSnapshot {
  const CachedQrPassSnapshot({
    required this.childId,
    required this.childName,
    required this.studentCode,
    required this.schoolName,
    required this.busNumber,
    required this.stopName,
    required this.qrPayload,
  });

  final String childId;
  final String childName;
  final String studentCode;
  final String schoolName;
  final String busNumber;
  final String stopName;
  final String qrPayload;
}
