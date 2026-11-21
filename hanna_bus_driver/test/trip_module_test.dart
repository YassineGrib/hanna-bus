import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/core/widgets/driver_widgets.dart';
import 'package:hanna_bus_driver/features/trip/trip_screens.dart';
import 'helpers.dart';

void main() {
  testWidgets('inspection requires all twelve checks', (tester) async {
    final state = await readyState();
    addTearDown(state.dispose);
    await tester.pumpWidget(host(state, InspectionScreen(state: state)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('confirm-inspection')),
      300,
    );
    expect(
      tester
          .widget<DriverButton>(find.byKey(const Key('confirm-inspection')))
          .onPressed,
      isNull,
    );
    for (final item in inspectionKeys) {
      await tapVisible(tester, find.byKey(Key('inspect-$item')));
    }
    await tester.scrollUntilVisible(
      find.byKey(const Key('confirm-inspection')),
      300,
    );
    expect(
      tester
          .widget<DriverButton>(find.byKey(const Key('confirm-inspection')))
          .onPressed,
      isNotNull,
    );
  });
  testWidgets(
    'safety walk cannot finish until every physical check is confirmed',
    (tester) async {
      final state = await readyState(active: true);
      addTearDown(state.dispose);
      await tester.pumpWidget(host(state, SafetyWalkScreen(state: state)));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DriverButton>(find.byKey(const Key('confirm-safety')))
            .onPressed,
        isNull,
      );
      for (var i = 0; i < 3; i++) {
        await tapVisible(tester, find.byKey(Key('walk-$i')));
      }
      expect(
        tester
            .widget<DriverButton>(find.byKey(const Key('confirm-safety')))
            .onPressed,
        isNotNull,
      );
    },
  );
  testWidgets('delay sheet sends selected delay and reason', (tester) async {
    final repo = FakeRepository();
    final state = await readyState(repository: repo, active: true);
    addTearDown(state.dispose);
    await tester.pumpWidget(
      host(state, Scaffold(body: DelaySheet(state: state))),
    );
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('10 Minutes'));
    await tapVisible(tester, find.text('Weather'));
    await tapVisible(tester, find.text('Broadcast delay alert'));
    expect(repo.calls.where((c) => c.path.endsWith('/delay')).single.body, {
      'minutes': 10,
      'reason': 'weather',
    });
  });
}
