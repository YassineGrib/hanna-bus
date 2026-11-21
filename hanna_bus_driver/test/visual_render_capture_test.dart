import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/features/home/home_shell.dart';
import 'package:hanna_bus_driver/features/messages/messages_screen.dart';
import 'package:hanna_bus_driver/features/history/history_screens.dart';
import 'package:hanna_bus_driver/features/profile/profile_screens.dart';
import 'package:hanna_bus_driver/features/settings/settings_screens.dart';
import 'package:hanna_bus_driver/features/students/dossier_screen.dart';
import 'package:hanna_bus_driver/features/auth/recovery_screen.dart';
import 'helpers.dart';

void main() {
  testWidgets('render mission control in both languages', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = await readyState();
    addTearDown(state.dispose);
    for (final language in ['en', 'ar']) {
      state.locale = Locale(language);
      final pages = <String, Widget>{
        'home': HomeShell(state: state),
        if (Platform.environment['HANNA_CAPTURE'] == '1') ...{
          'messages': MessagesScreen(state: state),
          'thread': MessageThreadScreen(
            state: state,
            parentId: 'parent-1',
            childId: 'child-1',
          ),
          'history': HistoryScreen(state: state),
          'performance': StatsScreen(state: state),
          'profile': ProfileScreen(state: state),
          'edit-profile': EditProfileScreen(state: state),
          'passport': PassportScreen(state: state, busId: 'bus-04'),
          'telemetry': TelemetryScreen(state: state),
          'contacts': ContactsScreen(state: state, calls: FakeCalls()),
          for (final tab in ['transit', 'medical', 'guardian'])
            'dossier-$tab': DossierScreen(
              state: state,
              childId: 'child-1',
              initialTab: tab,
            ),
          for (final section in SettingsSection.values)
            'settings-${section.name}': SettingsScreen(
              state: state,
              section: section,
            ),
          for (var step = 0; step < 3; step++)
            'recovery-$step': RecoveryScreen(state: state, initialStep: step),
        },
      };
      for (final page in pages.entries) {
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(key: key, child: host(state, page.value)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (Platform.environment['HANNA_CAPTURE'] == '1') {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File('output/previews/${page.key}-$language.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox());
      }
    }
  });
}
