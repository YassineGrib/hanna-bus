import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanna_bus_parent/core/network/hanna_api_client.dart';
import 'package:hanna_bus_parent/core/state/app_state.dart';
import 'package:hanna_bus_parent/core/theme/hanna_tokens.dart';

const _liveUrl = String.fromEnvironment('HANNA_LIVE_API_URL');

void main() {
  test(
    'Live Laravel + Sanctum + SQLite end-to-end integration roundtrip (Zero-Seed dynamic verification)',
    skip: _liveUrl.isEmpty ? 'Pass --dart-define=HANNA_LIVE_API_URL=...' : false,
    () async {
      SharedPreferences.setMockInitialValues({});
      final controller = AppStateController(
        apiClient: HannaApiClient(baseUrl: _liveUrl),
      );
      await controller.init();

      // 1. Dynamic registration on live Laravel API
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testEmail = 'parent.$timestamp@hanna-test.dz';
      const testPassword = 'Password123!';

      final regOk = await controller.register(
        name: 'Test Parent Live',
        email: testEmail,
        password: testPassword,
        phone: '+213550123456',
      );
      expect(regOk, isTrue);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.isOfflineDemoMode, isFalse);
      expect(controller.children, isEmpty, reason: 'Fresh account must have 0 children (no fake seed data)');

      // 2. Dynamic child creation in live SQLite
      final child = await controller.saveChild(
        fullName: 'Youssef Test',
        studentCode: 'HB-${timestamp % 10000}',
        schoolName: 'El Wiam Primary School',
        grade: 'Grade 3',
        busNumber: '04',
        stopName: 'Hay El Nasr, Stop 03',
        allergies: 'None',
        dismissalRule: 'Authorized guardian only',
      );
      expect(child.id, isNotEmpty);
      expect(controller.children.length, equals(1));
      expect(controller.selectedChild?.id, equals(child.id));

      // 3. Absence report & resume roundtrip in live database
      await controller.reportAbsence(child.id, reason: 'Live E2E Absence Test');
      await controller.refreshDashboardData();
      expect(
        controller.children.firstWhere((c) => c.id == child.id).transitStatus,
        equals('absent'),
      );

      await controller.resumeRideToday(child.id);
      await controller.refreshDashboardData();
      expect(
        controller.children.firstWhere((c) => c.id == child.id).transitStatus,
        equals('at_home'),
      );

      // 4. Alert settings update roundtrip in live database
      await controller.updateAlertSettings(
        controller.alertSettings.copyWith(globalRadiusMeters: 450),
      );
      final alertsFromServer = await controller.api.getAlerts();
      expect(alertsFromServer.globalRadiusMeters, equals(450));

      // 5. Theme and language preference persistence on live server
      await controller.setPalette(HannaPalette.ocean);
      await controller.setBrightness(Brightness.dark);
      await controller.setLocale(const Locale('ar'));

      final profile = await controller.api.getProfile();
      expect(profile.palette, equals(HannaPalette.ocean));
      expect(profile.brightness, equals(Brightness.dark));
      expect(profile.locale.languageCode, equals('ar'));

      // 6. Logout and re-login verification with Sanctum token
      await controller.logout();
      expect(controller.isAuthenticated, isFalse);

      final loginOk = await controller.login(testEmail, testPassword);
      expect(loginOk, isTrue);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.isOfflineDemoMode, isFalse);
      expect(controller.children.length, equals(1));
      expect(controller.currentUser.email, equals(testEmail));
    },
  );
}
