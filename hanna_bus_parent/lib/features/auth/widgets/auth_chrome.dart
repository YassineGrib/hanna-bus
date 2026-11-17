import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_icon.dart';

class AuthTopBar extends StatelessWidget {
  const AuthTopBar({
    super.key,
    this.onBack,
    this.trailing,
    this.showBack = true,
  });

  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBack)
            Material(
              color: t.border,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onBack ?? () => Navigator.maybePop(context),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Center(
                    child: HannaIcon(
                      isRtl ? 'arrow-right' : 'arrow-left',
                      size: 20,
                      color: t.text,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 42),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuthLanguagePill(),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class AuthHeaderTitle extends StatelessWidget {
  const AuthHeaderTitle({
    super.key,
    required this.line1,
    required this.line2,
    required this.subtitle,
    this.subtitleMaxWidth = 315,
  });

  final String line1;
  final String line2;
  final String subtitle;
  final double subtitleMaxWidth;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final locale = Localizations.localeOf(context);
    final isArabic = HannaTypography.isArabicLocale(locale);
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          line1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: fontFam,
            fontFamilyFallback: fontFallbacks,
            fontSize: isArabic ? 32 : 34,
            fontWeight: FontWeight.w700,
            color: t.titleSoft,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          line2,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: fontFam,
            fontFamilyFallback: fontFallbacks,
            fontSize: isArabic ? 32 : 34,
            fontWeight: FontWeight.w700,
            color: t.text,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: subtitleMaxWidth),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontFam,
              fontFamilyFallback: fontFallbacks,
              fontSize: isArabic ? 17 : 16,
              fontWeight: FontWeight.w400,
              color: t.textMuted,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTapAction,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onTapAction;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final locale = Localizations.localeOf(context);
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prompt,
          style: TextStyle(
            fontFamily: fontFam,
            fontFamilyFallback: fontFallbacks,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: t.textMuted,
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: onTapAction,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              actionLabel,
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
      ],
    );
  }
}

class SocialRow extends StatelessWidget {
  const SocialRow({super.key, this.onApple, this.onGoogle});

  final VoidCallback? onApple;
  final VoidCallback? onGoogle;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            iconName: 'apple-logo',
            onTap: onApple,
            tokens: t,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _SocialButton(
            label: 'Google',
            iconName: 'google-logo',
            onTap: onGoogle,
            tokens: t,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.iconName,
    required this.onTap,
    required this.tokens,
  });

  final String label;
  final String iconName;
  final VoidCallback? onTap;
  final HannaTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.border, width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HannaIcon(iconName, size: 20, color: tokens.text),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: tokens.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthLanguagePill extends StatelessWidget {
  const AuthLanguagePill({super.key});

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final s = AppStrings.of(context);

    final codeLabel = state.locale.languageCode.toUpperCase();

    return HannaPressable(
      key: const ValueKey('lang-switch-pill'),
      borderRadius: BorderRadius.circular(HannaRadius.pill),
      semanticLabel: s.tr('Language selector', 'اختيار اللغة', 'Choix de langue'),
      onTap: () => _showLanguageSheet(context, state, s),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(HannaRadius.pill),
          border: Border.all(color: t.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HannaIcon('globe', size: 16, color: t.link),
            const SizedBox(width: 6),
            Text(
              codeLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.text,
              ),
            ),
            const SizedBox(width: 4),
            HannaIcon('caret-down', size: 14, color: t.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
    AppStateController state,
    AppStrings s,
  ) async {
    final t = HannaTokens.of(context);
    final options = [
      (locale: const Locale('en'), label: 'English', tag: 'LTR'),
      (locale: const Locale('ar'), label: 'العربية', tag: 'RTL'),
      (locale: const Locale('fr'), label: 'Français', tag: 'LTR'),
    ];

    final picked = await showModalBottomSheet<Locale>(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HannaRadius.xl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(HannaSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr('Choose app language', 'اختر لغة التطبيق', 'Choisir la langue'),
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: HannaSpace.sm),
                ...options.map((item) {
                  final selected = state.locale.languageCode == item.locale.languageCode;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HannaPressable(
                      onTap: () => Navigator.of(ctx).pop(item.locale),
                      borderRadius: BorderRadius.circular(HannaRadius.md),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: selected ? t.surfaceSubtle : t.background,
                          borderRadius: BorderRadius.circular(HannaRadius.md),
                          border: Border.all(
                            color: selected ? t.actionPrimary : t.border,
                            width: selected ? 1.6 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.label,
                                style: Theme.of(ctx).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              item.tag,
                              style: Theme.of(ctx).textTheme.labelSmall,
                            ),
                            if (selected) ...[
                              const SizedBox(width: 8),
                              Icon(LucideIcons.check, size: 18, color: t.link),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      await state.setLocale(picked);
    }
  }
}

class HannaCrestLogo extends StatelessWidget {
  const HannaCrestLogo({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.10),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: t.border, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.20),
        child: Image.asset(
          'assets/images/hanna-bus-logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
