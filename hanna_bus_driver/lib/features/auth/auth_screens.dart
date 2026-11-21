import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/hanna_tokens.dart';
import '../../core/widgets/driver_widgets.dart';
import 'recovery_screen.dart';
import '../home/home_shell.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Image.asset('assets/images/hanna-bus-logo.png', width: 180),
    ),
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.state});
  final DriverState state;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController(), password = TextEditingController();
  bool signIn = false, visible = false;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = widget.state;
    String a(String k) => s.design('auth', k);
    return DriverPage(
      state: state,
      title: s.t('appName'),
      back: false,
      trailing: TextButton(
        onPressed: () => state.preferences(
          language: Locale(state.locale.languageCode == 'ar' ? 'en' : 'ar'),
        ),
        child: Text(state.locale.languageCode == 'ar' ? 'English' : 'العربية'),
      ),
      children: [
        const SizedBox(height: 30),
        Center(
          child: Image.asset(
            'assets/images/hanna-bus-logo.png',
            width: 160,
            height: 130,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          a(signIn ? 'in_t1' : 'welcome_t1'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: t.titleSoft,
          ),
        ),
        Text(
          a(signIn ? 'in_t2' : 'welcome_t2'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700),
        ),
        Text(a(signIn ? 'in_sub' : 'welcome_sub'), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        if (!signIn)
          DriverButton(
            a('cont'),
            key: const Key('welcome-continue'),
            onPressed: () => setState(() => signIn = true),
          ),
        if (signIn) ...[
          DriverField(
            label: a('email'),
            controller: email,
            latin: true,
            keyboard: TextInputType.emailAddress,
          ),
          DriverField(
            label: a('password'),
            controller: password,
            icon: 'lock-simple',
            obscure: !visible,
          ),
          Row(
            children: [
              IconButton(
                tooltip: a('password'),
                onPressed: () => setState(() => visible = !visible),
                icon: Icon(
                  visible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    openDriverScreen(context, RecoveryScreen(state: state)),
                child: Text(a('forgot')),
              ),
            ],
          ),
          DriverButton(
            a('sign_in'),
            key: const Key('sign-in'),
            onPressed: state.busy
                ? null
                : () => state.login(email.text, password.text),
          ),
          Text(s.t('demoHelp'), style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}
