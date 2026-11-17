import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';
import '../../../core/widgets/hanna_text_field.dart';
import '../widgets/auth_chrome.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
    required this.onResetComplete,
  });

  final String email;
  final String resetToken;
  final VoidCallback onResetComplete;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _req1 => _passCtrl.text.length >= 8;
  bool get _req2 => RegExp(r'[0-9]').hasMatch(_passCtrl.text);
  bool get _req3 => RegExp(r'[A-Z]').hasMatch(_passCtrl.text) && RegExp(r'[^a-zA-Z0-9]').hasMatch(_passCtrl.text);

  Future<void> _submit() async {
    final s = AppStrings.of(context);
    final p1 = _passCtrl.text;
    final p2 = _confirmCtrl.text;

    if (p1.length < 8) {
      setState(() {
        _error = s.tr(
          'Use at least 8 characters.',
          'استخدم 8 أحرف على الأقل.',
          'Utilisez au moins 8 caractères.',
        );
      });
      return;
    }
    if (p1 != p2) {
      setState(() {
        _error = s.tr(
          'Passwords do not match.',
          'كلمتا المرور غير متطابقتين.',
          'Les mots de passe ne correspondent pas.',
        );
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await AppStateScope.of(context).completePasswordReset(
      email: widget.email,
      resetToken: widget.resetToken,
      password: p1,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      widget.onResetComplete();
    } else {
      setState(() {
        _error = s.tr(
          'Could not save password. Check connection and try again.',
          'تعذر حفظ كلمة المرور. تحقق من الاتصال وأعد المحاولة.',
          'Échec de mise à jour. Réessayez.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);

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
                      // Top Bar with Back
                      AuthTopBar(onBack: () => Navigator.pop(context)),
                      const SizedBox(height: 36),
                      // 2-line Title & Subtitle
                      AuthHeaderTitle(
                        line1: s.resetTitle1,
                        line2: s.resetTitle2,
                        subtitle: s.resetSubtitle,
                      ),
                      const SizedBox(height: 32),
                      // New password field
                      HannaTextField(
                        label: s.newPasswordLabel,
                        hintText: '••••••••••••',
                        controller: _passCtrl,
                        prefixIconName: 'lock-simple',
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      // Confirm password field
                      HannaTextField(
                        label: s.confirmPasswordLabelExact,
                        hintText: '••••••••••••',
                        controller: _confirmCtrl,
                        prefixIconName: 'lock-simple',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      // Requirements Card: 357w x 120h, fill SURF, stroke BORDER, radius 18
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: t.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: t.border, width: 1.0),
                        ),
                        child: Builder(
                          builder: (context) {
                            final loc = Localizations.localeOf(context);
                            final fontFam = HannaTypography.familyFor(loc);
                            final fontFallbacks = HannaTypography.fallbacksFor(loc);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.reqTitle,
                                  style: TextStyle(
                                    fontFamily: fontFam,
                                    fontFamilyFallback: fontFallbacks,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: t.text,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _ReqItem(label: s.req1, ok: _req1, tokens: t),
                                const SizedBox(height: 8),
                                _ReqItem(label: s.req2, ok: _req2, tokens: t),
                                const SizedBox(height: 8),
                                _ReqItem(label: s.req3, ok: _req3, tokens: t),
                              ],
                            );
                          },
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Builder(
                            builder: (context) {
                              final loc = Localizations.localeOf(context);
                              return Text(
                                _error!,
                                style: TextStyle(
                                  fontFamily: HannaTypography.familyFor(loc),
                                  fontFamilyFallback: HannaTypography.fallbacksFor(loc),
                                  fontSize: 12,
                                  color: t.actionDestructive,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      // Primary Button
                      HannaButton(
                        label: s.resetPasswordButton,
                        onPressed: _submit,
                        isLoading: _saving,
                        variant: HannaButtonVariant.primary,
                      ),
                      const SizedBox(height: 36),
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

class _ReqItem extends StatelessWidget {
  const _ReqItem({
    required this.label,
    required this.ok,
    required this.tokens,
  });

  final String label;
  final bool ok;
  final HannaTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: ok ? tokens.actionPrimary : tokens.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: HannaIcon(
              'check',
              size: 11,
              color: tokens.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Builder(
          builder: (context) {
            final loc = Localizations.localeOf(context);
            return Text(
              label,
              style: TextStyle(
                fontFamily: HannaTypography.familyFor(loc),
                fontFamilyFallback: HannaTypography.fallbacksFor(loc),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ok ? tokens.text : tokens.textMuted,
              ),
            );
          },
        ),
      ],
    );
  }
}
