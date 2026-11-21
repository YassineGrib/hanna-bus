import 'dart:convert';
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
import 'package:hanna_bus_parent/features/home/screens/home_dashboard_screen.dart';
import 'package:hanna_bus_parent/features/profile/screens/add_child_screen.dart';
import 'package:hanna_bus_parent/features/tracking/screens/live_tracking_screen.dart';

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
  group('Empty State (Active trip 404 when parent has no children)', () {
    test(
      'HannaApiClient getActiveTrip returns null on 404 without throwing',
      () async {
        final client = HannaApiClient(
          baseUrl: 'http://127.0.0.1:8000/api/v1',
          httpClient: MockClient((request) async {
            if (request.url.path.contains('/parent/tracking/active-trip')) {
              return http.Response(
                jsonEncode({'message': 'No active trip'}),
                404,
              );
            }
            return http.Response(jsonEncode({}), 200);
          }),
        );

        final trip = await client.getActiveTrip();
        expect(trip, isNull);
      },
    );

    testWidgets(
      'LiveTrackingScreen renders clean empty state when parent has no children and opens link flow',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        SharedPreferences.setMockInitialValues({});
        // Mock client that returns user with 0 children and 404 on active trip
        final client = HannaApiClient(
          baseUrl: 'http://127.0.0.1:8000/api/v1',
          httpClient: MockClient((request) async {
            final p = request.url.path;
            if (p.contains('/auth/login')) {
              return http.Response(
                jsonEncode({
                  'token': 'mock-token',
                  'user': {
                    'id': '10',
                    'name': 'Sara Mansouri',
                    'email': 'sara@mail.dz',
                    'phone': '+213 555 00 11 22',
                    'primary_bus_stop': 'Stop 01',
                    'theme_palette': 'mustard',
                    'brightness_mode': 'light',
                    'locale': 'en',
                  },
                }),
                200,
              );
            }
            if (p.contains('/parent/children')) {
              return http.Response(jsonEncode({'data': []}), 200);
            }
            if (p.contains('/parent/tracking/active-trip')) {
              return http.Response(
                jsonEncode({'message': 'No active trip found'}),
                404,
              );
            }
            if (p.contains('/parent/support/messages')) {
              return http.Response(jsonEncode([]), 200);
            }
            if (p.contains('/parent/notifications')) {
              return http.Response(jsonEncode({'data': []}), 200);
            }
            if (p.contains('/parent/bulletins')) {
              return http.Response(jsonEncode({'data': []}), 200);
            }
            if (p.contains('/parent/settings/alerts')) {
              return http.Response(
                jsonEncode({
                  'proximity_alert_enabled': true,
                  'global_radius_meters': 300,
                  'quiet_hours_enabled': false,
                  'quiet_hours_start': '21:00',
                  'quiet_hours_end': '06:30',
                  'alert_channels': ['push', 'sms'],
                  'speeding_threshold_kmh': 60,
                  'delay_tolerance_minutes': 10,
                }),
                200,
              );
            }
            if (p.contains('/parent/emergency-contacts')) {
              return http.Response(jsonEncode({'data': []}), 200);
            }
            if (p.contains('/parent/tracking/history')) {
              return http.Response(jsonEncode({'trips': []}), 200);
            }
            return http.Response(jsonEncode({}), 200);
          }),
        );

        final controller = AppStateController(apiClient: client);
        await controller.init();
        await controller.login('sara@mail.dz', 'Password123!');

        expect(controller.children, isEmpty);
        expect(controller.activeTrip, isNull);
        expect(controller.lastError, isNull);

        await tester.pumpWidget(_wrap(controller, const LiveTrackingScreen()));
        await tester.pumpAndSettle();

        // Verify friendly empty state title
        expect(find.text('Link your child to follow the bus'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('empty-state-link-child-btn')),
          findsOneWidget,
        );

        // Tap link child button
        await tester.tap(
          find.byKey(const ValueKey('empty-state-link-child-btn')),
        );
        await tester.pumpAndSettle();

        // Verify navigated to AddChildScreen
        expect(find.byType(AddChildScreen), findsOneWidget);
      },
    );

    testWidgets(
      'HomeDashboardScreen renders clean empty state when parent has no children',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        SharedPreferences.setMockInitialValues({});
        final client = HannaApiClient(
          baseUrl: 'http://127.0.0.1:8000/api/v1',
          httpClient: MockClient((request) async {
            final p = request.url.path;
            if (p.contains('/auth/login')) {
              return http.Response(
                jsonEncode({
                  'token': 'mock-token',
                  'user': {
                    'id': '10',
                    'name': 'Sara Mansouri',
                    'email': 'sara@mail.dz',
                    'phone': '+213 555 00 11 22',
                    'primary_bus_stop': 'Stop 01',
                    'theme_palette': 'mustard',
                    'brightness_mode': 'light',
                    'locale': 'en',
                  },
                }),
                200,
              );
            }
            if (p.contains('/parent/children')) {
              return http.Response(jsonEncode({'data': []}), 200);
            }
            if (p.contains('/parent/tracking/active-trip')) {
              return http.Response(
                jsonEncode({'message': 'No active trip found'}),
                404,
              );
            }
            if (p.contains('/parent/support/messages')) {
              return http.Response(jsonEncode([]), 200);
            }
            if (p.contains('/parent/notifications')) {
              return http.Response(jsonEncode({'data': []}), 200);
            }
            if (p.contains('/parent/bulletins')) {
              return http.Response(jsonEncode({'data': []}), 200);
            }
            if (p.contains('/parent/settings/alerts')) {
              return http.Response(
                jsonEncode({
                  'proximity_alert_enabled': true,
                  'global_radius_meters': 300,
                  'quiet_hours_enabled': false,
                  'quiet_hours_start': '21:00',
                  'quiet_hours_end': '06:30',
                  'alert_channels': ['push', 'sms'],
                  'speeding_threshold_kmh': 60,
                  'delay_tolerance_minutes': 10,
                }),
                200,
              );
            }
            if (p.contains('/parent/emergency-contacts')) {
              return http.Response(jsonEncode({'data': []}), 200);
            }
            if (p.contains('/parent/tracking/history')) {
              return http.Response(jsonEncode({'trips': []}), 200);
            }
            return http.Response(jsonEncode({}), 200);
          }),
        );

        final controller = AppStateController(apiClient: client);
        await controller.init();
        await controller.login('sara@mail.dz', 'Password123!');

        await tester.pumpWidget(
          _wrap(
            controller,
            HomeDashboardScreen(
              onOpenTrack: () {},
              onOpenChildren: () {},
              onOpenHistory: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Empty state on dashboard
        expect(
          find.byKey(const ValueKey('home-empty-state-card')),
          findsOneWidget,
        );
        expect(find.text('Link your child to follow the bus'), findsOneWidget);

        // Tap link child button on dashboard
        await tester.tap(find.byKey(const ValueKey('home-link-child-btn')));
        await tester.pumpAndSettle();

        expect(find.byType(AddChildScreen), findsOneWidget);
      },
    );
  });
}
