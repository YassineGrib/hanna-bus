import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';
import '../../../core/widgets/hanna_text_field.dart';
import '../widgets/auth_chrome.dart';
import 'otp_verify_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.onResetComplete,
  });

  final VoidCallback onResetComplete;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController(text: 'k.mansouri@mail.dz');
  String? _emailErr;
  bool _sending = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final s = AppStrings.of(context);
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      setState(() {
        _emailErr = s.tr(
          'Please enter a valid email address.',
          'يرجى إدخال بريد إلكتروني صحيح.',
          'Veuillez entrer une adresse e-mail valide.',
        );
      });
      return;
    }

    setState(() => _sending = true);
    final otp = await AppStateScope.of(context).requestPasswordResetOtp(email);
    if (!mounted) return;
    setState(() => _sending = false);

    Navigator.of(context).push(
      HannaMotion.route(
        OtpVerifyScreen(
          email: email,
          demoOtp: otp,
          onResetComplete: widget.onResetComplete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      body: HannaBackground(
        variant: HannaBackgroundVariant.horizon,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      // Top Bar with Back
                      AuthTopBar(onBack: () => Navigator.pop(context)),
                      const SizedBox(height: 28),
                      // Hero Icon Circle: 96x96, radius 48, fill ACCENT 35% opacity
                      Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: t.accent.withValues(alpha: 0x59 / 255.0),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: HannaIcon(
                              'envelope-simple',
                              size: 52,
                              color: t.text,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 2-line Title & Subtitle
                      AuthHeaderTitle(
                        line1: s.recoveryTitle1,
                        line2: s.recoveryTitle2,
                        subtitle: s.recoverySubtitle,
                        subtitleMaxWidth: 310,
                      ),
                      const SizedBox(height: 32),
                      // Email field
                      HannaTextField(
                        label: s.emailExact,
                        hintText: s.emailPlaceholder,
                        controller: _emailCtrl,
                        prefixIconName: 'envelope-simple',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        errorText: _emailErr,
                        onSubmitted: (_) => _sendCode(),
                        onChanged: (_) {
                          if (_emailErr != null) setState(() => _emailErr = null);
                        },
                      ),
                      const SizedBox(height: 28),
                      // Primary Send Button
                      HannaButton(
                        label: s.sendVerificationCode,
                        onPressed: _sendCode,
                        isLoading: _sending,
                        variant: HannaButtonVariant.primary,
                      ),
                      const SizedBox(height: 36),
                      // Footer
                      AuthFooter(
                        prompt: s.rememberedQ,
                        actionLabel: s.backToSignIn,
                        onTapAction: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
