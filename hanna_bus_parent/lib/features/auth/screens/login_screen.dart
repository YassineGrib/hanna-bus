import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_text_field.dart';
import '../widgets/auth_chrome.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onAuthenticated,
    required this.onOpenRegister,
    required this.onOpenForgot,
    this.onBack,
  });

  final VoidCallback onAuthenticated;
  final VoidCallback onOpenRegister;
  final VoidCallback onOpenForgot;
  final VoidCallback? onBack;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _formError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = AppStrings.of(context);
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text;

    String? eErr;
    String? pErr;
    if (email.isEmpty || !email.contains('@')) {
      eErr = s.tr(
        'Enter a valid email address with @.',
        'أدخل بريداً إلكترونياً صحيحاً يحتوي على @.',
        'Entrez une adresse e-mail valide avec @.',
      );
    }
    if (pass.length < 6) {
      pErr = s.tr(
        'Password must be at least 6 characters.',
        'كلمة المرور يجب أن تكون 6 أحرف على الأقل.',
        'Le mot de passe doit contenir au moins 6 caractères.',
      );
    }
    if (eErr != null || pErr != null) {
      setState(() {
        _emailError = eErr;
        _passwordError = pErr;
      });
      return;
    }

    final state = AppStateScope.of(context);
    final ok = await state.login(email, pass);
    if (!mounted) return;
    if (ok) {
      widget.onAuthenticated();
    } else {
      setState(() {
        _formError = state.lastError ??
            s.tr(
              'Check your email and password and try again.',
              'تحقق من البريد وكلمة المرور وأعد المحاولة.',
              'Vérifiez vos identifiants et réessayez.',
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final locale = Localizations.localeOf(context);
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

    return Scaffold(
      backgroundColor: t.background,
      body: HannaBackground(
        variant: HannaBackgroundVariant.sweep,
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
                      // Top Bar
                      AuthTopBar(
                        onBack: widget.onBack,
                        showBack: widget.onBack != null,
                      ),
                      const SizedBox(height: 36),
                      // 2-line Title & Subtitle
                      AuthHeaderTitle(
                        line1: s.signInTitle1,
                        line2: s.signInTitle2,
                        subtitle: s.signInSubtitleExact,
                      ),
                      const SizedBox(height: 32),
                      // Form Error banner if present
                      if (_formError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: t.destructiveSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: t.destructiveBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, size: 18, color: t.actionDestructive),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formError!,
                                  style: TextStyle(
                                    fontFamily: fontFam,
                                    fontFamilyFallback: fontFallbacks,
                                    fontSize: 13,
                                    color: t.actionDestructive,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Email Field
                      HannaTextField(
                        label: s.emailExact,
                        hintText: s.emailPlaceholder,
                        controller: _emailCtrl,
                        prefixIconName: 'envelope-simple',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        errorText: _emailError,
                        onChanged: (_) {
                          if (_emailError != null) setState(() => _emailError = null);
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      HannaTextField(
                        label: s.passwordExact,
                        hintText: s.passwordPlaceholder,
                        controller: _passwordCtrl,
                        prefixIconName: 'lock-simple',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        errorText: _passwordError,
                        onSubmitted: (_) => _submit(),
                        onChanged: (_) {
                          if (_passwordError != null) setState(() => _passwordError = null);
                        },
                      ),
                      const SizedBox(height: 12),
                      // Forgot password link
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: InkWell(
                          onTap: widget.onOpenForgot,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: Text(
                              s.forgotPasswordExact,
                              style: TextStyle(
                                fontFamily: fontFam,
                                fontFamilyFallback: fontFallbacks,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: t.link,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Primary Sign in Button
                      HannaButton(
                        label: s.signInExact,
                        onPressed: _submit,
                        isLoading: state.isBusy,
                        variant: HannaButtonVariant.primary,
                      ),
                      const SizedBox(height: 32),
                      // Divider: Line - or - Line
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: t.border,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              s.orDivider,
                              style: TextStyle(
                                fontFamily: fontFam,
                                fontFamilyFallback: fontFallbacks,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: t.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: t.border,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Social login buttons (Apple & Google)
                      const SocialRow(),
                      const SizedBox(height: 36),
                      // Footer
                      AuthFooter(
                        prompt: s.newToHannaQ,
                        actionLabel: s.createAccountLink,
                        onTapAction: widget.onOpenRegister,
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
