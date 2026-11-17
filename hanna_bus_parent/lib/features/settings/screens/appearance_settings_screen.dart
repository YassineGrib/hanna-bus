import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final locale = Localizations.localeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

    final isLight = state.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: t.background,
      body: HannaBackground(
        variant: HannaBackgroundVariant.sweep,
        child: SafeArea(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              // Top Bar Header
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Material(
                      color: t.border,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
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
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        s.thTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          fontFamily: fontFam,
                          fontFamilyFallback: fontFallbacks,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section: Display Mode
              Text(
                s.thSecMode,
                style: TextStyle(
                  fontFamily: fontFam,
                  fontFamilyFallback: fontFallbacks,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 12),

              // Side-by-Side Display Mode Cards
              Row(
                children: [
                  // Light Mode Card
                  Expanded(
                    child: _ModeCard(
                      title: s.thMLight,
                      subtitle: s.thMLightSub,
                      iconName: 'sun',
                      isSelected: isLight,
                      previewBg: const Color(0xFFFFFDF5),
                      previewFg: const Color(0xFF2B2B2B),
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                      onTap: () => state.setBrightness(Brightness.light),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Dark Mode Card
                  Expanded(
                    child: _ModeCard(
                      title: s.thMDark,
                      subtitle: s.thMDarkSub,
                      iconName: 'moon',
                      isSelected: !isLight,
                      previewBg: const Color(0xFF1B2024),
                      previewFg: const Color(0xFFFAF7EE),
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                      onTap: () => state.setBrightness(Brightness.dark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Section: Brand Color Palette
              Text(
                s.thSecPal,
                style: TextStyle(
                  fontFamily: fontFam,
                  fontFamilyFallback: fontFallbacks,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 12),

              // Palette 1: Mustard
              _PaletteCard(
                title: state.palette == HannaPalette.mustard ? s.thP1 : 'Mustard Gold',
                subtitle: s.thP1Sub,
                colors: const [Color(0xFF2B2B2B), Color(0xFFD4A017), Color(0xFFF0C94C), Color(0xFFF7E7B5)],
                isSelected: state.palette == HannaPalette.mustard,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () => state.setPalette(HannaPalette.mustard),
              ),
              const SizedBox(height: 12),

              // Palette 2: Teal / Slate Gray
              _PaletteCard(
                title: state.palette == HannaPalette.tealGray ? '${s.thP2} (Active)' : s.thP2,
                subtitle: s.thP2Sub,
                colors: const [Color(0xFF263238), Color(0xFF455A64), Color(0xFF80CBC4), Color(0xFFCFD8DC)],
                isSelected: state.palette == HannaPalette.tealGray,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () => state.setPalette(HannaPalette.tealGray),
              ),
              const SizedBox(height: 12),

              // Palette 3: Ocean Blue
              _PaletteCard(
                title: state.palette == HannaPalette.ocean ? '${s.thP3} (Active)' : 'Ocean Blue',
                subtitle: s.thP3Sub,
                colors: const [Color(0xFF0D1B2A), Color(0xFF1B4965), Color(0xFF29ADB2), Color(0xFFA8DADC)],
                isSelected: state.palette == HannaPalette.ocean,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () => state.setPalette(HannaPalette.ocean),
              ),
              const SizedBox(height: 28),

              // Section: Language Selection
              Text(
                s.rowLanguage,
                style: TextStyle(
                  fontFamily: fontFam,
                  fontFamilyFallback: fontFallbacks,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.border, width: 1.0),
                ),
                child: Column(
                  children: [
                    _LangInlineRow(
                      code: 'AR',
                      title: 'العربية',
                      subtitle: 'واجهة عربية (RTL) · خط IBM Plex',
                      isSelected: state.locale.languageCode == 'ar',
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                      onTap: () => state.setLocale(const Locale('ar')),
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),
                    _LangInlineRow(
                      code: 'EN',
                      title: 'English',
                      subtitle: 'LTR interface · Inter font',
                      isSelected: state.locale.languageCode == 'en',
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                      onTap: () => state.setLocale(const Locale('en')),
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),
                    _LangInlineRow(
                      code: 'FR',
                      title: 'Français',
                      subtitle: 'Interface LTR · Police Inter',
                      isSelected: state.locale.languageCode == 'fr',
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                      onTap: () => state.setLocale(const Locale('fr')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Done Button
              HannaButton(
                label: s.thApplyBtn,
                leadIconName: 'check',
                onPressed: () => Navigator.of(context).pop(),
                variant: HannaButtonVariant.primary,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.isSelected,
    required this.previewBg,
    required this.previewFg,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String iconName;
  final bool isSelected;
  final Color previewBg;
  final Color previewFg;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 156,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? tokens.actionPrimary : tokens.border,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: previewBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tokens.border, width: 1.0),
                ),
                child: Row(
                  children: [
                    HannaIcon(iconName, size: 22, color: previewFg),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 7,
                            width: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4A017),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 5,
                            width: 40,
                            decoration: BoxDecoration(
                              color: tokens.textMuted.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: fontFam,
                  fontFamilyFallback: fontFallbacks,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: tokens.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: fontFam,
                  fontFamilyFallback: fontFallbacks,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: tokens.textMuted,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  const _PaletteCard({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.isSelected,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<Color> colors;
  final bool isSelected;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? tokens.actionPrimary : tokens.border,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: fontFam,
                        fontFamilyFallback: fontFallbacks,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: tokens.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: fontFam,
                        fontFamilyFallback: fontFallbacks,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: colors.map((col) {
                  return Container(
                    width: 18,
                    height: 26,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: col,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: tokens.border, width: 1.0),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? tokens.actionPrimary : tokens.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? tokens.actionPrimary : tokens.border,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: HannaIcon('check', size: 12, color: tokens.onPrimary),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangInlineRow extends StatelessWidget {
  const _LangInlineRow({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
    required this.onTap,
  });

  final String code;
  final String title;
  final String subtitle;
  final bool isSelected;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? tokens.accent : tokens.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: tokens.border, width: 1.0),
              ),
              child: Center(
                child: Text(
                  code,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: fontFam,
                      fontFamilyFallback: fontFallbacks,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: tokens.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: fontFam,
                      fontFamilyFallback: fontFallbacks,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? tokens.actionPrimary : tokens.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? tokens.actionPrimary : tokens.border,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: HannaIcon('check', size: 12, color: tokens.onPrimary),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
