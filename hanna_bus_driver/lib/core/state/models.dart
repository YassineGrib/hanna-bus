import 'package:latlong2/latlong.dart';

typedef Json = Map<String, dynamic>;

bool validCoordinates(double? lat, double? lng) =>
    lat != null &&
    lng != null &&
    lat.isFinite &&
    lng.isFinite &&
    lat.abs() <= 90 &&
    lng.abs() <= 180;

String label(dynamic value, String language) {
  if (value is Map) return (value[language] ?? value['en'] ?? '').toString();
  if (value is List) {
    return value
        .map((v) => label(v, language))
        .join(language == 'ar' ? '، ' : ', ');
  }
  return (value ?? '').toString();
}

class DriverBus {
  DriverBus.fromJson(Json j)
    : id = '${j['id']}',
      number = '${j['number']}',
      line = j['line_name'],
      plate = '${j['plate_number'] ?? ''}',
      model = '${j['vehicle_model'] ?? ''}',
      capacity = (j['capacity'] as num?)?.toInt() ?? 24,
      status = '${j['status']}',
      current = j['is_current'] == true;
  final String id, number, plate, model, status;
  final dynamic line;
  final int capacity;
  final bool current;
}

class Student {
  Student.fromJson(Json j)
    : id = '${j['child_id']}',
      name = j['name'],
      code = '${j['student_code']}',
      absent = j['absent'] == true,
      status =
          const ['on_bus', 'at_school', 'at_home'].contains(j['transit_status'])
          ? j['transit_status'] as String
          : 'waiting',
      stop = j['stop_name'];
  final String id, code, status;
  final dynamic name, stop;
  final bool absent;
}

class Station {
  Station.fromJson(Json j)
    : id = '${j['id']}',
      name = j['name'],
      time = '${j['scheduled_time'] ?? ''}',
      status = const ['completed', 'current'].contains(j['status'])
          ? j['status'] as String
          : 'upcoming',
      lat = (j['lat'] as num?)?.toDouble(),
      lng = (j['lng'] as num?)?.toDouble(),
      students = List.unmodifiable(
        (j['students'] as List? ?? []).map(
          (s) => Student.fromJson(Map<String, dynamic>.from(s)),
        ),
      );
  final String id, time, status;
  final dynamic name;
  final double? lat, lng;
  final List<Student> students;
}

class DriverTrip {
  DriverTrip.withStatus(DriverTrip other, this.status)
    : id = other.id,
      period = other.period,
      route = other.route,
      busNumber = other.busNumber,
      scheduledStart = other.scheduledStart,
      stations = other.stations,
      routePoints = other.routePoints;
  DriverTrip.fromJson(Json j)
    : id = '${j['id']}',
      period = '${j['period']}',
      route = j['route_name'],
      busNumber = '${j['bus_number'] ?? ''}',
      status = '${j['status']}',
      scheduledStart = '${j['scheduled_start'] ?? ''}',
      routePoints = List.unmodifiable(
        (j['route_points'] as List? ?? [])
            .whereType<List>()
            .where(
              (p) =>
                  p.length == 2 &&
                  p[0] is num &&
                  p[1] is num &&
                  validCoordinates(
                    (p[0] as num).toDouble(),
                    (p[1] as num).toDouble(),
                  ),
            )
            .map(
              (p) => LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()),
            ),
      ),
      stations = List.unmodifiable(
        (j['stations'] as List? ?? []).map(
          (s) => Station.fromJson(Map<String, dynamic>.from(s)),
        ),
      );
  final String id, period, busNumber, status, scheduledStart;
  final dynamic route;
  final List<Station> stations;
  final List<LatLng> routePoints;
  bool get active => status == 'en_route';
}

class RotationDay {
  RotationDay.fromJson(Json j)
    : date = '${j['date']}',
      weekday = j['weekday'],
      bus = j['bus_number']?.toString(),
      today = j['is_today'] == true;
  final String date;
  final dynamic weekday;
  final String? bus;
  final bool today;
}
