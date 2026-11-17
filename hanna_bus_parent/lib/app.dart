import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/motion/hanna_motion.dart';
import 'core/state/app_state.dart';
import 'core/theme/hanna_tokens.dart';
import 'features/auth/screens/auth_success_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/link_child_onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/children/screens/children_list_screen.dart';
import 'features/home/home_shell.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/tracking/screens/live_tracking_screen.dart';
import 'features/tracking/screens/trip_history_screen.dart';

class HannaBusParentApp extends StatelessWidget {
  const HannaBusParentApp({super.key, required this.controller});
  final AppStateController controller;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return MaterialApp(
            title: 'Hanna Bus Parent',
            debugShowCheckedModeBanner: false,
            locale: controller.locale,
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
              palette: controller.palette,
              brightness: controller.brightness,
              locale: controller.locale,
            ),
            home: _AppFlowGate(controller: controller),
          );
        },
      ),
    );
  }
}

enum _RootStage { splash, onboarding, login, register, linkChild, authSuccess, home }

class _AppFlowGate extends StatefulWidget {
  const _AppFlowGate({required this.controller});
  final AppStateController controller;

  @override
  State<_AppFlowGate> createState() => _AppFlowGateState();
}

class _AppFlowGateState extends State<_AppFlowGate> {
  late _RootStage _stage;

  @override
  void initState() {
    super.initState();
    _stage = widget.controller.isAuthenticated ? _RootStage.home : _RootStage.splash;
    widget.controller.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!widget.controller.isAuthenticated && _stage == _RootStage.home) {
      setState(() => _stage = _RootStage.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case _RootStage.splash:
        return SplashScreen(
          onFinished: () {
            if (!mounted) return;
            setState(() {
              if (widget.controller.isAuthenticated) {
                _stage = _RootStage.home;
              } else if (!widget.controller.onboardingComplete) {
                _stage = _RootStage.onboarding;
              } else {
                _stage = _RootStage.login;
              }
            });
          },
        );

      case _RootStage.onboarding:
        return OnboardingScreen(
          onCompleted: () {
            if (!mounted) return;
            setState(() => _stage = _RootStage.login);
          },
        );

      case _RootStage.login:
        return LoginScreen(
          onAuthenticated: () => setState(() => _stage = _RootStage.home),
          onOpenRegister: () => setState(() => _stage = _RootStage.register),
          onOpenForgot: () {
            Navigator.of(context).push(
              HannaMotion.route(
                ForgotPasswordScreen(
                  onResetComplete: () {
                    if (mounted) setState(() => _stage = _RootStage.authSuccess);
                  },
                ),
              ),
            );
          },
        );

      case _RootStage.register:
        return RegisterScreen(
          onRegistered: () => setState(() => _stage = _RootStage.linkChild),
          onOpenLogin: () => setState(() => _stage = _RootStage.login),
        );

      case _RootStage.linkChild:
        return LinkChildOnboardingScreen(
          onContinue: () => setState(() => _stage = _RootStage.authSuccess),
        );

      case _RootStage.authSuccess:
        return AuthSuccessScreen(
          onContinue: () => setState(() => _stage = _RootStage.home),
        );

      case _RootStage.home:
        return Builder(
          builder: (navCtx) => HomeShell(
            onOpenTripHistory: () {
              Navigator.of(navCtx).push(
                HannaMotion.route(const TripHistoryScreen()),
              );
            },
            trackBuilder: (_, onBack) => LiveTrackingScreen(onBack: onBack),
            childrenBuilder: (_, onOpenTrack) => ChildrenListScreen(onOpenTrack: onOpenTrack),
            profileBuilder: (_) => ProfileScreen(
              onSignedOut: () {
                if (mounted) setState(() => _stage = _RootStage.login);
              },
            ),
          ),
        );
    }
  }
}
