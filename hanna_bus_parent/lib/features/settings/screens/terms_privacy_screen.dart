import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';

class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({super.key});

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  int _selectedTab = 0; // 0: Terms, 1: Privacy

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final locale = Localizations.localeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

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
                      s.tmTitle,
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
              const SizedBox(height: 18),

              // Segmented Tabs Container (357x44 in design)
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: t.border, width: 1.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedTab = 0),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? t.actionPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            s.tmTabTerms,
                            style: TextStyle(
                              fontFamily: fontFam,
                              fontFamilyFallback: fontFallbacks,
                              fontSize: 13,
                              fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w600,
                              color: _selectedTab == 0 ? t.onPrimary : t.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedTab = 1),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? t.actionPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            s.tmTabPrivacy,
                            style: TextStyle(
                              fontFamily: fontFam,
                              fontFamilyFallback: fontFallbacks,
                              fontSize: 13,
                              fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w600,
                              color: _selectedTab == 1 ? t.onPrimary : t.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Effective Date
              Center(
                child: Text(
                  s.tmUpdatedDate,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: fontFam,
                    fontFamilyFallback: fontFallbacks,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: t.link,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Clauses
              _ClauseCard(
                title: s.tmC1Title,
                body: s.tmC1Body,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 14),
              _ClauseCard(
                title: s.tmC2Title,
                body: s.tmC2Body,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 14),
              _ClauseCard(
                title: s.tmC3Title,
                body: s.tmC3Body,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 28),

              // Download PDF Copy button
              HannaButton(
                label: s.tmDownloadBtn,
                leadIconName: 'download-simple',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.tmDownloadBtn)),
                  );
                },
                variant: HannaButtonVariant.secondary,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClauseCard extends StatelessWidget {
  const _ClauseCard({
    required this.title,
    required this.body,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
  });

  final String title;
  final String body;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: fontFam,
              fontFamilyFallback: fontFallbacks,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: tokens.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontFamily: fontFam,
              fontFamilyFallback: fontFallbacks,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: tokens.textMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
