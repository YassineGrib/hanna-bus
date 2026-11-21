import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/driver_api_client.dart';
import '../network/driver_repository.dart';
import '../services/location_source.dart';
import '../theme/hanna_tokens.dart';
import 'models.dart';

part 'phase2_state.dart';

class DriverState extends ChangeNotifier with WidgetsBindingObserver {
  DriverState({DriverRepository? repository, LocationSource? location})
    : repository = repository ?? DriverRepository(),
      location = location ?? PhoneLocationSource();
  final DriverRepository repository;
  final LocationSource location;
  Locale locale = const Locale('en');
  HannaPalette palette = HannaPalette.mustard;
  Brightness brightness = Brightness.light;
  bool authenticated = false, busy = false, ready = false;
  String? error, notice, locationIssue;
  Json profile = {};
  Json settings = Map.of(defaultDriverSettings), contacts = {};
  List<Json> inbox = [];
  String brightnessMode = 'light';
  int get unreadCount => inbox.fold(
    0,
    (sum, item) => sum + ((item['unread_count'] as num?)?.toInt() ?? 0),
  );
  List<DriverBus> _buses = [];
  List<DriverTrip> _trips = [];
  List<Student> _students = [];
  List<RotationDay> _rotation = [];
  String? selectedTripId;
  String? _inspectedBus;
  DateTime? _inspectionDate;
  Timer? _locationTimer;
  bool _sendingLocation = false, _disposed = false, _foreground = true;
  DriverPosition? lastPosition;
  bool requestingPermission = false;
  int _locationFailures = 0;
  List<DriverBus> get buses => List.unmodifiable(_buses);
  List<DriverTrip> get trips => List.unmodifiable(_trips);
  List<Student> get students => List.unmodifiable(_students);
  List<RotationDay> get rotation => List.unmodifiable(_rotation);
  DriverBus? get currentBus => _buses.where((b) => b.current).firstOrNull;
  DriverTrip? get trip =>
      _trips.where((t) => t.active).firstOrNull ??
      _trips.where((t) => t.id == selectedTripId).firstOrNull ??
      _trips.where((t) => t.status == 'scheduled').firstOrNull ??
      _trips.firstOrNull;
  bool get inspected =>
      _inspectedBus == currentBus?.id &&
      _inspectionDate != null &&
      DateUtils.isSameDay(_inspectionDate, DateTime.now());
  int get onboard => _students.where((s) => s.status == 'on_bus').length;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    locale = Locale(prefs.getString('driver_language') == 'ar' ? 'ar' : 'en');
    palette = HannaPalette.fromApi(prefs.getString('driver_palette'));
    brightness = prefs.getBool('driver_dark') == true
        ? Brightness.dark
        : Brightness.light;
    settings = {
      ...settings,
      'theme_palette': palette.apiValue,
      'brightness_mode': brightness.name,
    };
    final stored = prefs.getString('driver_settings');
    if (stored != null) {
      try {
        settings.addAll(Map<String, dynamic>.from(jsonDecode(stored)));
      } on FormatException {
        /* Keep defaults. */
      }
    }
    _applySettings();
    repository.api.language = locale.languageCode;
    WidgetsBinding.instance.addObserver(this);
    ready = true;
    _notify();
  }

  Future<void> preferences({
    Locale? language,
    HannaPalette? color,
    Brightness? mode,
  }) async {
    locale = language ?? locale;
    palette = color ?? palette;
    brightness = mode ?? brightness;
    repository.api.language = locale.languageCode;
    _notify();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_language', locale.languageCode);
    await prefs.setString('driver_palette', palette.apiValue);
    await prefs.setBool('driver_dark', brightness == Brightness.dark);
    if (authenticated) {
      if (language != null) {
        await updateProfile({'locale': locale.languageCode});
      }
      if (color != null || mode != null) {
        await saveSettings({
          if (color != null) 'theme_palette': color.apiValue,
          if (mode != null) 'brightness_mode': mode.name,
        });
      }
      await run(refresh);
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String failure(Object e) => e is ApiFailure
      ? switch (e.status) {
          401 => 'credentialsError',
          403 => 'driverOnly',
          404 => 'codeUnknown',
          409 => 'conflict',
          422 => 'validation',
          429 => 'rateLimit',
          _ => 'serverError',
        }
      : e is ApiUnreachable
      ? 'unreachable'
      : 'serverError';
  Future<bool> run(Future<void> Function() action) async {
    if (busy) return false;
    busy = true;
    error = null;
    notice = null;
    _notify();
    try {
      await action();
      return true;
    } catch (e) {
      error = failure(e);
      return false;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<bool> login(String email, String password) => run(() async {
    await repository.login(email, password);
    await refresh();
    authenticated = true;
    await loadPhase2();
    _syncLocation();
  });
  Future<void> refresh() async {
    final results = await Future.wait([
      repository.request('GET', '/driver/profile'),
      repository.request('GET', '/driver/buses'),
      repository.request('GET', '/driver/rotation'),
      repository.request('GET', '/driver/trips/today'),
    ]);
    final newTrips = (results[3] as List)
        .map((e) => DriverTrip.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    profile = Map<String, dynamic>.from(results[0]);
    _buses = (results[1] as List)
        .map((e) => DriverBus.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    _rotation = (results[2]['days'] as List)
        .map((e) => RotationDay.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    _trips = newTrips;
    await _loadStudents();
    _syncLocation();
    _notify();
  }

  Future<void> _loadStudents() async {
    if (trip == null) {
      _students = [];
      return;
    }
    final result = await repository.request(
      'GET',
      '/driver/trips/${trip!.id}/students',
    );
    _students = (result as List)
        .map((e) => Student.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<bool> selectTrip(String id) => run(() async {
    if (trip?.active == true) return;
    selectedTripId = id;
    await _loadStudents();
  });
  Future<bool> inspect(Map<String, bool> items) => run(() async {
    if (currentBus == null ||
        !['tires', 'brakes', 'lights', 'fuel'].every((k) => items[k] == true)) {
      throw const ApiFailure(422);
    }
    if (items.values.any((checked) => !checked)) throw const ApiFailure(422);
    await repository.request('POST', '/driver/inspections', {
      'bus_id': currentBus!.id,
      'items': items,
      'passed': true,
    });
    _inspectedBus = currentBus!.id;
    _inspectionDate = DateTime.now();
  });
  Future<bool> switchBus(String id) => run(() async {
    await repository.request('PUT', '/driver/bus', {'bus_id': id});
    _inspectedBus = null;
    await refresh();
    notice = 'busSwitched';
  });
  Future<bool> start() => run(() async {
    if (!inspected || trip == null) throw const ApiFailure(422);
    await repository.request('POST', '/driver/trips/${trip!.id}/start');
    final id = trip!.id;
    _trips = [
      for (final t in _trips)
        t.id == id ? DriverTrip.withStatus(t, 'en_route') : t,
    ];
    _syncLocation();
    await refresh();
  });
  Future<bool> arrive(String station) => run(() async {
    _requireActive();
    await repository.request(
      'POST',
      '/driver/trips/${trip!.id}/stations/$station/arrive',
    );
    await refresh();
    notice = 'arrivalSent';
  });
  void _requireActive() {
    if (trip?.active != true) throw const ApiFailure(409);
  }

  Future<bool> board(
    String code, {
    String method = 'qr',
    String type = 'boarded',
  }) => run(() async {
    _requireActive();
    await repository.request('POST', '/driver/trips/${trip!.id}/boarding', {
      'student_code': code.trim(),
      'type': type,
      'method': method,
    });
    await _loadStudents();
    notice = type == 'boarded' ? 'boardSuccess' : 'alightSuccess';
  });
  Future<bool> delay(int minutes, String reason) => run(() async {
    _requireActive();
    await repository.request('POST', '/driver/trips/${trip!.id}/delay', {
      'minutes': minutes,
      'reason': reason,
    });
    notice = 'delaySent';
  });
  Future<bool> end(bool safetyConfirmed) => run(() async {
    _requireActive();
    if (!safetyConfirmed) throw const ApiFailure(422);
    await repository.request('POST', '/driver/trips/${trip!.id}/end', {
      'safety_walk_confirmed': true,
    });
    final id = trip!.id;
    _trips = [
      for (final t in _trips)
        t.id == id ? DriverTrip.withStatus(t, 'completed') : t,
    ];
    _locationTimer?.cancel();
    await refresh();
    notice = 'tripEnded';
  });
  Future<bool> sos(String type) => run(() async {
    await repository.request('POST', '/driver/sos', {
      'type': type,
      if (trip?.active == true) 'trip_id': trip!.id,
      if (lastPosition != null) ...{
        'lat': lastPosition!.lat,
        'lng': lastPosition!.lng,
      },
    });
    notice = 'sosSent';
  });
  Future<bool> logout() => run(() async {
    await repository.logout();
    authenticated = false;
    locationIssue = null;
    _locationFailures = 0;
    _locationTimer?.cancel();
    _trips = [];
    _students = [];
    _buses = [];
    profile = {};
    inbox = [];
    contacts = {};
    _inspectedBus = null;
    lastPosition = null;
  });
  void _syncLocation() {
    if (trip?.active != true || !_foreground || !authenticated) {
      _locationTimer?.cancel();
      _locationTimer = null;
      return;
    }
    if (_locationTimer?.isActive == true) return;
    unawaited(sendLocation(requestPermission: true));
    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => unawaited(sendLocation()),
    );
  }

  Future<void> sendLocation({bool requestPermission = false}) async {
    if (_sendingLocation ||
        trip?.active != true ||
        !authenticated ||
        !_foreground) {
      return;
    }
    _sendingLocation = true;
    final tripId = trip!.id;
    try {
      // Accuracy dialogs can appear during position acquisition on Android.
      requestingPermission = true;
      _notify();
      late final DriverPosition p;
      try {
        p = await location.current(requestPermission: requestPermission);
      } finally {
        requestingPermission = false;
        _notify();
      }
      if (_disposed ||
          trip?.id != tripId ||
          trip?.active != true ||
          !authenticated ||
          !_foreground) {
        return;
      }
      await repository.request('POST', '/driver/trips/$tripId/location', {
        'lat': p.lat,
        'lng': p.lng,
        'speed_kmh': p.speedKmh,
        'heading': p.heading,
      });
      if (_disposed ||
          trip?.id != tripId ||
          trip?.active != true ||
          !authenticated) {
        return;
      }
      lastPosition = p;
      _locationFailures = 0;
      locationIssue = null;
      _notify();
      if (settings['speed_chime'] == true && p.speedKmh > 60) {
        unawaited(SystemSound.play(SystemSoundType.alert));
      }
    } catch (e) {
      if (_disposed ||
          trip?.id != tripId ||
          trip?.active != true ||
          !authenticated) {
        return;
      }
      _locationFailures++;
      if (e is! LocationUnavailable && _locationFailures < 2) return;
      final issue = e is LocationUnavailable
          ? 'locationDenied'
          : 'locationFailed';
      if (locationIssue != issue) {
        locationIssue = issue;
        _notify();
      }
    } finally {
      _sendingLocation = false;
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (brightnessMode == 'auto') {
      _applySettings();
      _notify();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncLocation();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _locationTimer?.cancel();
    repository.close();
    super.dispose();
  }
}
