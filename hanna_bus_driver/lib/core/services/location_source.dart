import 'package:geolocator/geolocator.dart';

class DriverPosition {
  const DriverPosition(
    this.lat,
    this.lng, {
    this.speedKmh = 0,
    this.heading = 0,
  });
  final double lat, lng, speedKmh, heading;
}

class LocationUnavailable implements Exception {}

abstract interface class LocationSource {
  Future<DriverPosition> current({bool requestPermission = false});
}

class PhoneLocationSource implements LocationSource {
  @override
  Future<DriverPosition> current({bool requestPermission = false}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationUnavailable();
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermission) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationUnavailable();
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 4),
      ),
    );
    return DriverPosition(
      p.latitude,
      p.longitude,
      speedKmh: p.speed < 0 ? 0 : p.speed * 3.6,
      heading: p.heading < 0 ? 0 : p.heading,
    );
  }
}
