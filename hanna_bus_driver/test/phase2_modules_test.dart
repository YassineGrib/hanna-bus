import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanna_bus_driver/core/state/app_state.dart';
import 'package:hanna_bus_driver/core/l10n/app_strings.dart';
import 'package:hanna_bus_driver/core/network/driver_api_client.dart';
import 'package:hanna_bus_driver/core/network/driver_repository.dart';
import 'package:hanna_bus_driver/core/theme/hanna_tokens.dart';
import 'package:hanna_bus_driver/features/auth/recovery_screen.dart';
import 'package:hanna_bus_driver/features/history/history_screens.dart';
import 'package:hanna_bus_driver/features/messages/messages_screen.dart';
import 'package:hanna_bus_driver/features/profile/profile_screens.dart';
import 'package:hanna_bus_driver/features/settings/settings_screens.dart';
import 'package:hanna_bus_driver/features/students/dossier_screen.dart';
import 'package:hanna_bus_driver/core/widgets/privacy_guard.dart';
import 'package:hanna_bus_driver/features/boarding/scanner_screen.dart';
import 'helpers.dart';

void main() {
  testWidgets('privacy timer covers data and resume restores the screen', (
    tester,
  ) async {
    final state = await readyState();
    state.settings['privacy_lock_minutes'] = 1;
    addTearDown(state.dispose);
    await tester.pumpWidget(
      host(
        state,
        PrivacyGuard(
          state: state,
          child: const Scaffold(body: Text('Student information')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(minutes: 1));
    await tester.pumpAndSettle();
    expect(
      find.text('Student information is covered for privacy'),
      findsOneWidget,
    );
    await tester.tap(find.text('Resume shift'));
    await tester.pumpAndSettle();
    expect(
      find.text('Student information is covered for privacy'),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'Bluetooth keyboard scanner submits QR passes without camera access',
    (tester) async {
      final repo = FakeRepository();
      final state = await readyState(repository: repo, active: true);
      addTearDown(state.dispose);
      await state.saveSettings({'scan_mode': 'bluetooth', 'scan_chime': false});
      final scanner = FakeScanner();
      await tester.pumpWidget(
        host(state, ScannerScreen(state: state, source: scanner)),
      );
      await tester.pumpAndSettle();
      expect(scanner.emit, isNull);
      await tester.enterText(
        find.byType(TextField),
        'HANNA-BUS|HB-2026-9911|BUS-04|Youssef',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(
        repo.calls
            .where((c) => c.path.endsWith('/boarding'))
            .single
            .body?['method'],
        'qr',
      );
      expect(state.onboard, 1);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'security controls and handbook work without native authentication',
    (tester) async {
      final state = await readyState();
      addTearDown(state.dispose);
      await tester.pumpWidget(
        host(
          state,
          SettingsScreen(state: state, section: SettingsSection.security),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Biometric shift unlock'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('save-settings')));
      expect(state.settings['biometric_unlock'], true);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        host(
          state,
          SettingsScreen(state: state, section: SettingsSection.handbook),
        ),
      );
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Unannounced Child Absence at Stop'));
      expect(find.text(AppStrings('en').t('handbookAbsence')), findsOneWidget);
    },
  );
  testWidgets(
    'navigation and scanner preferences are saved through the settings API',
    (tester) async {
      final repo = FakeRepository();
      final state = await readyState(repository: repo);
      addTearDown(state.dispose);
      await tester.pumpWidget(
        host(
          state,
          SettingsScreen(state: state, section: SettingsSection.navigation),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Night'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Voice guidance'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('save-settings')));
      expect(state.settings['glare_mode'], 'night');
      expect(state.settings['voice_guidance'], false);
      expect(
        repo.calls.lastWhere((c) => c.method == 'PUT').path,
        '/driver/settings',
      );
    },
  );
  testWidgets('messages filter, read badge, quick reply and composer send', (
    tester,
  ) async {
    final repo = FakeRepository(), state = await readyState();
    addTearDown(state.dispose);
    expect(state.unreadCount, 1);
    await tester.pumpWidget(host(state, MessagesScreen(state: state)));
    await tester.pumpAndSettle();
    expect(find.text('Urgent'), findsOneWidget);
    await tester.tap(find.text('Unread 1'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Karim Mansouri'));
    expect(state.unreadCount, 0);
    await tapVisible(tester, find.text('On my way'));
    await tapVisible(tester, find.byKey(const Key('send-message')));
    expect(find.text('On my way'), findsNWidgets(2));
    await tester.enterText(find.byType(TextField), 'Arriving soon');
    await tapVisible(tester, find.byKey(const Key('send-message')));
    expect(find.text('Arriving soon'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    repo.close();
  });

  testWidgets(
    'open thread polls every ten seconds and stops while paused and disposed',
    (tester) async {
      final repo = FakeRepository();
      final state = await readyState(repository: repo);
      addTearDown(state.dispose);
      await tester.pumpWidget(
        host(
          state,
          MessageThreadScreen(
            state: state,
            parentId: 'parent-1',
            childId: 'child-1',
          ),
        ),
      );
      await tester.pumpAndSettle();
      int count() => repo.calls
          .where((c) => c.path.startsWith('/driver/messages/'))
          .length;
      expect(count(), 1);
      await tester.pump(const Duration(seconds: 10));
      await tester.pump();
      expect(count(), 2);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 20));
      expect(count(), 2);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(count(), 3);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 20));
      expect(count(), 3);
    },
  );

  testWidgets(
    'history period fetch and performance metrics use contract data',
    (tester) async {
      final repo = FakeRepository(), state = await readyState();
      addTearDown(state.dispose);
      await tester.pumpWidget(host(state, HistoryScreen(state: state)));
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsOneWidget);
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      final calls = (state.repository as FakeRepository).calls;
      expect(calls.any((c) => c.path == '/driver/history?period=month'), true);
      expect(calls.any((c) => c.path == '/driver/history?period=all'), true);
      await tester.pumpWidget(host(state, StatsScreen(state: state)));
      await tester.pumpAndSettle();
      expect(find.text('4.9'), findsOneWidget);
      await tapVisible(tester, find.text('Trips per day'));
      expect(find.byType(WeekdayChart), findsOneWidget);
      repo.close();
    },
  );

  testWidgets('dossier tabs expose medical protocol and guardian dialer', (
    tester,
  ) async {
    final calls = FakeCalls(), state = await readyState();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      host(
        state,
        DossierScreen(state: state, childId: 'child-1', calls: calls),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dossier-medical')));
    await tester.pumpAndSettle();
    expect(find.text('Peanut allergy'), findsOneWidget);
    await tester.tap(find.byKey(const Key('dossier-guardian')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('guardian-phone')));
    await tapVisible(tester, find.byKey(const Key('guardian-backup_phone')));
    expect(calls.numbers, ['+213550123456', '+213550789012']);
  });

  testWidgets('profile saves name and phone; passport and telemetry render', (
    tester,
  ) async {
    final state = await readyState();
    addTearDown(state.dispose);
    await tester.pumpWidget(host(state, EditProfileScreen(state: state)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Ahmed Updated');
    await tester.enterText(find.byType(TextField).at(1), '+213551234567');
    await tapVisible(tester, find.byKey(const Key('save-profile')));
    expect(state.profile['user']['name'], 'Ahmed Updated');
    await tester.pumpWidget(
      host(state, PassportScreen(state: state, busId: 'bus-04')),
    );
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Insurance expiry'));
    expect(find.text('2027-06-30'), findsOneWidget);
    await tester.pumpWidget(host(state, TelemetryScreen(state: state)));
    await tester.pumpAndSettle();
    expect(find.text('Maximum speed in km/h'), findsOneWidget);
  });

  testWidgets('dispatch contacts use API numbers with injected dialer', (
    tester,
  ) async {
    final calls = FakeCalls(), state = await readyState();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      host(state, ContactsScreen(state: state, calls: calls)),
    );
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('call-coordinator')));
    expect(calls.numbers, ['+213550889900']);
  });

  testWidgets(
    'settings persist exact palette keys and apply live RTL and brightness',
    (tester) async {
      final state = await readyState();
      addTearDown(state.dispose);
      await tester.pumpWidget(
        host(
          state,
          SettingsScreen(state: state, section: SettingsSection.localization),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ocean Blue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('save-settings')));
      expect(state.palette, HannaPalette.ocean);
      expect(state.brightness, Brightness.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(
        jsonDecode(prefs.getString('driver_settings')!)['theme_palette'],
        'ocean-blue',
      );
      await tapVisible(tester, find.byKey(const Key('language-ar')));
      expect(state.locale.languageCode, 'ar');
      expect(
        Directionality.of(tester.element(find.byType(SettingsScreen))),
        TextDirection.rtl,
      );
      final restored = DriverState(
        repository: FakeRepository(),
        location: FakeLocation(),
      );
      await restored.init();
      expect(restored.palette, HannaPalette.ocean);
      expect(restored.brightness, Brightness.dark);
      expect(restored.locale.languageCode, 'ar');
      restored.dispose();
    },
  );

  test(
    'all operational settings round trip and failures preserve preferences',
    () async {
      final repo = FakeRepository();
      final state = await readyState(repository: repo);
      addTearDown(state.dispose);
      final changes = {
        'voice_guidance': false,
        'speed_chime': false,
        'glare_mode': 'night',
        'radar_radius_m': 1000,
        'scan_mode': 'bluetooth',
        'scan_chime': false,
        'biometric_unlock': true,
        'quick_pin_enabled': true,
        'privacy_lock_minutes': 30,
        'theme_palette': 'teal-gray',
        'brightness_mode': 'auto',
      };
      expect(await state.saveSettings(changes), true);
      await state.loadSettings();
      for (final entry in changes.entries) {
        expect(state.settings[entry.key], entry.value);
      }
      repo.failNext = 422;
      expect(await state.saveSettings({'theme_palette': 'mustard'}), false);
      expect(state.palette, HannaPalette.tealGray);
      expect(state.error, 'validation');
    },
  );

  testWidgets('read failure provides retry and empty data is supported', (
    tester,
  ) async {
    final repo = FakeRepository();
    final state = await readyState(repository: repo);
    addTearDown(state.dispose);
    repo.failNext = 500;
    await tester.pumpWidget(host(state, TelemetryScreen(state: state)));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings('en').t('serverError')), findsOneWidget);
    await tapVisible(tester, find.text('Retry'));
    expect(find.text('Maximum speed in km/h'), findsOneWidget);
  });

  testWidgets(
    'recovery calls all three auth endpoints with returned reset token',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await AppStrings.load();
      final requests = <http.Request>[];
      final state = DriverState(
        repository: DriverRepository(
          api: DriverApiClient(
            client: MockClient((r) async {
              requests.add(r);
              return http.Response(
                jsonEncode(
                  r.url.path.endsWith('verify-otp')
                      ? {'reset_token': 'verified-token'}
                      : {},
                ),
                200,
              );
            }),
          ),
        ),
        location: FakeLocation(),
      );
      await state.init();
      addTearDown(state.dispose);
      await tester.pumpWidget(host(state, RecoveryScreen(state: state)));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'driver@mail.dz');
      await tapVisible(tester, find.byKey(const Key('recovery-submit')));
      await tester.enterText(find.byType(TextField), '123456');
      await tapVisible(tester, find.byKey(const Key('recovery-submit')));
      await tester.enterText(find.byType(TextField).at(0), 'NewPassword123!');
      await tester.enterText(find.byType(TextField).at(1), 'DifferentPassword');
      await tapVisible(tester, find.byKey(const Key('recovery-submit')));
      expect(requests.length, 2);
      await tester.enterText(find.byType(TextField).at(1), 'NewPassword123!');
      await tapVisible(tester, find.byKey(const Key('recovery-submit')));
      expect(requests.map((r) => r.url.path), [
        '/api/v1/auth/forgot-password',
        '/api/v1/auth/verify-otp',
        '/api/v1/auth/reset-password',
      ]);
      expect(jsonDecode(requests.last.body)['reset_token'], 'verified-token');
      expect(find.text(AppStrings('en').t('passwordReset')), findsOneWidget);
    },
  );
}
