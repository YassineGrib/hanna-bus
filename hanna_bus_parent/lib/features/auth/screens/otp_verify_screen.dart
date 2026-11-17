import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';
import '../widgets/auth_chrome.dart';
import 'new_password_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.email,
    required this.demoOtp,
    required this.onResetComplete,
  });

  final String email;
  final String demoOtp;
  final VoidCallback onResetComplete;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  late final List<TextEditingController> _digitCtrls;
  late final List<FocusNode> _focusNodes;
  int _activeIndex = 0;
  bool _verifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final padded = widget.demoOtp.padRight(6, '0').substring(0, 6);
    _digitCtrls = List.generate(
      6,
      (i) => TextEditingController(text: padded[i]),
    );
    _focusNodes = List.generate(6, (i) => FocusNode()..addListener(() {
      if (mounted && _focusNodes[i].hasFocus) {
        setState(() => _activeIndex = i);
      }
    }));
  }

  @override
  void dispose() {
    for (final c in _digitCtrls) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    final s = AppStrings.of(context);
    final code = _digitCtrls.map((c) => c.text.trim()).join();
    if (code.length < 6) {
      setState(() {
        _error = s.tr(
          'Enter all 6 digits.',
          'أدخل جميع الأرقام الستة.',
          'Entrez les 6 chiffres.',
        );
      });
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });
    final token = await AppStateScope.of(context).verifyPasswordOtp(widget.email, code);
    if (!mounted) return;
    setState(() => _verifying = false);

    if (token == null || token.isEmpty) {
      setState(() {
        _error = s.tr(
          'That verification code did not match. Try 482910.',
          'رمز التحقق غير مطابق. جرب 482910.',
          'Code invalide. Essayez 482910.',
        );
      });
      return;
    }

    Navigator.of(context).push(
      HannaMotion.route(
        NewPasswordScreen(
          email: widget.email,
          resetToken: token,
          onResetComplete: widget.onResetComplete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);

    final subCopy = s.tr(
      'We sent a 6-digit code to ${widget.email}',
      'أرسلنا رمزًا من 6 أرقام إلى ${widget.email}',
      'Nous avons envoyé un code à 6 chiffres à ${widget.email}',
    );

    return Scaffold(
      backgroundColor: t.background,
      body: HannaBackground(
        variant: HannaBackgroundVariant.ambient,
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
                              'shield-check',
                              size: 52,
                              color: t.text,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 2-line Title & Subtitle
                      AuthHeaderTitle(
                        line1: s.otpTitle1,
                        line2: s.otpTitle2,
                        subtitle: subCopy,
                        subtitleMaxWidth: 315,
                      ),
                      const SizedBox(height: 32),
                      // 6 OTP Digit Boxes: each 52w x 60h, gap ~9, corner radius 16
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            final isActive = _focusNodes[index].hasFocus || _activeIndex == index;
                            return Container(
                              width: 52,
                              height: 60,
                              decoration: BoxDecoration(
                                color: t.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isActive ? t.actionPrimary : t.border,
                                  width: isActive ? 1.6 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: TextField(
                                  controller: _digitCtrls[index],
                                  focusNode: _focusNodes[index],
                                  maxLength: 1,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: t.text,
                                  ),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                  },
                                ),
                              ),
                            );
                          }),
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
                      const SizedBox(height: 24),
                      // Timer Pill: 169w x 30h, radius 15, fill SURF, stroke BORDER
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: t.surface,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: t.border, width: 1.0),
                          ),
                          child: Builder(
                            builder: (context) {
                              final loc = Localizations.localeOf(context);
                              return Text(
                                s.otpTimer,
                                style: TextStyle(
                                  fontFamily: HannaTypography.familyFor(loc),
                                  fontFamilyFallback: HannaTypography.fallbacksFor(loc),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: t.textMuted,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Primary Verify Button
                      HannaButton(
                        label: s.otpButton,
                        onPressed: _verify,
                        isLoading: _verifying,
                        variant: HannaButtonVariant.primary,
                      ),
                      const SizedBox(height: 36),
                      // Footer
                      AuthFooter(
                        prompt: s.otpWrongEmail,
                        actionLabel: s.otpChangeAddress,
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
