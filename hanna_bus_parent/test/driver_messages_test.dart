import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanna_bus_parent/core/network/hanna_api_client.dart';
import 'package:hanna_bus_parent/core/state/app_state.dart';
import 'package:hanna_bus_parent/core/state/demo_seed.dart';
import 'package:hanna_bus_parent/core/state/models.dart';
import 'package:hanna_bus_parent/core/theme/hanna_tokens.dart';
import 'package:hanna_bus_parent/core/theme/hanna_typography.dart';
import 'package:hanna_bus_parent/features/home/screens/driver_message_thread_screen.dart';
import 'package:hanna_bus_parent/features/home/screens/updates_support_screen.dart';
import 'package:hanna_bus_parent/features/tracking/screens/live_tracking_screen.dart';

// Keep workspace fixtures local while exercising the real messaging HTTP client.
class _MessagingApi extends HannaApiClient {
  _MessagingApi(http.Client client) : super(httpClient: client);

  @override
  Future<AuthSessionResponse> login({
    required String email,
    required String password,
  }) async => AuthSessionResponse(token: 'token', user: DemoSeed.demoUser);
  @override
  Future<List<ChildProfile>> getChildren() async => DemoSeed.children;
  @override
  Future<ActiveTripData?> getActiveTrip({String? childId}) async =>
      DemoSeed.activeTrip(const Locale('en'));
  @override
  Future<List<TripHistorySummary>> getTripHistory({
    String? childId,
    String period = 'all',
  }) async => [];
  @override
  Future<List<SafetyNotificationItem>> getNotifications() async => [];
  @override
  Future<List<SchoolBulletinItem>> getBulletins() async => [];
  @override
  Future<TransitAlertSettings> getAlerts() async =>
      const TransitAlertSettings();
  @override
  Future<List<EmergencyContactItem>> getEmergencyContacts() async => [];
  @override
  Future<AttendanceAnalyticsData> getAnalytics(String childId) async =>
      DemoSeed.analytics(childId, 'Youssef');
}

