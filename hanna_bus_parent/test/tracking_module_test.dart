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
import 'package:hanna_bus_parent/features/tracking/screens/attendance_analytics_screen.dart';
import 'package:hanna_bus_parent/features/tracking/screens/corridor_timeline_screen.dart';
import 'package:hanna_bus_parent/features/tracking/screens/live_tracking_screen.dart';
import 'package:hanna_bus_parent/features/tracking/screens/report_absence_screen.dart';
import 'package:hanna_bus_parent/features/tracking/screens/trip_history_screen.dart';
import 'package:hanna_bus_parent/features/tracking/widgets/attendance_bar_chart.dart';
import 'package:hanna_bus_parent/features/tracking/widgets/stylized_route_map.dart';

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
  group('Module 05 Live Tracking, History, Replay, Analytics & Absence', () {
    testWidgets('LiveTrackingScreen renders StylizedRouteMap and navigates to History & Timeline', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const LiveTrackingScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(StylizedRouteMap), findsOneWidget);
      expect(find.textContaining('6 min'), findsWidgets);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Trip History'), findsOneWidget);
    });

    testWidgets('TripHistoryScreen filters morning/return and opens TripReplayScreen with QR audit', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const TripHistoryScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('07:25'), findsWidgets);
      await tester.tap(find.text('Return'));
      await tester.pumpAndSettle();
      expect(find.textContaining('15:30'), findsWidgets);

      await tester.tap(find.textContaining('15:30').first);
      await tester.pumpAndSettle();
      expect(find.text('Trip Replay & QR Audit'), findsOneWidget);
      expect(find.textContaining('Parent QR Handover'), findsWidgets);
    });

    testWidgets('CorridorTimelineScreen lists all live stations', (tester) async {
      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const CorridorTimelineScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Martyrs Square'), findsOneWidget);
      expect(find.text('El Mouradia Upper'), findsOneWidget);
      expect(find.text('El-Feth Main Gate'), findsOneWidget);
    });

    testWidgets('AttendanceAnalyticsScreen displays bar chart & ReportAbsenceScreen updates status', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const AttendanceAnalyticsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AttendanceBarChart), findsOneWidget);
      expect(find.textContaining('98.4%'), findsWidgets);

      await tester.pumpWidget(_wrap(controller, const ReportAbsenceScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Family Travel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm Absence Today'));
      await tester.pumpAndSettle();

      expect(controller.selectedChild?.transitStatus, equals('absent'));
    });

    testWidgets('LiveTrackingScreen shows active geofence proximity alert banner', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const LiveTrackingScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('350m'), findsWidgets);
    });
  });
}
