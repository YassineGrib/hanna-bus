import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:hanna_bus_driver/core/l10n/app_strings.dart';
import 'package:hanna_bus_driver/core/network/driver_api_client.dart';
import 'package:hanna_bus_driver/core/network/driver_repository.dart';
import 'package:hanna_bus_driver/core/services/location_source.dart';
import 'package:hanna_bus_driver/core/services/scanner_source.dart';
import 'package:hanna_bus_driver/core/services/call_source.dart';
import 'package:hanna_bus_driver/core/state/app_state.dart';
import 'package:hanna_bus_driver/core/state/demo_seed.dart';
import 'package:hanna_bus_driver/core/state/models.dart';
import 'package:hanna_bus_driver/core/theme/hanna_tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRepository extends DriverRepository {
  FakeRepository()
    : super(
        api: DriverApiClient(
          client: MockClient((_) async => http.Response('{}', 500)),
        ),
      );
  final seed = DemoSeed();
  final calls = <({String method, String path, Json? body})>[];
  int? failNext;
  @override
  bool get isDemo => false;
  @override
  Future<void> login(String email, String password) async {}
  @override
  Future<dynamic> request(String method, String path, [Json? body]) async {
    calls.add((method: method, path: path, body: body));
    if (failNext != null) {
      final status = failNext!;
      failNext = null;
      throw ApiFailure(status);
    }
    try {
      return seed.request(method, path, body);
    } on DemoFailure catch (e) {
      throw ApiFailure(e.status);
    }
  }

  @override
  Future<void> logout() async {}
}

class FakeLocation implements LocationSource {
  int calls = 0;
  bool denied = false;
  @override
  Future<DriverPosition> current({bool requestPermission = false}) async {
    calls++;
    if (denied) throw LocationUnavailable();
    return const DriverPosition(36.7538, 3.0588, speedKmh: 20, heading: 90);
  }
}

class FakeScanner implements ScannerSource {
  ValueChanged<String>? emit;
  bool disposed = false;
  @override
  Widget preview({
    required ValueChanged<String> onCode,
    required Widget error,
  }) {
    emit = onCode;
    return const ColoredBox(color: Colors.black);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

class FakeCalls implements CallSource {
  final numbers = <String>[];
  @override
  Future<bool> dial(String number) async {
    numbers.add(number);
    return true;
  }
}

Future<DriverState> readyState({
  FakeRepository? repository,
  FakeLocation? location,
  bool active = false,
  bool tracking = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  await AppStrings.load();
  final state = DriverState(
    repository: repository ?? FakeRepository(),
    location: location ?? FakeLocation(),
  );
  await state.init();
  await state.login('driver', 'password');
  if (active) {
    await state.inspect({
      'tires': true,
      'brakes': true,
      'lights': true,
      'fuel': true,
    });
    await state.start();
    if (!tracking) state.didChangeAppLifecycleState(AppLifecycleState.paused);
  }
  return state;
}

Widget host(DriverState state, Widget page, {double scale = 1}) =>
    ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: state.locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: HannaTheme.build(
          palette: state.palette,
          brightness: state.brightness,
          locale: state.locale,
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: page,
      ),
    );
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
