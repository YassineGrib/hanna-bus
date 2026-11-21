import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanna_bus_parent/app.dart';
import 'package:hanna_bus_parent/core/network/hanna_api_client.dart';
import 'package:hanna_bus_parent/core/state/app_state.dart';
import 'package:hanna_bus_parent/core/theme/hanna_tokens.dart';
import 'package:hanna_bus_parent/core/theme/hanna_typography.dart';
import 'package:hanna_bus_parent/features/home/screens/driver_message_thread_screen.dart';
import 'package:hanna_bus_parent/features/home/screens/home_dashboard_screen.dart';
import 'package:hanna_bus_parent/features/home/screens/updates_support_screen.dart';
import 'package:hanna_bus_parent/features/tracking/screens/live_tracking_screen.dart';

Future<AppStateController> _loggedInController({
  required Locale locale,
  required HannaPalette palette,
  required Brightness brightness,
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
  await controller.markOnboardingComplete();
  await controller.setPalette(palette);
  await controller.setBrightness(brightness);
  await controller.setLocale(locale);
  await controller.login('k.mansouri@mail.dz', 'Password123!');
  return controller;
}

void main() {
  group('Narrow 360px + 1.25x font-scale + RTL overflow verification', () {
    final configs = [
      (
        locale: const Locale('en'),
        palette: HannaPalette.mustard,
        brightness: Brightness.light,
      ),
      (
        locale: const Locale('ar'),
        palette: HannaPalette.tealGray,
        brightness: Brightness.light,
      ),
      (
        locale: const Locale('fr'),
        palette: HannaPalette.ocean,
        brightness: Brightness.dark,
      ),
    ];

    for (final cfg in configs) {
      testWidgets(
        'HannaBusParentApp renders all 4 HomeShell tabs cleanly at 360px 1.25x scale (${cfg.locale.languageCode}/${cfg.palette.name}/${cfg.brightness.name})',
        (tester) async {
          HannaTypography.useGoogleFonts = false;
          tester.view.physicalSize = const Size(360, 780);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          tester.platformDispatcher.textScaleFactorTestValue = 1.25;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          final controller = await _loggedInController(
            locale: cfg.locale,
            palette: cfg.palette,
            brightness: cfg.brightness,
          );

          await tester.pumpWidget(
            MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.25)),
              child: HannaBusParentApp(controller: controller),
            ),
          );
          await tester.pumpAndSettle();

          for (var tabIdx = 0; tabIdx < 4; tabIdx++) {
            await tester.tap(find.byKey(ValueKey('nav-item-$tabIdx')));
            await tester.pumpAndSettle();
            final dynamic exc = tester.takeException();
            expect(exc, isNull, reason: 'Failed on tab $tabIdx');
          }

          final renderedDir = Directionality.of(
            tester.element(find.byKey(const ValueKey('nav-item-0'))),
          );
          expect(
            renderedDir,
            equals(
              cfg.locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          );
        },
      );

      for (final screen in [
        'thread',
        'updates',
        'tracking empty',
        'home empty',
      ]) {
        testWidgets(
          '$screen renders cleanly at 360px 1.25x scale (${cfg.locale.languageCode}/${cfg.palette.name}/${cfg.brightness.name})',
          (tester) async {
            HannaTypography.useGoogleFonts = false;
            tester.view.physicalSize = const Size(360, 780);
            tester.view.devicePixelRatio = 1.0;
            tester.platformDispatcher.textScaleFactorTestValue = 1.25;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            final empty = screen.endsWith('empty');
            final controller = empty
                ? AppStateController()
                : await _loggedInController(
                    locale: cfg.locale,
                    palette: cfg.palette,
                    brightness: cfg.brightness,
                  );
            if (empty) {
              SharedPreferences.setMockInitialValues({});
              await controller.init();
              await controller.setLocale(cfg.locale);
              await controller.setPalette(cfg.palette);
              await controller.setBrightness(cfg.brightness);
            }
            final Widget home = switch (screen) {
              'thread' => const DriverMessageThreadScreen(),
              'updates' => const UpdatesSupportScreen(),
              'tracking empty' => const LiveTrackingScreen(),
              _ => HomeDashboardScreen(
                onOpenTrack: () {},
                onOpenChildren: () {},
                onOpenHistory: () {},
              ),
            };
            await tester.pumpWidget(
              AppStateScope(
                controller: controller,
                child: MaterialApp(
                  locale: cfg.locale,
                  supportedLocales: const [
                    Locale('en'),
                    Locale('ar'),
                    Locale('fr'),
                  ],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  theme: HannaTheme.build(
                    palette: cfg.palette,
                    brightness: cfg.brightness,
                    locale: cfg.locale,
                  ),
                  home: home,
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              MediaQuery.textScalerOf(
                tester.element(find.byWidget(home)),
              ).scale(16),
              20,
            );
            expect(
              tester.takeException(),
              isNull,
              reason: 'Failed on $screen in ${cfg.locale.languageCode}',
            );
            await tester.pumpWidget(const SizedBox.shrink());
            controller.dispose();
          },
        );
      }
    }
  });
}
