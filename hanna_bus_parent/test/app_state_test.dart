import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanna_bus_parent/core/network/hanna_api_client.dart';
import 'package:hanna_bus_parent/core/state/app_state.dart';
import 'package:hanna_bus_parent/core/theme/hanna_tokens.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  HannaApiClient unreachableClient() {
    return HannaApiClient(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      httpClient: MockClient((_) async => throw http.ClientException('Offline')),
    );
  }

  group('AppStateController offline demo fallback & persistence', () {
    test('falls back to demo seed when backend is unreachable on login and caches QR pass', () async {
      final controller = AppStateController(apiClient: unreachableClient());
      await controller.init();

      final ok = await controller.login('k.mansouri@mail.dz', 'Password123!');
      expect(ok, isTrue);
      expect(controller.isOfflineDemoMode, isTrue);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.children.length, greaterThanOrEqualTo(3));
      expect(controller.selectedChild?.fullName, contains('Youssef'));
      expect(controller.activeTrip, isNotNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('hanna_cached_qr_child_name'), isNotEmpty);
    });

    test('persists palette, brightness, and trilingual locale across restarts', () async {
      final first = AppStateController(apiClient: unreachableClient());
      await first.init();
      await first.setPalette(HannaPalette.ocean);
      await first.setBrightness(Brightness.dark);
      await first.setLocale(const Locale('ar'));

      final second = AppStateController(apiClient: unreachableClient());
      await second.init();

      expect(second.palette, equals(HannaPalette.ocean));
      expect(second.brightness, equals(Brightness.dark));
      expect(second.locale, equals(const Locale('ar')));
    });

    test('updates notifications, absence status, and alert settings cleanly offline', () async {
      final controller = AppStateController(apiClient: unreachableClient());
      await controller.init();
      await controller.login('k.mansouri@mail.dz', 'Password123!');

      final firstChild = controller.children.first;
      expect(controller.unreadNotificationsCount, greaterThan(0));
      await controller.markAllNotificationsRead();
      expect(controller.unreadNotificationsCount, equals(0));

      await controller.reportAbsence(firstChild.id, reason: 'Family trip');
      expect(
        controller.children.firstWhere((c) => c.id == firstChild.id).transitStatus,
        equals('absent'),
      );

      await controller.resumeRideToday(firstChild.id);
      expect(
        controller.children.firstWhere((c) => c.id == firstChild.id).transitStatus,
        equals('at_home'),
      );

      await controller.updateAlertSettings(
        controller.alertSettings.copyWith(globalRadiusMeters: 600, smsBackup: true),
      );
      expect(controller.alertSettings.globalRadiusMeters, equals(600));
      expect(controller.alertSettings.smsBackup, isTrue);
    });
  });
}
