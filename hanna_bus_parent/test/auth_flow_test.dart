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
import 'package:hanna_bus_parent/features/auth/screens/auth_success_screen.dart';
import 'package:hanna_bus_parent/features/auth/screens/forgot_password_screen.dart';
import 'package:hanna_bus_parent/features/auth/screens/link_child_onboarding_screen.dart';
import 'package:hanna_bus_parent/features/auth/screens/login_screen.dart';
import 'package:hanna_bus_parent/features/auth/screens/onboarding_screen.dart';
import 'package:hanna_bus_parent/features/auth/screens/register_screen.dart';
import 'package:hanna_bus_parent/features/auth/screens/splash_screen.dart';

Future<AppStateController> _makeController() async {
  SharedPreferences.setMockInitialValues({});
  final controller = AppStateController(
    apiClient: HannaApiClient(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      httpClient: MockClient((_) async => throw http.ClientException('Offline')),
    ),
  );
  await controller.init();
  return controller;
}

Widget _appWrap(AppStateController controller, Widget home) {
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
  group('Module 01 Auth & Onboarding flow', () {
    testWidgets('SplashScreen renders crest logo and triggers completion', (tester) async {
      final controller = await _makeController();
      var done = false;
      await tester.pumpWidget(
        _appWrap(
          controller,
          SplashScreen(
            autoAdvanceDelay: const Duration(milliseconds: 50),
            onFinished: () => done = true,
          ),
        ),
      );

      expect(find.text('Hanna Bus Parent'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();
      expect(done, isTrue);
    });

    testWidgets('OnboardingScreen / WelcomeScreen renders FigCraft welcome and switches runtime language to Arabic RTL', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _makeController();
      var completed = false;
      await tester.pumpWidget(
        _appWrap(
          controller,
          OnboardingScreen(onCompleted: () => completed = true),
        ),
      );

      expect(find.text('Welcome to'), findsOneWidget);
      expect(find.text('Hanna Bus'), findsOneWidget);
      expect(find.text('Safe school rides, tracked live.'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('lang-switch-pill')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      expect(controller.locale, equals(const Locale('ar')));
      expect(find.text('أهلاً بك في'), findsOneWidget);
      expect(find.text('هنّا باص'), findsOneWidget);

      await tester.ensureVisible(find.text('متابعة'));
      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();
      expect(completed, isTrue);
    });

    testWidgets('LoginScreen validates empty submission and signs in with credentials', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _makeController();
      var signedIn = false;
      await tester.pumpWidget(
        _appWrap(
          controller,
          LoginScreen(
            onAuthenticated: () => signedIn = true,
            onOpenRegister: () {},
            onOpenForgot: () {},
          ),
        ),
      );

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.textContaining('@'), findsWidgets);

      await tester.enterText(find.byType(TextField).at(0), 'parent@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'Password123!');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(signedIn, isTrue);
      expect(controller.isAuthenticated, isTrue);
    });

    testWidgets('ForgotPassword -> OTP -> NewPassword resets password cleanly', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _makeController();
      var resetComplete = false;
      await tester.pumpWidget(
        _appWrap(
          controller,
          ForgotPasswordScreen(onResetComplete: () => resetComplete = true),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'k.mansouri@mail.dz');
      await tester.tap(find.text('Send verification code'));
      await tester.pumpAndSettle();

      expect(find.text('Verify your'), findsOneWidget);
      await tester.tap(find.text('Verify & continue'));
      await tester.pumpAndSettle();

      expect(find.text('Create a'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'NewPass2026!');
      await tester.enterText(find.byType(TextField).at(1), 'NewPass2026!');
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();

      expect(resetComplete, isTrue);
      expect(controller.isAuthenticated, isTrue);
    });

    testWidgets('RegisterScreen & LinkChildOnboardingScreen link student code HB-2026-9911', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _makeController();
      var enteredHome = false;

      await tester.pumpWidget(
        _appWrap(
          controller,
          RegisterScreen(
            onRegistered: () {},
            onOpenLogin: () {},
          ),
        ),
      );
      expect(find.text('Create account'), findsWidgets);

      await tester.pumpWidget(
        _appWrap(
          controller,
          LinkChildOnboardingScreen(onContinue: () => enteredHome = true),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'HB-2026-9911');
      await tester.tap(find.text('Link Child Now'));
      await tester.pumpAndSettle();
      expect(controller.children.any((c) => c.studentCode == 'HB-2026-9911'), isTrue);

      await tester.tap(find.text('Continue to Home'));
      await tester.pumpAndSettle();
      expect(enteredHome, isTrue);
    });

    testWidgets('AuthSuccessScreen displays verified confirmation and proceeds to home hub', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = await _makeController();
      var proceeded = false;
      await tester.pumpWidget(
        _appWrap(
          controller,
          AuthSuccessScreen(onContinue: () => proceeded = true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('all set!'), findsOneWidget);
      await tester.tap(find.text('Go to Hanna Bus'));
      await tester.pumpAndSettle();
      expect(proceeded, isTrue);
    });
  });
}
