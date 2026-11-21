import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/core/widgets/driver_widgets.dart';
import 'package:hanna_bus_driver/features/fleet/fleet_screen.dart';
import 'helpers.dart';

void main() {
  testWidgets(
    'rotation offers available bus and disables workshop and occupied buses',
    (tester) async {
      final state = await readyState();
      addTearDown(state.dispose);
      await tester.pumpWidget(host(state, FleetScreen(state: state)));
      await tester.pumpAndSettle();
      expect(find.text("This week's rotation"), findsOneWidget);
      await tapVisible(tester, find.byKey(const Key('switch-bus-07')));
      expect(state.currentBus!.number, '07');
      expect(state.inspected, false);
      await tester.scrollUntilVisible(
        find.byKey(const Key('switch-bus-02')),
        300,
      );
      expect(
        tester
            .widget<DriverButton>(find.byKey(const Key('switch-bus-02')))
            .onPressed,
        isNull,
      );
    },
  );
}
