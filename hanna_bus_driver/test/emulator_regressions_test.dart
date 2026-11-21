import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hanna_bus_driver/core/network/driver_api_client.dart';
import 'package:hanna_bus_driver/core/l10n/app_strings.dart';
import 'package:hanna_bus_driver/core/network/driver_repository.dart';
import 'package:hanna_bus_driver/core/services/location_source.dart';
import 'package:hanna_bus_driver/core/state/app_state.dart';
import 'package:hanna_bus_driver/core/widgets/privacy_guard.dart';
import 'package:hanna_bus_driver/features/auth/auth_screens.dart';
import 'package:hanna_bus_driver/features/home/home_shell.dart';
import 'helpers.dart';

class PendingLocation extends FakeLocation {
  Completer<DriverPosition>? pending;
  @override
  Future<DriverPosition> current({bool requestPermission = false}) =>
      pending?.future ?? super.current(requestPermission: requestPermission);
}

void main() {
  for (final language in ['en', 'ar']) {
    testWidgets(
      '$language active banner and privacy curtain at 360px and 1.25 scale',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final state = await readyState(active: true);
        addTearDown(state.dispose);
        state.locale = Locale(language);
        state.locationIssue = 'locationFailed';
        await tester.pumpWidget(
          host(
            state,
            PrivacyGuard(
              state: state,
              child: HomeShell(state: state),
            ),
            scale: 1.25,
          ),
        );
        await tester.pumpAndSettle();
        final banner = find.text(
          language == 'ar'
              ? 'تعذر إرسال تحديث الموقع'
              : 'Location update could not be sent',
        );
        await tester.scrollUntilVisible(
          banner,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(banner, findsOneWidget);
        expect(tester.takeException(), isNull);
        final observer =
            tester.state(find.byType(PrivacyGuard)) as WidgetsBindingObserver;
        observer.didChangeAppLifecycleState(AppLifecycleState.paused);
        await tester.pumpAndSettle();
        expect(
          find.text(AppStrings(language).t('resumeShift')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets(
    'inactive never covers data or runs the idle timer; paused and hidden do',
    (tester) async {
      final state = await readyState();
      addTearDown(state.dispose);
      state.settings['privacy_lock_minutes'] = 1;
      await tester.pumpWidget(
        host(
          state,
          PrivacyGuard(
            state: state,
            child: const Scaffold(body: Text('Student')),
          ),
        ),
      );
      final observer =
          tester.state(find.byType(PrivacyGuard)) as WidgetsBindingObserver;
      observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await tester.pump(const Duration(minutes: 2));
      expect(find.text('Resume shift'), findsNothing);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('Resume shift'), findsNothing);
      for (final lifecycle in [
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
      ]) {
        observer.didChangeAppLifecycleState(lifecycle);
        await tester.pump();
        expect(find.text('Resume shift'), findsOneWidget);
        observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await tester.tap(find.text('Resume shift'));
        await tester.pump();
      }
      state.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'location permission acquisition suppresses privacy and always clears its flag',
    (tester) async {
      final location = PendingLocation();
      final state = await readyState(
        location: location,
        active: true,
        tracking: true,
      );
      addTearDown(state.dispose);
      await tester.pump();
      location.pending = Completer<DriverPosition>();
      await tester.pumpWidget(
        host(
          state,
          PrivacyGuard(
            state: state,
            child: const Scaffold(body: Text('Student')),
          ),
        ),
      );
      final send = state.sendLocation(requestPermission: true);
      expect(state.requestingPermission, isTrue);
      final observer =
          tester.state(find.byType(PrivacyGuard)) as WidgetsBindingObserver;
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();
      expect(find.text('Resume shift'), findsNothing);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      location.pending!.completeError(LocationUnavailable());
      await send;
      await tester.pump();
      expect(state.requestingPermission, isFalse);
      expect(find.text('Resume shift'), findsNothing);
      state.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'send banner needs consecutive failures, clears on success and resets the streak',
    (tester) async {
      final repo = FakeRepository();
      final state = await readyState(
        repository: repo,
        active: true,
        tracking: true,
      );
      addTearDown(state.dispose);
      await tester.pump();
      await tester.pumpWidget(host(state, HomeShell(state: state)));
      Future<void> fail() async {
        repo.failNext = 500;
        await state.sendLocation();
        await tester.pump();
      }

      await fail();
      expect(state.locationIssue, isNull);
      await fail();
      expect(state.locationIssue, 'locationFailed');
      await tapVisible(tester, find.text('Location update could not be sent'));
      await state.sendLocation();
      await tester.pump();
      expect(state.locationIssue, isNull);
      expect(find.text('Location update could not be sent'), findsNothing);
      await fail();
      expect(state.locationIssue, isNull);
      await state.sendLocation();
      await fail();
      expect(state.locationIssue, isNull);
      state.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'debug sign in hint requires transport failure and disappears after an HTTP response',
    (tester) async {
      var unreachable = false;
      final repo = DriverRepository(
        api: DriverApiClient(
          client: MockClient((_) async {
            if (unreachable) throw http.ClientException('offline');
            return http.Response('{}', 401);
          }),
        ),
      );
      final state = DriverState(repository: repo, location: FakeLocation());
      addTearDown(state.dispose);
      await state.init();
      await tester.pumpWidget(host(state, AuthScreen(state: state)));
      await tapVisible(tester, find.byKey(const Key('welcome-continue')));
      final hint = find.textContaining('Server unavailable? Explore');
      expect(hint, findsNothing);
      await state.login('wrong', 'wrong');
      await tester.pump();
      expect(hint, findsNothing);
      unreachable = true;
      await state.login('wrong', 'wrong');
      await tester.pump();
      await tester.scrollUntilVisible(
        hint,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(hint, findsOneWidget);
      unreachable = false;
      await state.login('wrong', 'wrong');
      await tester.pump();
      expect(hint, findsNothing);
    },
  );
}
