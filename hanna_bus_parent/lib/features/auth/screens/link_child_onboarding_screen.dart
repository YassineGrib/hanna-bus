import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_badge.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_card.dart';
import '../../../core/widgets/hanna_header.dart';
import '../../../core/widgets/hanna_text_field.dart';

class LinkChildOnboardingScreen extends StatefulWidget {
  const LinkChildOnboardingScreen({super.key, required this.onContinue});
  final VoidCallback onContinue;

  @override
  State<LinkChildOnboardingScreen> createState() => _LinkChildOnboardingScreenState();
}

class _LinkChildOnboardingScreenState extends State<LinkChildOnboardingScreen> {
  final _codeCtrl = TextEditingController();
  String? _statusMsg;
  String? _error;
  bool _linking = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _linkCode() async {
    final s = AppStrings.of(context);
    final code = _codeCtrl.text.trim();
    if (code.length < 4) {
      setState(() {
        _error = s.tr(
          'Enter your school student code (e.g. HB-2026-9911).',
          'أدخل رمز الطالب المرسل من المدرسة (مثال HB-2026-9911).',
          'Entrez le code eleve fourni par l ecole.',
        );
      });
      return;
    }
    setState(() {
      _linking = true;
      _error = null;
    });
    final child = await AppStateScope.of(context).linkChildByCode(studentCode: code);
    if (!mounted) return;
    setState(() {
      _linking = false;
      _statusMsg = child != null
          ? s.tr(
              'Linked ${child.fullName} (Bus ${child.busNumber})',
              'تم ربط ${child.fullName} (حافلة ${child.busNumber})',
              '${child.fullName} lie (Bus ${child.busNumber})',
            )
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);

    return Scaffold(
      body: HannaBackground(
        variant: HannaBackgroundVariant.auth,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(HannaSpace.lg),
            child: HannaMotionEntrance(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HannaHeader(title: s.linkChildOnboardingTitle),
                  const SizedBox(height: HannaSpace.lg),
                  HannaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          s.linkChildOnboardingBody,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: t.textMuted,
                              ),
                        ),
                        const SizedBox(height: HannaSpace.md),
                        HannaTextField(
                          label: s.studentCodeLabel,
                          controller: _codeCtrl,
                          prefixIcon: LucideIcons.qrCode,
                          hintText: 'HB-2026-9911',
                          textDirection: TextDirection.ltr,
                          errorText: _error,
                        ),
                        if (_statusMsg != null) ...[
                          const SizedBox(height: HannaSpace.sm),
                          HannaBadge(
                            label: _statusMsg!,
                            icon: LucideIcons.circleCheck,
                            tone: HannaBadgeTone.success,
                          ),
                        ],
                        const SizedBox(height: HannaSpace.md),
                        HannaButton(
                          label: s.linkChildAction,
                          variant: HannaButtonVariant.secondary,
                          icon: LucideIcons.plus,
                          isLoading: _linking,
                          onPressed: _linkCode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: HannaSpace.lg),
                  HannaButton(
                    label: s.continueToHome,
                    icon: LucideIcons.arrowRight,
                    onPressed: widget.onContinue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
