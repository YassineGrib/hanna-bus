import 'models.dart';

/// A separate in-memory simulator. No offline queue or live boarding cache.
class DemoSeed {
  final buses = <Json>[
    {
      'id': 'bus-04',
      'number': '04',
      'line_name': {'en': 'Line 12', 'ar': 'الخط 12'},
      'plate_number': '16-2841-09',
      'vehicle_model': 'Toyota Coaster',
      'capacity': 24,
      'status': 'in_service',
      'is_current': true,
    },
    {
      'id': 'bus-07',
      'number': '07',
      'line_name': {'en': 'Line 3', 'ar': 'الخط 3'},
      'capacity': 24,
      'status': 'available',
      'is_current': false,
    },
    {
      'id': 'bus-11',
      'number': '11',
      'line_name': {'en': 'Line 8', 'ar': 'الخط 8'},
      'capacity': 30,
      'status': 'in_service',
      'is_current': false,
    },
    {
      'id': 'bus-02',
      'number': '02',
      'line_name': {'en': 'Spare', 'ar': 'احتياط'},
      'capacity': 18,
      'status': 'workshop',
      'is_current': false,
    },
  ];
  late final List<Json> trips = ['morning', 'return']
      .map(
        (period) => <String, dynamic>{
          'id': 'demo-$period',
          'period': period,
          'route_name': {
            'en': 'Line 12 · El Wiam Primary',
            'ar': 'الخط 12 · ابتدائية الوئام',
          },
          'bus_number': '04',
          'status': 'scheduled',
          'scheduled_start': period == 'morning' ? '07:00' : '15:30',
          'stations': [
            {
              'id': 'stop-1',
              'sort_order': 1,
              'name': {'en': 'Hay El Nasr 01', 'ar': 'حي النصر 01'},
              'scheduled_time': '07:08',
              'status': 'upcoming',
              'lat': 36.7538,
              'lng': 3.0588,
              'students': [
                {
                  'child_id': 'child-1',
                  'name': {'en': 'Youssef Mansouri', 'ar': 'يوسف منصوري'},
                  'student_code': 'HB-2026-9911',
                  'absent': false,
                },
                {
                  'child_id': 'child-2',
                  'name': {'en': 'Amina Mansouri', 'ar': 'أمينة منصوري'},
                  'student_code': 'HB-2026-9912',
                  'absent': false,
                },
              ],
            },
            {
              'id': 'stop-2',
              'sort_order': 2,
              'name': {'en': 'Blvd des Martyrs 03', 'ar': 'شارع الشهداء 03'},
              'scheduled_time': '07:16',
              'status': 'upcoming',
              'lat': 36.7552,
              'lng': 3.0601,
              'students': [
                {
                  'child_id': 'child-3',
                  'name': {'en': 'Rayan Benali', 'ar': 'ريان بن علي'},
                  'student_code': 'HB-2026-9913',
                  'absent': false,
                },
                {
                  'child_id': 'child-4',
                  'name': {'en': 'Lina Hadj', 'ar': 'لينا حاج'},
                  'student_code': 'HB-2026-9914',
                  'absent': true,
                },
              ],
            },
            {
              'id': 'stop-3',
              'sort_order': 3,
              'name': {'en': 'El Wiam Campus Gate', 'ar': 'بوابة مدرسة الوئام'},
              'scheduled_time': '07:42',
              'status': 'upcoming',
              'lat': 36.7582,
              'lng': 3.0642,
              'students': <Json>[],
            },
          ],
        },
      )
      .toList();
  final events = <String, Json>{};
  bool inspected = false;
  Json get currentBus => buses.firstWhere((b) => b['is_current'] == true);
  List<Json> students(Json trip) => [
    for (final stop in trip['stations'])
      for (final child in stop['students'])
        {...Map<String, dynamic>.from(child), 'stop_name': stop['name']},
  ];

