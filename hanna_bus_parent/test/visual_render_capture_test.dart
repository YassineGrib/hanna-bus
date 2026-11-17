import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:hanna_bus_parent/features/children/screens/child_dossier_screen.dart';

const _captureDir = String.fromEnvironment('HANNA_CAPTURE_DIR');

Future<void> _captureBoundary(
  WidgetTester tester,
  GlobalKey key,
  String filename,
) async {
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory(_captureDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    await File('${dir.path}/$filename').writeAsBytes(bytes!.buffer.asUint8List());
  });
}

Future<AppStateController> _controller({
  required HannaPalette palette,
  required Brightness brightness,
  required Locale locale,
  bool authenticated = true,
}) async {
  SharedPreferences.setMockInitialValues({});
  final controller = AppStateController(
    apiClient: HannaApiClient(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      httpClient: MockClient((_) async => throw http.ClientException('Offline')),
    ),
  );
  await controller.init();
  await controller.markOnboardingComplete();
  await controller.setPalette(palette);
  await controller.setBrightness(brightness);
  await controller.setLocale(locale);
  if (authenticated) {
    await controller.login('k.mansouri@mail.dz', 'Password123!');
  }
  return controller;
}

void main() {
  testWidgets(
    'Captures visual verification PNG screenshots across themes and RTL',
    skip: _captureDir.isEmpty,
    (tester) async {
      HannaTypography.useGoogleFonts = false;
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // 1. Login Screen (Mustard Light)
      final loginKey = GlobalKey();
      final c1 = await _controller(
        palette: HannaPalette.mustard,
        brightness: Brightness.light,
        locale: const Locale('en'),
        authenticated: false,
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: loginKey,
          child: HannaBusParentApp(controller: c1),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();
      await _captureBoundary(tester, loginKey, '01-login-mustard-light.png');

      // 2. Home Dashboard (Mustard Light)
      final homeKey = GlobalKey();
      final c2 = await _controller(
        palette: HannaPalette.mustard,
        brightness: Brightness.light,
        locale: const Locale('en'),
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: homeKey,
          child: HannaBusParentApp(controller: c2),
        ),
      );
      await tester.pumpAndSettle();
      await _captureBoundary(tester, homeKey, '02-home-mustard-light.png');

      // 3. Live Tracking (Ocean Dark)
      final trackKey = GlobalKey();
      final c3 = await _controller(
        palette: HannaPalette.ocean,
        brightness: Brightness.dark,
        locale: const Locale('en'),
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: trackKey,
          child: HannaBusParentApp(controller: c3),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nav-item-1')));
      await tester.pumpAndSettle();
      await _captureBoundary(tester, trackKey, '03-tracking-ocean-dark.png');

      // 4. Child Dossier (Arabic RTL Teal-Gray)
      final dossierKey = GlobalKey();
      final c4 = await _controller(
        palette: HannaPalette.tealGray,
        brightness: Brightness.light,
        locale: const Locale('ar'),
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: dossierKey,
          child: AppStateScope(
            controller: c4,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: const Locale('ar'),
              supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: HannaTheme.build(
                palette: HannaPalette.tealGray,
                brightness: Brightness.light,
                locale: const Locale('ar'),
              ),
              home: ChildDossierScreen(childId: c4.children.first.id),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _captureBoundary(tester, dossierKey, '04-dossier-ar-teal-light.png');
    },
  );
}
