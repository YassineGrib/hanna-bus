import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';
import '../widgets/auth_chrome.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onCompleted,
    this.onBack,
  });

  final VoidCallback onCompleted;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final locale = Localizations.localeOf(context);
    final isArabic = HannaTypography.isArabicLocale(locale);

    return Scaffold(
      backgroundColor: t.background,
      body: HannaBackground(
        variant: HannaBackgroundVariant.ambient,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight,
                    maxWidth: screenWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        // Top Bar: Back Button, Language Switcher, Skip Link
                        _WelcomeTopBar(
                          isRtl: isRtl,
                          tokens: t,
                          skipText: s.skip,
                          onSkip: onCompleted,
                          onBack: onBack ?? onCompleted,
                        ),
                        const SizedBox(height: 24),
                        // Center Hero Orbital Cards Stack
                        _WelcomeHeroStack(
                          tokens: t,
                          isRtl: isRtl,
                        ),
                        const SizedBox(height: 32),
                        // 3-Pill Pager Indicator
                        _WelcomePagerIndicator(tokens: t),
                        const SizedBox(height: 28),
                        // 2-Line Centered Title
                        Text(
                          s.welcomeTitle1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: isArabic ? HannaTypography.fontArabic : HannaTypography.fontLatin,
                            fontFamilyFallback: isArabic ? HannaTypography.fallbackArabic : HannaTypography.fallbackLatin,
                            fontSize: isArabic ? 32 : 34,
                            fontWeight: FontWeight.w700,
                            color: t.titleSoft,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.welcomeTitle2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: isArabic ? HannaTypography.fontArabic : HannaTypography.fontLatin,
                            fontFamilyFallback: isArabic ? HannaTypography.fallbackArabic : HannaTypography.fallbackLatin,
                            fontSize: isArabic ? 32 : 34,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Subtitle
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 330),
                          child: Text(
                            s.welcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: isArabic ? HannaTypography.fontArabic : HannaTypography.fontLatin,
                              fontFamilyFallback: isArabic ? HannaTypography.fallbackArabic : HannaTypography.fallbackLatin,
                              fontSize: isArabic ? 17 : 16,
                              fontWeight: FontWeight.w400,
                              color: t.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Continue Primary Button (58px tall, 18px radius, trailing caret icon)
                        HannaButton(
                          label: s.continueAction,
                          onPressed: onCompleted,
                          variant: HannaButtonVariant.primary,
                          trailIconName: isRtl ? 'caret-left' : 'caret-right',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
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

class _WelcomeTopBar extends StatelessWidget {
  const _WelcomeTopBar({
    required this.isRtl,
    required this.tokens,
    required this.skipText,
    required this.onSkip,
    required this.onBack,
  });

  final bool isRtl;
  final HannaTokens tokens;
  final String skipText;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back Button: 42x42 circular button in border tint with Phosphor arrow
          Material(
            color: tokens.border,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onBack,
              child: SizedBox(
                width: 42,
                height: 42,
                child: Center(
                  child: HannaIcon(
                    isRtl ? 'arrow-right' : 'arrow-left',
                    size: 20,
                    color: tokens.text,
                  ),
                ),
              ),
            ),
          ),
          // Language selector
          const AuthLanguagePill(),
          // Skip Link
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              skipText,
              style: TextStyle(
                fontFamily: isRtl ? HannaTypography.fontArabic : HannaTypography.fontLatin,
                fontFamilyFallback: isRtl ? HannaTypography.fallbackArabic : HannaTypography.fallbackLatin,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: tokens.link,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeroStack extends StatelessWidget {
  const _WelcomeHeroStack({
    required this.tokens,
    required this.isRtl,
  });

  final HannaTokens tokens;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    // Stack dimensions matching FigCraft Hero card cluster
    const clusterW = 340.0;
    const clusterH = 290.0;

    final dropShadow = BoxShadow(
      color: tokens.text.withValues(alpha: 0.15),
      offset: const Offset(0, 10),
      blurRadius: 30,
    );

    return SizedBox(
      width: clusterW,
      height: clusterH,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 1. Orbital Glow Halo (320x320)
          Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                stops: const [0.0, 0.5, 1.0],
                colors: [
                  tokens.accent.withValues(alpha: 0x55 / 255.0),
                  tokens.accent.withValues(alpha: 0x1A / 255.0),
                  tokens.accent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // 2. Orbital Ring 1 (280x280)
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: tokens.actionPrimary.withValues(alpha: 0.14),
                width: 1.2,
              ),
            ),
          ),
          // 3. Orbital Ring 2 (340x340)
          Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: tokens.actionPrimary.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
          ),
          // 4. Back Right Card: 132x205, rot +8° (LTR) / -8° (RTL), fill ACCENT (opacity 0.55)
          Positioned(
            left: isRtl ? 10 : null,
            right: isRtl ? null : 10,
            top: 20,
            child: Transform.rotate(
              angle: (isRtl ? -8.0 : 8.0) * (math.pi / 180.0),
              child: Opacity(
                opacity: 0.55,
                child: Container(
                  width: 132,
                  height: 205,
                  decoration: BoxDecoration(
                    color: tokens.accent,
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: tokens.surface, width: 4),
                    boxShadow: [dropShadow],
                  ),
                ),
              ),
            ),
          ),
          // 5. Back Left Card: 168x168, rot -8° (LTR) / +8° (RTL), fill BORDER (opacity 0.90)
          Positioned(
            left: isRtl ? null : 20,
            right: isRtl ? 20 : null,
            bottom: 10,
            child: Transform.rotate(
              angle: (isRtl ? 8.0 : -8.0) * (math.pi / 180.0),
              child: Opacity(
                opacity: 0.90,
                child: Container(
                  width: 168,
                  height: 168,
                  decoration: BoxDecoration(
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: tokens.surface, width: 4),
                    boxShadow: [dropShadow],
                  ),
                ),
              ),
            ),
          ),
          // 6. Foreground Logo Card: 196x244, rot 0°, fill SURFACE (#FFFFFF)
          Container(
            width: 196,
            height: 244,
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: tokens.surface, width: 4),
              boxShadow: [dropShadow],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Image.asset(
                'assets/images/hanna-bus-logo.png',
                width: 168,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePagerIndicator extends StatelessWidget {
  const _WelcomePagerIndicator({required this.tokens});

  final HannaTokens tokens;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dot 0 (Inactive)
          Container(
            width: 4,
            height: 12,
            decoration: BoxDecoration(
              color: tokens.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          // Dot 1 (Active Mustard)
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: tokens.actionPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          // Dot 2 (Inactive)
          Container(
            width: 4,
            height: 12,
            decoration: BoxDecoration(
              color: tokens.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
