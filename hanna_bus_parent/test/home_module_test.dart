import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanna_bus_parent/core/network/hanna_api_client.dart';
import 'package:hanna_bus_parent/core/state/app_state.dart';
import 'package:hanna_bus_parent/core/theme/hanna_tokens.dart';
import 'package:hanna_bus_parent/core/theme/hanna_typography.dart';
import 'package:hanna_bus_parent/features/home/home_shell.dart';
import 'package:hanna_bus_parent/features/home/screens/notifications_screen.dart';
import 'package:hanna_bus_parent/features/home/screens/quick_qr_pass_screen.dart';
import 'package:hanna_bus_parent/features/home/screens/updates_support_screen.dart';

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
  group('Module 06 Home Hub & 4 screens', () {
    testWidgets('HomeShell + HomeDashboard renders hero card, switches child, toggles absence and switches tabs', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(
        _wrap(
          controller,
          HomeShell(
            trackBuilder: (_, _) => const Center(child: Text('Track Tab')),
            childrenBuilder: (_, _) => const Center(child: Text('Children Tab')),
            profileBuilder: (_) => const Center(child: Text('Profile Tab')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Karim Mansouri'), findsOneWidget);
      expect(find.textContaining('6 min'), findsWidgets);

      // Switch child chip to Amina
      await tester.tap(find.text('Amina'));
      await tester.pumpAndSettle();
      expect(controller.selectedChild?.fullName, contains('Amina'));

      // Switch to Track tab via hero CTA
      await tester.tap(find.text('Track Live'));
      await tester.pumpAndSettle();
      expect(find.text('Track Tab'), findsOneWidget);

      // Switch back to Home tab via floating nav bar and toggle absence
      await tester.tap(find.byKey(const ValueKey('nav-item-0')));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).last, const Offset(0, -240));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Report Absence'));
      await tester.pumpAndSettle();
      expect(controller.selectedChild?.transitStatus, equals('absent'));
    });

    testWidgets('NotificationsScreen filters alerts and marks all read', (tester) async {
      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const NotificationsScreen()));
      await tester.pumpAndSettle();

      expect(controller.unreadNotificationsCount, greaterThan(0));
      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      expect(controller.unreadNotificationsCount, equals(0));
    });

    testWidgets('QuickQrPassScreen renders live QrImageView and cached child metadata', (tester) async {
      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const QuickQrPassScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('Youssef Mansouri'), findsWidgets);
      expect(find.text('HB-304'), findsWidgets);
    });

    testWidgets('UpdatesSupportScreen renders school bulletins and dispatches driver message', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const UpdatesSupportScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Thursday Early Dismissal'), findsOneWidget);
      await tester.ensureVisible(find.byType(TextField).first);
      await tester.enterText(find.byType(TextField).first, 'Grandmother will meet Bus 04.');
      await tester.ensureVisible(find.text('Send Message'));
      await tester.tap(find.text('Send Message'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('HomeDashboard toggles between Morning and Return schedule periods', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(
        _wrap(
          controller,
          HomeShell(
            trackBuilder: (_, _) => const SizedBox.shrink(),
            childrenBuilder: (_, _) => const SizedBox.shrink(),
            profileBuilder: (_) => const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Return'), findsOneWidget);
      await tester.tap(find.text('Return'));
      await tester.pumpAndSettle();
      expect(find.textContaining('15:30'), findsWidgets);
    });
  });
}
