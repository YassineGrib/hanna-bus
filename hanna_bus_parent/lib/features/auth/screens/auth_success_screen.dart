import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';
import '../widgets/auth_chrome.dart';

class AuthSuccessScreen extends StatelessWidget {
  const AuthSuccessScreen({
    super.key,
    required this.onContinue,
    this.subtitleOverride,
  });

  final VoidCallback onContinue;
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

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
                      // Top Bar with Language Selector
                      const AuthTopBar(showBack: false),
                      const SizedBox(height: 16),
                      // Hero Badge with Halo & Orbit rings
                      Center(
                        child: SizedBox(
                          width: 240,
                          height: 240,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Halo 240x240
                              Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    stops: const [0.0, 0.5, 1.0],
                                    colors: [
                                      t.accent.withValues(alpha: 0x55 / 255.0),
                                      t.accent.withValues(alpha: 0x1A / 255.0),
                                      t.accent.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                              // Orbit 2 (228x228)
                              Container(
                                width: 228,
                                height: 228,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: t.actionPrimary.withValues(alpha: 0.09),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              // Orbit 1 (172x172)
                              Container(
                                width: 172,
                                height: 172,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: t.actionPrimary.withValues(alpha: 0.16),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              // Outer Ring (120x120, radius 60, fill ACCENT 40%)
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: t.accent.withValues(alpha: 0x66 / 255.0),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // Inner Circle (88x88, radius 44, fill PRIMARY)
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: t.actionPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: HannaIcon(
                                    'check-circle',
                                    size: 48,
                                    color: t.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Verified Pill (141w x 30h, radius 15, fill SURF, stroke BORDER)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          decoration: BoxDecoration(
                            color: t.surface,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: t.border, width: 1.0),
                          ),
                          child: Builder(
                            builder: (context) {
                              final loc = Localizations.localeOf(context);
                              return Text(
                                s.okBadge,
                                style: TextStyle(
                                  fontFamily: HannaTypography.familyFor(loc),
                                  fontFamilyFallback: HannaTypography.fallbacksFor(loc),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: t.link,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 2-line Title & Subtitle
                      AuthHeaderTitle(
                        line1: s.okTitle1,
                        line2: s.okTitle2,
                        subtitle: subtitleOverride ?? s.okSubtitle,
                        subtitleMaxWidth: 315,
                      ),
                      const SizedBox(height: 36),
                      // Account Summary Card: 357w x 74h, radius 20, fill SURF, stroke BORDER
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: t.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: t.border, width: 1.0),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: t.accent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: HannaIcon(
                                  'bus',
                                  size: 22,
                                  color: t.text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final loc = Localizations.localeOf(context);
                                  final fontFam = HannaTypography.familyFor(loc);
                                  final fontFallbacks = HannaTypography.fallbacksFor(loc);
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        s.okCardTitle,
                                        style: TextStyle(
                                          fontFamily: fontFam,
                                          fontFamilyFallback: fontFallbacks,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: t.text,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        s.okCardSubtitle,
                                        style: TextStyle(
                                          fontFamily: fontFam,
                                          fontFamilyFallback: fontFallbacks,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: t.textMuted,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 44),
                      // Primary Button
                      HannaButton(
                        label: s.okButton,
                        onPressed: onContinue,
                        variant: HannaButtonVariant.primary,
                        trailIconName: isRtl ? 'caret-left' : 'caret-right',
                      ),
                      const SizedBox(height: 32),
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
