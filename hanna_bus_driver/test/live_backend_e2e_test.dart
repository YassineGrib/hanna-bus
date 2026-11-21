import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/core/network/driver_api_client.dart';
import 'package:hanna_bus_driver/core/network/driver_repository.dart';
import 'package:hanna_bus_driver/core/services/location_source.dart';
import 'package:hanna_bus_driver/core/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _liveUrl = String.fromEnvironment('HANNA_LIVE_API_URL');

class _FixedLocation implements LocationSource {
  @override
  Future<DriverPosition> current({bool requestPermission = false}) async =>
      const DriverPosition(36.7541, 3.0592, speedKmh: 31, heading: 80);
}

/// Needs a freshly seeded backend (`php artisan migrate:fresh --seed`) and
/// `--dart-define=HANNA_LIVE_API_URL=http://127.0.0.1:8000/api/v1`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The test binding answers every HTTP request with 400; this suite needs the real network.
  setUpAll(() => HttpOverrides.global = null);

  test(
    'driver state works against the live Laravel API (login, roster, boarding, '
    'arrival, delay, SOS, phase 2 data, end trip)',
    skip: _liveUrl.isEmpty ? 'Pass --dart-define=HANNA_LIVE_API_URL=...' : false,
    () async {
      SharedPreferences.setMockInitialValues({});
      final state = DriverState(
        repository: DriverRepository(api: DriverApiClient(baseUrl: _liveUrl)),
        location: _FixedLocation(),
      );
      addTearDown(state.dispose);
      await state.init();

      expect(await state.login('ahmed.benali@mail.dz', 'Password123!'), isTrue,
          reason: state.error);
      expect(state.authenticated, isTrue);
      expect(state.profile['license_number'], isNotNull);
      expect(state.currentBus, isNotNull);
      expect(state.rotation, isNotEmpty);

      final trip = state.trip!;
      expect(trip.active, isTrue, reason: 'the seeded morning trip is en route');
      expect(trip.stations, isNotEmpty);
      expect(state.students, isNotEmpty);

      final first = state.students.first;
      expect(await state.board(first.code), isTrue, reason: state.error);
      expect(state.students.firstWhere((s) => s.id == first.id).status, 'on_bus');

      expect(await state.arrive(trip.stations.first.id), isTrue,
          reason: state.error);
      expect(await state.delay(5, 'traffic'), isTrue, reason: state.error);
      await state.sendLocation();
      expect(state.lastPosition, isNotNull);
      expect(await state.sos('breakdown'), isTrue, reason: state.error);

      // Phase 2 reads
      await state.loadPhase2();
      expect(state.contacts, isNotEmpty);
      expect(state.settings, isNotEmpty);
      expect((await state.stats())['rating'], isNotNull);
      expect(await state.telemetry(), isNotEmpty);
      expect(await state.history('all'), isNotEmpty);
      expect(await state.dossier(first.id), isNotEmpty);
      expect(await state.passport(state.currentBus!.id), isNotEmpty);
      expect(await state.saveSettings({'glare_mode': 'night'}), isTrue,
          reason: state.error);

      expect(await state.end(true), isTrue, reason: state.error);
      expect(state.trip?.active, isNot(true));
      expect(await state.logout(), isTrue);
      expect(state.authenticated, isFalse);
    },
  );

  test(
    'wrong password is rejected without activating a demo session',
    skip: _liveUrl.isEmpty ? 'Pass --dart-define=HANNA_LIVE_API_URL=...' : false,
    () async {
      SharedPreferences.setMockInitialValues({});
      final state = DriverState(
        repository: DriverRepository(api: DriverApiClient(baseUrl: _liveUrl)),
        location: _FixedLocation(),
      );
      addTearDown(state.dispose);
      await state.init();
      expect(await state.login('ahmed.benali@mail.dz', 'wrong-password'), isFalse);
      expect(state.authenticated, isFalse);
    },
  );
}
