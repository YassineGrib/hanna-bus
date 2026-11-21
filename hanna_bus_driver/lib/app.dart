import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/state/app_state.dart';
import 'core/theme/hanna_tokens.dart';
import 'core/widgets/privacy_guard.dart';
import 'features/auth/auth_screens.dart';
import 'features/home/home_shell.dart';

class DriverApp extends StatelessWidget {
  const DriverApp({super.key, required this.state});
  final DriverState state;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => MaterialApp(
      title: 'Hanna Bus Driver',
      debugShowCheckedModeBanner: false,
      locale: state.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => PrivacyGuard(state: state, child: child!),
      theme: HannaTheme.build(
        palette: state.palette,
        brightness: state.brightness,
        locale: state.locale,
      ),
      home: !state.ready
          ? const SplashScreen()
          : state.authenticated
          ? HomeShell(state: state)
          : AuthScreen(state: state),
    ),
  );
}