Future<AppStateController> _loggedInController({
  Locale locale = const Locale('en'),
}) async {
  SharedPreferences.setMockInitialValues({});
  final controller = AppStateController(
    apiClient: HannaApiClient(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      httpClient: MockClient(
        (_) async => throw http.ClientException('Offline'),
      ),
    ),
  );
  await controller.init();
  await controller.setLocale(locale);
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
  test(
    'Read and load failures preserve unread state without demo messages',
    () async {
      SharedPreferences.setMockInitialValues({});
      var failLoad = false;
      final controller = AppStateController(
        apiClient: _MessagingApi(
          MockClient((request) async {
            if (request.method == 'GET' && !failLoad) {
              return http.Response(
                '[{"id":1,"direction":"driver_to_parent","message":"Hello","created_at":"2026-11-21T08:00:00Z","read_at":null}]',
                200,
              );
            }
            return http.Response('{"message":"Unavailable"}', 503);
          }),
        ),
      );
      await controller.init();
      await controller.login('parent@example.com', 'password');
      await controller.markAllDriverMessagesRead();
      expect(controller.unreadDriverMessagesCount, 1);
      failLoad = true;
      expect(await controller.fetchDriverMessages(), isFalse);
      expect(controller.driverMessages.single.message, 'Hello');
      expect(controller.isOfflineDemoMode, isFalse);
      controller.dispose();
    },
  );

  testWidgets(
    'Updates opens the thread and demo refresh preserves sent messages and read state',
    (tester) async {
      final controller = await _loggedInController();
      await tester.pumpWidget(_wrap(controller, const UpdatesSupportScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('open-driver-thread-btn')));
      await tester.pumpAndSettle();
      expect(find.byType(DriverMessageThreadScreen), findsOneWidget);
      expect(controller.unreadDriverMessagesCount, 0);
      await controller.sendDriverMessage('See you soon');
      await controller.refreshDashboardData();
      expect(controller.driverMessages.last.message, 'See you soon');
      expect(controller.unreadDriverMessagesCount, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );

  testWidgets(
    'Online thread polls replies, acknowledges read, sends and cancels polling on dispose',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final messages = <Map<String, dynamic>>[];
      final requests = <http.Request>[];
      final api = _MessagingApi(
        MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            return http.Response(jsonEncode(messages), 200);
          }
          if (request.method == 'POST') {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['recipient_type'], 'driver');
            expect(body['child_id'], DemoSeed.children.first.id);
            messages.add({
              'id': 2,
              'direction': 'parent_to_driver',
              'message': body['message'],
              'created_at': '2026-11-21T08:01:00Z',
              'read_at': null,
            });
            return http.Response('{}', 201);
          }
          messages.first['read_at'] = '2026-11-21T08:02:00Z';
          return http.Response('{}', 200);
        }),
      );
      final controller = AppStateController(apiClient: api);
      await tester.runAsync(() async {
        await controller.init();
        await controller.login('parent@example.com', 'password');
      });
      expect(controller.isOfflineDemoMode, isFalse);
      await tester.pumpWidget(
        _wrap(controller, const DriverMessageThreadScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('No messages yet'), findsOneWidget);

      messages.add({
        'id': 1,
        'direction': 'driver_to_parent',
        'message': 'I am at the stop',
        'created_at': '2026-11-21T08:00:00Z',
        'read_at': null,
      });
      final gets = requests.where((r) => r.method == 'GET').length;
      await tester.pump(const Duration(seconds: 9));
      expect(requests.where((r) => r.method == 'GET').length, gets);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('I am at the stop'), findsOneWidget);
      expect(
        requests.where((r) => r.method == 'PUT').single.url.path,
        '/api/v1/parent/support/messages/1/read',
      );
      expect(controller.unreadDriverMessagesCount, 0);

      await tester.enterText(
        find.byKey(const ValueKey('driver-message-input')),
        'Please wait for me',
      );
      await tester.tap(find.byKey(const ValueKey('driver-message-send-btn')));
      await tester.pumpAndSettle();
      expect(requests.where((r) => r.method == 'POST'), hasLength(1));
      expect(controller.driverMessages.last.id, '2');
      expect(controller.driverMessages.last.isRead, isFalse);
      messages.last['read_at'] = '2026-11-21T08:03:00Z';
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(controller.driverMessages.last.isRead, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      final count = requests.length;
      await tester.pump(const Duration(seconds: 30));
      expect(requests, hasLength(count));
      controller.dispose();
    },
  );

  testWidgets(
    'Failed send keeps composer text and does not add a sent bubble or demo data',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppStateController(
        apiClient: _MessagingApi(
          MockClient((request) async {
            return request.method == 'GET'
                ? http.Response('[]', 200)
                : http.Response('{"message":"Unavailable"}', 503);
          }),
        ),
      );
      await tester.runAsync(() async {
        await controller.init();
        await controller.login('parent@example.com', 'password');
      });
      await tester.pumpWidget(
        _wrap(controller, const DriverMessageThreadScreen()),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('driver-message-input')),
        'Please wait for me',
      );
      await tester.tap(find.byKey(const ValueKey('driver-message-send-btn')));
      await tester.pumpAndSettle();
      expect(controller.driverMessages, isEmpty);
      expect(controller.isOfflineDemoMode, isFalse);
      expect(
        find.text('Message could not be sent. Please try again.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('driver-message-input')),
            )
            .controller!
            .text,
        'Please wait for me',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );

  group(
    'Driver Messaging Feature (Thread, Bubbles, Quick Replies, Badges & RTL)',
    () {
      testWidgets(
        'DriverMessageThreadScreen renders driver and parent bubbles with timestamps and read ticks',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          final controller = await _loggedInController();
          await tester.pumpWidget(
            _wrap(controller, const DriverMessageThreadScreen()),
          );
          await tester.pumpAndSettle();

          // Verify header and driver info
          expect(find.text('Ahmed Benali'), findsWidgets);
          expect(find.textContaining('Bus 04'), findsWidgets);

          // Verify messages rendered
          expect(find.textContaining('Good morning Mr. Ahmed'), findsOneWidget);
          expect(
            find.textContaining('arriving in about 3 minutes'),
            findsOneWidget,
          );
          expect(
            find.textContaining('Youssef has safely boarded'),
            findsOneWidget,
          );

          // Verify read ticks on parent messages
          expect(find.byKey(const ValueKey('read-tick-msg-1')), findsOneWidget);
          expect(find.byKey(const ValueKey('read-tick-msg-3')), findsOneWidget);
          expect(
            tester
                .getCenter(find.byKey(const ValueKey('message-bubble-msg-1')))
                .dx,
            greaterThan(
              tester
                  .getCenter(find.byKey(const ValueKey('message-bubble-msg-2')))
                  .dx,
            ),
          );
        },
      );

      testWidgets('Composer allows entering and sending message to driver', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final controller = await _loggedInController();
        await tester.pumpWidget(
          _wrap(controller, const DriverMessageThreadScreen()),
        );
        await tester.pumpAndSettle();

        final inputFinder = find.byKey(const ValueKey('driver-message-input'));
        expect(inputFinder, findsOneWidget);

        await tester.enterText(inputFinder, 'Reaching stop in 2 minutes');
        await tester.tap(find.byKey(const ValueKey('driver-message-send-btn')));
        await tester.pumpAndSettle();

        expect(find.text('Reaching stop in 2 minutes'), findsOneWidget);
      });

      testWidgets('Quick reply chip sends message immediately', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final controller = await _loggedInController();
        await tester.pumpWidget(
          _wrap(controller, const DriverMessageThreadScreen()),
        );
        await tester.pumpAndSettle();

        final quickReplyFinder = find.text('Please wait for me');
        expect(quickReplyFinder, findsOneWidget);

        await tester.tap(quickReplyFinder);
        await tester.pumpAndSettle();

        // Verify sent message appears in thread
        expect(find.text('Please wait for me'), findsWidgets);
      });

      testWidgets(
        'Unread badge shows on entry points and clears when thread is opened',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          final controller = await _loggedInController();
          // Initially msg-4 is unread from driver
          expect(controller.unreadDriverMessagesCount, greaterThan(0));

          // 1. Check entry point in UpdatesSupportScreen
          await tester.pumpWidget(
            _wrap(controller, const UpdatesSupportScreen()),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('updates-driver-unread-badge')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('open-driver-thread-btn')),
            findsOneWidget,
          );

          // 2. Check entry point in LiveTrackingScreen
          await tester.pumpWidget(
            _wrap(controller, const LiveTrackingScreen()),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('tracking-driver-message-btn')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('tracking-driver-unread-badge')),
            findsOneWidget,
          );

          // 3. Open thread: marks read
          await tester.ensureVisible(
            find.byKey(const ValueKey('tracking-driver-message-btn')),
          );
          await tester.tap(
            find.byKey(const ValueKey('tracking-driver-message-btn')),
          );
          await tester.pumpAndSettle();

          expect(find.byType(DriverMessageThreadScreen), findsOneWidget);
          expect(controller.unreadDriverMessagesCount, equals(0));
        },
      );

      testWidgets('DriverMessageThreadScreen renders correctly in Arabic RTL', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final controller = await _loggedInController(
          locale: const Locale('ar'),
        );
        await tester.pumpWidget(
          _wrap(controller, const DriverMessageThreadScreen()),
        );
        await tester.pumpAndSettle();

        final textDirection = Directionality.of(
          tester.element(find.byType(DriverMessageThreadScreen)),
        );
        expect(textDirection, equals(TextDirection.rtl));

        expect(
          tester
              .getCenter(find.byKey(const ValueKey('message-bubble-msg-1')))
              .dx,
          lessThan(
            tester
                .getCenter(find.byKey(const ValueKey('message-bubble-msg-2')))
                .dx,
          ),
        );

        // Arabic quick replies
        expect(find.text('يرجى الانتظار، نحن قادمون'), findsOneWidget);
        expect(find.text('طفلي غائب اليوم'), findsOneWidget);

        final before = controller.driverMessages.length;
        await tester.ensureVisible(find.text('طفلي غائب اليوم'));
        await tester.pumpAndSettle();
        // Tap Arabic quick reply
        await tester.tap(find.text('طفلي غائب اليوم'));
        await tester.pumpAndSettle();
        expect(find.text('طفلي غائب اليوم'), findsWidgets);
        expect(controller.driverMessages.length, before + 1);
      });
    },
  );
}
