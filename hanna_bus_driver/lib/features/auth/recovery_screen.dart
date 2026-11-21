import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/network/driver_api_client.dart';
import '../../core/widgets/driver_widgets.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key, required this.state, this.initialStep = 0});
  final DriverState state;
  final int initialStep;
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final email = TextEditingController(),
      code = TextEditingController(),
      password = TextEditingController(),
      confirmation = TextEditingController();
  late int step = widget.initialStep;
  String? error, demoCode;
  String resetToken = '';
  bool busy = false, done = false;
  @override
  void dispose() {
    email.dispose();
    code.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> submit({bool resend = false}) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (step == 0 || resend) {
        final result = await widget.state.recovery('forgot-password', {
          'email': email.text.trim(),
        });
        if (!mounted) return;
        setState(() {
          demoCode = result['demo_otp']?.toString();
          step = 1;
        });
      } else if (step == 1) {
        final result = await widget.state.recovery('verify-otp', {
          'email': email.text.trim(),
          'code': code.text.trim(),
        });
        resetToken = result['reset_token']?.toString() ?? '';
        if (resetToken.isEmpty) throw StateError('Missing reset token');
        if (mounted) setState(() => step = 2);
      } else {
        if (password.text.length < 8 || password.text != confirmation.text) {
          setState(() => error = 'passwordMismatch');
          return;
        }
        await widget.state.recovery('reset-password', {
          'email': email.text.trim(),
          'reset_token': resetToken,
          'password': password.text,
          'password_confirmation': confirmation.text,
        });
        if (mounted) setState(() => done = true);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is ApiFailure && e.status == 422
              ? 'recoveryValidation'
              : widget.state.failure(e),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return DriverPage(
      state: widget.state,
      title: s.t(['recoveryEmail', 'recoveryCode', 'recoveryPassword'][step]),
      children: [
        if (busy) const LinearProgressIndicator(),
        if (error != null) Text(s.t(error!)),
        if (done) ...[
          Text(s.t('passwordReset')),
          DriverButton(
            s.t('backToLogin'),
            onPressed: () => Navigator.pop(context),
          ),
        ] else ...[
          if (step == 0) ...[
            Text(s.t('recoveryHint')),
            DriverField(
              label: s.design('auth', 'email'),
              controller: email,
              latin: true,
              keyboard: TextInputType.emailAddress,
            ),
          ],
          if (step == 1) ...[
            Text(email.text, textDirection: TextDirection.ltr),
            if (demoCode != null) Text('${s.t('recoveryDemoCode')}: $demoCode'),
            DriverField(
              label: s.t('code'),
              controller: code,
              latin: true,
              keyboard: TextInputType.number,
            ),
            TextButton(
              onPressed: busy ? null : () => submit(resend: true),
              child: Text(s.t('resend')),
            ),
          ],
          if (step == 2) ...[
            DriverField(
              label: s.t('newPassword'),
              controller: password,
              obscure: true,
              icon: 'lock-simple',
            ),
            DriverField(
              label: s.t('confirmPassword'),
              controller: confirmation,
              obscure: true,
              icon: 'lock-simple',
            ),
          ],
          DriverButton(
            s.t('confirm'),
            key: const Key('recovery-submit'),
            onPressed: busy ? null : submit,
          ),
        ],
      ],
    );
  }
}
