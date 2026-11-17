import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_text_field.dart';
import '../widgets/auth_chrome.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.onRegistered,
    required this.onOpenLogin,
  });

  final VoidCallback onRegistered;
  final VoidCallback onOpenLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _nameErr;
  String? _emailErr;
  String? _passErr;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = AppStrings.of(context);
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text;

    String? nErr;
    String? eErr;
    String? pErr;
    if (name.length < 2) {
      nErr = s.tr('Enter your full name.', 'أدخل اسمك الكامل.', 'Entrez votre nom complet.');
    }
    if (!email.contains('@')) {
      eErr = s.tr('Enter a valid email.', 'أدخل بريداً صحيحاً.', 'Entrez un e-mail valide.');
    }
    if (pass.length < 8) {
      pErr = s.tr(
        'Use at least 8 characters.',
        'استخدم 8 أحرف على الأقل.',
        'Utilisez au moins 8 caractères.',
      );
    }

    if (nErr != null || eErr != null || pErr != null) {
      setState(() {
        _nameErr = nErr;
        _emailErr = eErr;
        _passErr = pErr;
      });
      return;
    }

    final ok = await AppStateScope.of(context).register(
      name: name,
      email: email,
      password: pass,
      phone: '',
    );
    if (!mounted) return;
    if (ok) {
      widget.onRegistered();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: t.background,
      body: HannaBackground(
        variant: HannaBackgroundVariant.orbital,
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
                      AuthTopBar(onBack: widget.onOpenLogin),
                      const SizedBox(height: 36),
                      // 2-line Title & Subtitle
                      AuthHeaderTitle(
                        line1: s.signUpTitle1,
                        line2: s.signUpTitle2,
                        subtitle: s.signUpSubtitle,
                      ),
                      const SizedBox(height: 32),
                      // Parent name field
                      HannaTextField(
                        label: s.parentName,
                        hintText: s.parentNamePlaceholder,
                        controller: _nameCtrl,
                        prefixIconName: 'user',
                        textInputAction: TextInputAction.next,
                        errorText: _nameErr,
                        onChanged: (_) {
                          if (_nameErr != null) setState(() => _nameErr = null);
                        },
                      ),
                      const SizedBox(height: 20),
                      // Email field
                      HannaTextField(
                        label: s.emailExact,
                        hintText: s.emailPlaceholder,
                        controller: _emailCtrl,
                        prefixIconName: 'envelope-simple',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        errorText: _emailErr,
                        onChanged: (_) {
                          if (_emailErr != null) setState(() => _emailErr = null);
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password field
                      HannaTextField(
                        label: s.passwordExact,
                        hintText: s.passwordPlaceholder8,
                        controller: _passwordCtrl,
                        prefixIconName: 'lock-simple',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        errorText: _passErr,
                        onSubmitted: (_) => _submit(),
                        onChanged: (_) {
                          if (_passErr != null) setState(() => _passErr = null);
                        },
                      ),
                      const SizedBox(height: 28),
                      // Primary Button
                      HannaButton(
                        label: s.createAccountLink,
                        onPressed: _submit,
                        isLoading: state.isBusy,
                        variant: HannaButtonVariant.primary,
                      ),
                      const SizedBox(height: 20),
                      // Terms notice
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Builder(
                            builder: (context) {
                              final locale = Localizations.localeOf(context);
                              return Text(
                                s.termsNotice,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: HannaTypography.familyFor(locale),
                                  fontFamilyFallback: HannaTypography.fallbacksFor(locale),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: t.textMuted,
                                  height: 1.4,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Footer
                      AuthFooter(
                        prompt: s.haveAccountQ,
                        actionLabel: s.signInExact,
                        onTapAction: widget.onOpenLogin,
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
