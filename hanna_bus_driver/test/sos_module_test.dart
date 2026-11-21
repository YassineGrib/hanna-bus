import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/features/sos/sos_screen.dart';
import 'helpers.dart';

void main() {
  testWidgets(
    'SOS cancels short presses and sends exactly once after three seconds',
    (tester) async {
      final repo = FakeRepository();
      final state = await readyState();
      final calls = FakeCalls();
      addTearDown(state.dispose);
      // Use a separately recorded repository for alert assertions.
      final recorded = await readyState(repository: repo);
      addTearDown(recorded.dispose);
      await tester.pumpWidget(
        host(recorded, SosScreen(state: recorded, calls: calls)),
      );
      await tester.pumpAndSettle();
      final target = find.byKey(const Key('sos-hold'));
      var gesture = await tester.startGesture(tester.getCenter(target));
      await tester.pump(const Duration(seconds: 2));
      await gesture.up();
      await tester.pump();
      expect(repo.calls.where((c) => c.path == '/driver/sos'), isEmpty);
      await tapVisible(tester, find.text('Medical'));
      gesture = await tester.startGesture(tester.getCenter(target));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(
        repo.calls.where((c) => c.path == '/driver/sos').single.body!['type'],
        'medical',
      );
      await tapVisible(tester, find.text('Civil Protection · 14'));
      expect(calls.numbers, ['14']);
    },
  );
}
