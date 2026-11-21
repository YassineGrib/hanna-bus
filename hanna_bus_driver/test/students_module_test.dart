import 'package:hanna_bus_driver/core/widgets/driver_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/features/students/students_screen.dart';
import 'helpers.dart';

void main() {
  testWidgets('roster filters absences, searches and groups by stops', (
    tester,
  ) async {
    final state = await readyState();
    addTearDown(state.dispose);
    await tester.pumpWidget(host(state, StudentsScreen(state: state)));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.widgetWithText(HannaChoiceChip, 'Absent'));
    expect(find.text('Lina Hadj'), findsOneWidget);
    expect(find.text('Youssef Mansouri'), findsNothing);
    await tapVisible(tester, find.widgetWithText(HannaChoiceChip, 'All'));
    await tester.enterText(find.byType(TextField), 'Youssef');
    await tester.pumpAndSettle();
    expect(find.text('Lina Hadj'), findsNothing);
    await tapVisible(tester, find.byType(SwitchListTile));
    expect(find.text('07:08 · Hay El Nasr 01'), findsOneWidget);
  });
}
