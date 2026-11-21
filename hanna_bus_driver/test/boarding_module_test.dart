import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/features/boarding/scanner_screen.dart';
import 'helpers.dart';

void main() {
  testWidgets('fake scanner deduplicates QR and supports manual alighting', (
    tester,
  ) async {
    final repo = FakeRepository();
    final state = await readyState(repository: repo, active: true);
    final source = FakeScanner();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      host(state, ScannerScreen(state: state, source: source)),
    );
    await tester.pumpAndSettle();
    source.emit!('HANNA-BUS|HB-2026-9911|BUS-04|Youssef Mansouri');
    await tester.pumpAndSettle();
    expect(state.onboard, 1);
    source.emit!('HB-2026-9911');
    await tester.pumpAndSettle();
    expect(repo.calls.where((c) => c.path.endsWith('/boarding')).length, 1);
    await tapVisible(tester, find.text('Alighting'));
    await tester.enterText(find.byType(TextField), 'HB-2026-9911');
    await tapVisible(tester, find.byKey(const Key('manual-board')));
    expect(state.onboard, 0);
    expect(
      repo.calls
          .where((c) => c.path.endsWith('/boarding'))
          .last
          .body!['method'],
      'manual',
    );
    await tester.pumpWidget(const SizedBox());
    expect(source.disposed, true);
  });
}
