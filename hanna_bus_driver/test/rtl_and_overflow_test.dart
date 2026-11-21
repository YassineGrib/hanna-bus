import 'package:hanna_bus_driver/features/navigation/navigation_screen.dart';
import 'package:hanna_bus_driver/core/widgets/driver_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/features/auth/auth_screens.dart';
import 'package:hanna_bus_driver/features/home/home_shell.dart';
import 'package:hanna_bus_driver/features/boarding/scanner_screen.dart';
import 'package:hanna_bus_driver/features/fleet/fleet_screen.dart';
import 'package:hanna_bus_driver/features/sos/sos_screen.dart';
import 'package:hanna_bus_driver/features/students/students_screen.dart';
import 'package:hanna_bus_driver/features/trip/trip_screens.dart';
import 'package:hanna_bus_driver/core/theme/hanna_typography.dart';
import 'package:hanna_bus_driver/core/l10n/app_strings.dart';
import 'helpers.dart';
import 'package:hanna_bus_driver/features/messages/messages_screen.dart';
import 'package:hanna_bus_driver/features/history/history_screens.dart';
import 'package:hanna_bus_driver/features/profile/profile_screens.dart';
import 'package:hanna_bus_driver/features/settings/settings_screens.dart';
import 'package:hanna_bus_driver/features/students/dossier_screen.dart';
import 'package:hanna_bus_driver/features/auth/recovery_screen.dart';

void main() {
  for (final language in ['en', 'ar']) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '$language ${brightness.name} all modules at 360px and 1.25 text scale',
        (tester) async {
          tester.view.physicalSize = const Size(360, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final state = await readyState();
          state.locale = Locale(language);
          state.brightness = brightness;
          (state.repository as FakeRepository)
                  .seed
                  .savedSettings['brightness_mode'] =
              brightness.name;
          (state.repository as FakeRepository).serverUnreachable = true;
          addTearDown(state.dispose);
          final pages = <Widget>[
            MessagesScreen(state: state),
            MessageThreadScreen(
              state: state,
              parentId: 'parent-1',
              childId: 'child-1',
            ),
            HistoryScreen(state: state),
            StatsScreen(state: state),
            ProfileScreen(state: state),
            EditProfileScreen(state: state),
            PassportScreen(state: state, busId: 'bus-04'),
            TelemetryScreen(state: state),
            ContactsScreen(state: state, calls: FakeCalls()),
            for (final tab in ['transit', 'medical', 'guardian'])
              DossierScreen(
                state: state,
                childId: 'child-1',
                initialTab: tab,
                calls: FakeCalls(),
              ),
            for (final section in SettingsSection.values)
              SettingsScreen(state: state, section: section),
            for (var step = 0; step < 3; step++)
              RecoveryScreen(state: state, initialStep: step),
            DriverPage(
              state: state,
              title: AppStrings(language).t('routeOverview'),
              children: [NavigationContent(state: state)],
            ),
            AuthScreen(state: state),
            HomeShell(state: state),
            StudentsScreen(state: state),
            FleetScreen(state: state),
            InspectionScreen(state: state),
            SafetyWalkScreen(state: state),
            ScannerScreen(state: state, source: FakeScanner()),
            SosScreen(state: state, calls: FakeCalls()),
            Scaffold(body: DelaySheet(state: state)),
          ];
          for (final page in pages) {
            await tester.pumpWidget(host(state, page, scale: 1.25));
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '${page.runtimeType} initial',
            );
            if (language == 'ar') {
              expect(
                Directionality.of(
                  tester.element(find.byType(page.runtimeType).first),
                ),
                TextDirection.rtl,
              );
            }
            if (find.byType(Scrollable).evaluate().isNotEmpty) {
              for (var i = 0; i < 5; i++) {
                await tester.drag(
                  find.byType(Scrollable).first,
                  const Offset(0, -350),
                );
                await tester.pumpAndSettle();
                expect(
                  tester.takeException(),
                  isNull,
                  reason: '${page.runtimeType} scroll $i',
                );
              }
            }
            if (page is AuthScreen) {
              await tapVisible(
                tester,
                find.byKey(const Key('welcome-continue')),
              );
              for (var i = 0; i < 4; i++) {
                await tester.drag(
                  find.byType(Scrollable).first,
                  const Offset(0, -300),
                );
                await tester.pumpAndSettle();
                expect(
                  tester.takeException(),
                  isNull,
                  reason: 'Sign in $language',
                );
              }
              await tester.drag(
                find.byType(Scrollable).first,
                const Offset(0, 1800),
              );
              await tester.pumpAndSettle();
              await tapVisible(
                tester,
                find.text(AppStrings(language).design('auth', 'forgot')),
              );
              expect(
                tester.takeException(),
                isNull,
                reason: 'Recovery $language',
              );
            }
            await tester.pumpWidget(const SizedBox());
          }
        },
      );
    }
  }
  testWidgets('Arabic small text adds one logical pixel', (tester) async {
    final state = await readyState();
    state.locale = const Locale('ar');
    addTearDown(state.dispose);
    double? size;
    await tester.pumpWidget(
      host(
        state,
        Builder(
          builder: (context) {
            size = HannaTypography.style(context, size: 17).fontSize;
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(size, 18);
  });
}
