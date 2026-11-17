import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanna_bus_parent/core/network/hanna_api_client.dart';
import 'package:hanna_bus_parent/core/state/app_state.dart';
import 'package:hanna_bus_parent/core/theme/hanna_tokens.dart';
import 'package:hanna_bus_parent/core/theme/hanna_typography.dart';
import 'package:hanna_bus_parent/features/profile/screens/edit_profile_screen.dart';
import 'package:hanna_bus_parent/features/profile/screens/emergency_screen.dart';
import 'package:hanna_bus_parent/features/profile/screens/profile_screen.dart';
import 'package:hanna_bus_parent/features/settings/screens/appearance_settings_screen.dart';
import 'package:hanna_bus_parent/features/settings/screens/delete_account_screen.dart';
import 'package:hanna_bus_parent/features/settings/screens/notification_prefs_screen.dart';
import 'package:hanna_bus_parent/features/settings/screens/settings_hub_screen.dart';
import 'package:hanna_bus_parent/features/settings/screens/terms_privacy_screen.dart';

Future<AppStateController> _loggedInController() async {
  SharedPreferences.setMockInitialValues({});
  final controller = AppStateController(
    apiClient: HannaApiClient(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      httpClient: MockClient((_) async => throw http.ClientException('Offline')),
    ),
  );
  await controller.init();
  await controller.login('k.mansouri@mail.dz', 'Password123!');
  return controller;
}

Widget _wrap(AppStateController controller, Widget home) {
  HannaTypography.useGoogleFonts = false;
  return AppStateScope(
    controller: controller,
    child: AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return MaterialApp(
          locale: controller.locale,
          supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: HannaTheme.build(
            palette: controller.palette,
            brightness: controller.brightness,
            locale: controller.locale,
          ),
          home: home,
        );
      },
    ),
  );
}

void main() {
  group('Modules 02 & 03 Profile, Emergency & Settings', () {
    testWidgets('ProfileScreen navigates to SettingsHubScreen via gear button', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Karim Mansouri'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('profile-settings-gear')));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsHubScreen), findsOneWidget);
      expect(find.text('Appearance & Alerts'), findsOneWidget);
    });

    testWidgets('EditProfileScreen saves updated profile name & EmergencyScreen renders SOS desk', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const EditProfileScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Karim M. Parent');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -180));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(controller.currentUser.name, equals('Karim M. Parent'));

      await tester.pumpWidget(_wrap(controller, const EmergencyScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Emergency Dispatch'), findsOneWidget);
    });

    testWidgets('AppearanceSettingsScreen changes palette, brightness & RTL Arabic cleanly', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const AppearanceSettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ocean Blue'));
      await tester.pumpAndSettle();
      expect(controller.palette, equals(HannaPalette.ocean));

      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();
      expect(controller.brightness, equals(Brightness.dark));

      await tester.drag(find.byType(ListView).first, const Offset(0, -240));
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      expect(controller.locale, equals(const Locale('ar')));
    });

    testWidgets('NotificationPrefsScreen updates geofence radius & DeleteAccountScreen requires DELETE', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const NotificationPrefsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('500m'));
      await tester.pumpAndSettle();
      expect(controller.alertSettings.globalRadiusMeters, equals(500));

      await tester.pumpWidget(_wrap(controller, const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'WRONG');
      await tester.tap(find.text('Delete Account').last);
      await tester.pumpAndSettle();
      expect(controller.isAuthenticated, isTrue);

      await tester.enterText(find.byType(TextField).first, 'DELETE');
      await tester.tap(find.text('Delete Account').last);
      await tester.pumpAndSettle();
      expect(controller.isAuthenticated, isFalse);
    });

    testWidgets('TermsPrivacyScreen displays transport privacy and telemetry policy', (tester) async {
      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const TermsPrivacyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Terms & Privacy Policy'), findsOneWidget);
      expect(find.textContaining('Encrypted QR'), findsWidgets);
    });
  });
}