  dynamic request(String method, String path, Json? body) {
    final b = body ?? {};
    if (path == '/driver/profile') {
      return {
        'user': {
          'name': {'en': 'Ahmed Benali', 'ar': 'أحمد بن علي'},
          'role': 'driver',
        },
        'license_number': 'DZ-D-2024-0457',
        'rating': 4.9,
        'trips_count': 520,
        'current_bus': currentBus,
      };
    }
    if (path == '/driver/buses') return buses;
    if (path.startsWith('/driver/rotation')) {
      final now = DateTime.now();
      final sunday = now.subtract(Duration(days: now.weekday % 7));
      return {
        'days': List.generate(5, (i) {
          final d = sunday.add(Duration(days: i));
          return {
            'date': d.toIso8601String().split('T').first,
            'weekday': i,
            'bus_number': ['04', '04', '04', '07', '11'][i],
            'is_today': d.day == now.day,
          };
        }),
      };
    }
    if (path == '/driver/trips/today') return trips;
    if (path == '/driver/bus') {
      final bus = buses.firstWhere((e) => e['id'] == b['bus_id']);
      if (trips.any((t) => t['status'] == 'en_route') ||
          (!bus['is_current'] && bus['status'] != 'available')) {
        throw const DemoFailure(409);
      }
      for (final other in buses) {
        if (other['is_current'] == true) other['status'] = 'available';
        other['is_current'] = false;
      }
      bus['is_current'] = true;
      bus['status'] = 'in_service';
      inspected = false;
      for (final trip in trips) {
        if (trip['status'] == 'scheduled') trip['bus_number'] = bus['number'];
      }
      return {'bus': bus, 'inspection_required': true};
    }
    if (path == '/driver/inspections') {
      inspected =
          b['passed'] == true &&
          [
            'tires',
            'brakes',
            'lights',
            'fuel',
          ].every((k) => b['items'][k] == true);
      return {'passed': inspected};
    }
    if (path == '/driver/sos' || path == '/auth/logout') return {'ok': true};
    final parts = path.split('/');
    final trip = trips.firstWhere((t) => t['id'] == parts[3]);
    final action = parts[4];
    if (action == 'students') return students(trip);
    if (action == 'start') {
      if (!inspected) throw const DemoFailure(422);
      if (trip['status'] != 'scheduled' ||
          trips.any((t) => t['status'] == 'en_route')) {
        throw const DemoFailure(409);
      }
      trip['status'] = 'en_route';
      return trip;
    }
    if (trip['status'] != 'en_route') throw const DemoFailure(409);
    if (action == 'end') {
      if (b['safety_walk_confirmed'] != true) throw const DemoFailure(422);
      trip['status'] = 'completed';
      return trip;
    }
    if (action == 'stations') {
      for (final s in trip['stations']) {
        s['status'] = s['id'] == parts[5] ? 'current' : 'completed';
        if (s['id'] == parts[5]) break;
      }
      return {'ok': true};
    }
    if (action == 'boarding') {
      Json? child;
      for (final stop in trip['stations']) {
        for (final c in stop['students']) {
          if (c['student_code'] == b['student_code']) child = c;
        }
      }
      if (child == null) throw const DemoFailure(404);
      if (child['absent'] == true) throw const DemoFailure(422);
      final key = '${trip['id']}/${child['child_id']}/${b['type']}';
      if (events.containsKey(key)) return events[key];
      child['transit_status'] = b['type'] == 'boarded'
          ? 'on_bus'
          : trip['period'] == 'morning'
          ? 'at_school'
          : 'at_home';
      return events[key] = {
        'child': child,
        'event': b,
        'onboard_count': students(
          trip,
        ).where((c) => c['transit_status'] == 'on_bus').length,
      };
    }
    return {'ok': true, 'notified': 3};
  }
}

class DemoFailure implements Exception {
  const DemoFailure(this.status);
  final int status;
}
