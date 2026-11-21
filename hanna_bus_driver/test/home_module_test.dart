import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/features/home/home_shell.dart';
import 'helpers.dart';

void main() {
  testWidgets('home opens inspection and switches shell tabs', (tester) async {
    final state = await readyState();
    addTearDown(state.dispose);
    await tester.pumpWidget(host(state, HomeShell(state: state)));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('start-route')));
    expect(find.text('Pre trip inspection'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-1')));
    await tester.pumpAndSettle();
    expect(find.text('Students Manifest'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-2')));
    await tester.pumpAndSettle();
    expect(find.text('Route overview'), findsOneWidget);
  });
}
