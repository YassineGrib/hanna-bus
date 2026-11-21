import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/features/auth/auth_screens.dart';
import 'helpers.dart';

void main() {
  testWidgets('welcome leads to sign in and password recovery', (tester) async {
    final state = await readyState();
    addTearDown(state.dispose);
    await tester.pumpWidget(host(state, AuthScreen(state: state)));
    await tester.pumpAndSettle();
    expect(find.text('Hanna Bus Captain'), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('welcome-continue')));
    expect(find.byType(TextField), findsNWidgets(2));
    await tester.enterText(
      find.byType(TextField).first,
      'ahmed.benali@mail.dz',
    );
    await tapVisible(tester, find.text('Forgot password?'));
    expect(
      find.text('Enter your driver email to receive a verification code'),
      findsOneWidget,
    );
  });
}
