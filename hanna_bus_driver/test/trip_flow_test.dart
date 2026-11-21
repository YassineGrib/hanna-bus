import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'inspection, start, arrival, QR boarding, delay, alighting and mandatory safety walk',
    () async {
      final repo = FakeRepository();
      final location = FakeLocation();
      final state = await readyState(repository: repo, location: location);
      addTearDown(state.dispose);
      expect(await state.start(), false);
      expect(repo.calls.where((c) => c.path.endsWith('/start')), isEmpty);
      expect(
        await state.inspect({
          'tires': true,
          'brakes': true,
          'lights': true,
          'fuel': false,
        }),
        false,
      );
      expect(
        await state.inspect({
          'tires': true,
          'brakes': true,
          'lights': true,
          'fuel': true,
        }),
        true,
      );
      expect(await state.start(), true);
      expect(state.trip!.active, true);
      expect(await state.arrive('stop-1'), true);
      expect(await state.board('HB-2026-9911'), true);
      expect(state.onboard, 1);
      expect(await state.board('HB-2026-9911'), true);
      expect(state.onboard, 1);
      expect(await state.board('HB-2026-9914'), false);
      expect(state.onboard, 1);
      expect(await state.delay(10, 'traffic'), true);
      expect(await state.end(false), false);
      expect(state.trip!.active, true);
      expect(
        await state.board('HB-2026-9911', method: 'manual', type: 'alighted'),
        true,
      );
      expect(state.onboard, 0);
      expect(await state.end(true), true);
      expect(state.trips.first.status, 'completed');
      expect(repo.calls.where((c) => c.path.endsWith('/end')).single.body, {
        'safety_walk_confirmed': true,
      });
      final posts = repo.calls.where((c) => c.method == 'POST').toList();
      expect(posts.any((c) => c.path.endsWith('/location')), true);
    },
  );
  test(
    'switch invalidates inspection and occupied buses reject switch',
    () async {
      final state = await readyState();
      addTearDown(state.dispose);
      await state.inspect({
        'tires': true,
        'brakes': true,
        'lights': true,
        'fuel': true,
      });
      expect(await state.switchBus('bus-11'), false);
      expect(await state.switchBus('bus-07'), true);
      expect(state.inspected, false);
      expect(state.currentBus!.number, '07');
    },
  );
  testWidgets(
    'five second location cadence, permission denial, lifecycle and end stop posting',
    (tester) async {
      final repo = FakeRepository();
      final location = FakeLocation()..denied = true;
      final state = await readyState(
        repository: repo,
        location: location,
        active: true,
        tracking: true,
      );
      await tester.pump();
      expect(state.locationIssue, 'locationDenied');
      expect(repo.calls.where((c) => c.path.endsWith('/location')), isEmpty);
      location.denied = false;
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(repo.calls.where((c) => c.path.endsWith('/location')).length, 1);
      state.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 10));
      expect(repo.calls.where((c) => c.path.endsWith('/location')).length, 1);
      state.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();
      expect(repo.calls.where((c) => c.path.endsWith('/location')).length, 2);
      await state.end(true);
      final count = location.calls;
      await tester.pump(const Duration(seconds: 10));
      expect(location.calls, count);
      state.dispose();
    },
  );
}
