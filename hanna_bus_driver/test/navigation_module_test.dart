import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/features/navigation/navigation_screen.dart';
import 'package:hanna_bus_driver/core/widgets/driver_widgets.dart';
import 'helpers.dart';

void main() {
  testWidgets('API stop coordinates and arrival actions are shown', (
    tester,
  ) async {
    final repo = FakeRepository();
    final state = await readyState(repository: repo, active: true);
    addTearDown(state.dispose);
    await tester.pumpWidget(
      host(
        state,
        DriverPage(
          state: state,
          title: 'Navigation',
          children: [NavigationContent(state: state)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is RoutePainter,
      ),
      findsOneWidget,
    );
    await tapVisible(tester, find.byKey(const Key('arrive-stop-1')));
    expect(
      repo.calls.any((c) => c.path.endsWith('/stations/stop-1/arrive')),
      true,
    );
    expect(state.trip!.stations.first.status, 'current');
  });
}
