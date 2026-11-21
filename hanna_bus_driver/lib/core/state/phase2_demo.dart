part of 'demo_seed.dart';

extension Phase2Demo on DemoSeed {
  dynamic phase2(String method, String path, Json body) {
    final uri = Uri.parse(path);
    final parent = {
      'id': 'parent-1',
      'name': {'en': 'Karim Mansouri', 'ar': 'كريم منصوري'},
    };
    final child = {
      'id': 'child-1',
      'name': students(trips.first).first['name'],
      'stop_name': trips.first['stations'][0]['name'],
    };
    if (uri.path == '/driver/messages') {
      return [
        {
          'parent': parent,
          'child': child,
          'last_message': messages.last['message'],
          'last_at': messages.last['created_at'],
          'unread_count': messages
              .where(
                (m) =>
                    m['direction'] == 'parent_to_driver' &&
                    m['read_at'] == null,
              )
              .length,
          'is_urgent': true,
        },
      ];
    }
    if (uri.path.startsWith('/driver/messages/')) {
      if (method == 'POST') {
        if (body['child_id'] != 'child-1' ||
            '${body['message']}'.trim().isEmpty) {
          throw const DemoFailure(422);
        }
        final item = <String, dynamic>{
          'id': 'message-${messages.length + 1}',
          'direction': 'driver_to_parent',
          'message': body['message'],
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'read_at': null,
        };
        messages.add(item);
        return item;
      }
      for (final message in messages) {
        if (message['direction'] == 'parent_to_driver') {
          message['read_at'] = DateTime.now().toUtc().toIso8601String();
        }
      }
      return {'parent': parent, 'child': child, 'messages': List.of(messages)};
    }
    if (uri.path == '/driver/settings') {
      if (method == 'PUT') savedSettings.addAll(body);
      return {
        'voice_guidance': true,
        'speed_chime': true,
        'glare_mode': 'auto',
        'radar_radius_m': 500,
        'scan_mode': 'camera',
        'scan_chime': true,
        'biometric_unlock': false,
        'quick_pin_enabled': false,
        'privacy_lock_minutes': 5,
        'theme_palette': 'mustard',
        'brightness_mode': 'light',
        ...savedSettings,
      };
    }
    if (uri.path == '/driver/contacts') {
      return {
        'school': {
          'name': {'en': 'El Wiam Primary', 'ar': 'ابتدائية الوئام'},
          'phone': '+213550776655',
        },
        'coordinator': {
          'name': {'en': 'Fleet Coordinator', 'ar': 'منسق الأسطول'},
          'phone': '+213550889900',
        },
        'emergency': [
          {
            'key': 'civil_protection',
            'label': {'en': 'Civil Protection', 'ar': 'الحماية المدنية'},
            'phone': '14',
          },
          {
            'key': 'police',
            'label': {'en': 'Police', 'ar': 'الشرطة'},
            'phone': '17',
          },
        ],
      };
    }
    if (uri.path.startsWith('/driver/students/')) {
      final c = students(
        trips.first,
      ).where((s) => s['child_id'] == uri.pathSegments.last).firstOrNull;
      if (c == null) throw const DemoFailure(404);
      return {
        'student': {
          ...c,
          'id': c['child_id'],
          'grade': '3',
          'seat_number': 'A2',
        },
        'transit': {
          'bus_number': currentBus['number'],
          'seat_number': 'A2',
          'stop_name': c['stop_name'],
          'stop_time': '07:08',
          'return_time': '15:40',
          'dismissal_rule': {
            'en': 'Release only to an authorized guardian',
            'ar': 'التسليم لولي أمر مخول فقط',
          },
        },
        'medical': {
          'blood_type': 'O+',
          'allergies': {'en': 'Peanut allergy', 'ar': 'حساسية الفول السوداني'},
          'chronic_conditions': {'en': 'Asthma', 'ar': 'الربو'},
          'first_aid_protocol': {
            'en': 'Stop safely and contact the guardian and emergency services',
            'ar': 'توقف بأمان واتصل بولي الأمر وخدمات الطوارئ',
          },
        },
        'guardian': {
          'name': parent['name'],
          'phone': '+213550123456',
          'backup_phone': '+213550789012',
        },
      };
    }
    if (uri.path.startsWith('/driver/buses/')) {
      final bus = buses
          .where((b) => b['id'] == uri.pathSegments.last)
          .firstOrNull;
      if (bus == null) throw const DemoFailure(404);
      return {
        ...bus,
        'insurance_expires_on': '2027-06-30',
        'technical_control_expires_on': '2026-12-15',
        'last_service_on': '2026-09-10',
        'last_inspection': inspected
            ? {
                'date': DateTime.now().toIso8601String().split('T').first,
                'passed': true,
              }
            : null,
      };
    }
    if (uri.path == '/driver/telemetry/today') {
      return {
        'max_speed_kmh': 42,
        'avg_speed_kmh': 24,
        'speeding_events': 0,
        'distance_km': 18,
        'driving_minutes': 45,
        'trips': 1,
      };
    }
    if (uri.path == '/driver/stats') {
      return {
        'rating': 4.9,
        'trips_count': 520,
        'on_time_rate': 98,
        'trips_this_month': 42,
        'km_this_month': 1126,
        'safe_scans': 1204,
        'per_weekday': [
          for (var i = 0; i < 5; i++)
            {
              'weekday': i,
              'trips': [8, 9, 9, 8, 8][i],
            },
        ],
      };
    }
    if (uri.path == '/driver/history') {
      return {
        'totals': {'trips': 2, 'km': 48, 'on_time_rate': 100},
        'trips': [
          for (final trip in trips)
            {
              'id': trip['id'],
              'date': '2026-11-20',
              'period': trip['period'],
              'route_name': trip['route_name'],
              'departure_time': trip['scheduled_start'],
              'arrival_time': trip['period'] == 'morning' ? '07:42' : '16:12',
              'students': 3,
              'status_code': 'completed',
              'delay_minutes': 0,
            },
        ],
      };
    }
    throw const DemoFailure(404);
  }
}
