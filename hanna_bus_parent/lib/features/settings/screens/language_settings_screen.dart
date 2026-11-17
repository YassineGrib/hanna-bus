import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late Locale _selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale = AppStateScope.of(context).locale;
  }

  Future<void> _save() async {
    final state = AppStateScope.of(context);
    await state.setLocale(_selectedLocale);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.of(context).lgSaveBtn)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final locale = Localizations.localeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

    final currentCode = _selectedLocale.languageCode;

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
                    Text(
                      s.lgTitle,
                      style: TextStyle(
                        fontFamily: fontFam,
                        fontFamilyFallback: fontFallbacks,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: t.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Subtitle
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 325),
                  child: Text(
                    s.lgSub,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontFam,
                      fontFamilyFallback: fontFallbacks,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: t.textMuted,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Language Cards
              _LangCard(
                code: 'AR',
                title: s.lgAr,
                subtitle: s.lgArSub,
                isSelected: currentCode == 'ar',
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () => setState(() => _selectedLocale = const Locale('ar')),
              ),
              const SizedBox(height: 14),
              _LangCard(
                code: 'EN',
                title: s.lgEn,
                subtitle: s.lgEnSub,
                isSelected: currentCode == 'en',
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () => setState(() => _selectedLocale = const Locale('en')),
              ),
              const SizedBox(height: 14),
              _LangCard(
                code: 'FR',
                title: s.lgFr,
                subtitle: s.lgFrSub,
                isSelected: currentCode == 'fr',
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () => setState(() => _selectedLocale = const Locale('fr')),
              ),
              const SizedBox(height: 36),

              // Save Language Button
              HannaButton(
                label: s.lgSaveBtn,
                leadIconName: 'globe',
                onPressed: _save,
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

class _LangCard extends StatelessWidget {
  const _LangCard({
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
    return Material(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? tokens.actionPrimary : tokens.border,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected ? tokens.accent : tokens.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tokens.border, width: 1.0),
                ),
                child: Center(
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
              Container(
                width: 24,
                height: 24,
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
                        child: HannaIcon('check', size: 14, color: tokens.onPrimary),
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
