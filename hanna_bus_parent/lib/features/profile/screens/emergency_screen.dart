import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

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
                    Expanded(
                      child: Text(
                        s.sosTitle,
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

              // Live Bus Telemetry Card (357x112, radius 22, in DSURF with DBORD)
              Container(
                constraints: const BoxConstraints(minHeight: 112),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: t.destructiveSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: t.destructiveBorder, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: t.actionDestructive,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        s.sosLiveBadge,
                        style: TextStyle(
                          fontFamily: fontFam,
                          fontFamilyFallback: fontFallbacks,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: t.onDestructive,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.sosBusTitle,
                      style: TextStyle(
                        fontFamily: fontFam,
                        fontFamilyFallback: fontFallbacks,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: t.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      s.sosBusSub,
                      style: TextStyle(
                        fontFamily: fontFam,
                        fontFamilyFallback: fontFallbacks,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: t.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Label: Immediate Voice Lines
              Text(
                s.sosSecDirect,
                style: TextStyle(
                  fontFamily: fontFam,
                  fontFamilyFallback: fontFallbacks,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 12),

              // Row 1: Driver Line
              _SosCallCard(
                iconName: 'phone-call',
                title: s.sosDriverTitle,
                subtitle: s.sosDriverSub,
                buttonLabel: s.urgentCallBtn,
                isDestructive: false,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${s.urgentCallBtn}: Ahmed Benali (+213 550 00 00 04)')),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Row 2: Transport Supervisor Line
              _SosCallCard(
                iconName: 'shield-check',
                title: s.sosSupervisorTitle,
                subtitle: s.sosSupervisorSub,
                buttonLabel: s.urgentCallBtn,
                isDestructive: false,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${s.urgentCallBtn}: Transport Dispatch (+213 21 00 11 22)')),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Row 3: Civil Protection SOS Line (Destructive red)
              _SosCallCard(
                iconName: 'warning-circle',
                title: s.sosCivilTitle,
                subtitle: s.sosCivilSub,
                buttonLabel: s.urgentSosBtn,
                isDestructive: true,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dialing 14 (Civil Protection)...')),
                  );
                },
              ),
              const SizedBox(height: 36),

              // Share live family location CTA
              HannaButton(
                label: s.sosShareLocation,
                leadIconName: 'map-pin',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.sosShareLocation)),
                  );
                },
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

class _SosCallCard extends StatelessWidget {
  const _SosCallCard({
    required this.iconName,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.isDestructive,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
    required this.onTap,
  });

  final String iconName;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final bool isDestructive;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDestructive ? tokens.destructiveSurface : tokens.surface;
    final border = isDestructive ? tokens.destructiveBorder : tokens.border;
    final iconBg = isDestructive ? tokens.actionDestructive : tokens.accent;
    final iconFg = isDestructive ? tokens.onDestructive : tokens.text;
    final btnBg = isDestructive ? tokens.actionDestructive : tokens.actionPrimary;
    final btnFg = isDestructive ? tokens.onDestructive : tokens.onPrimary;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: HannaIcon(iconName, size: 24, color: iconFg),
            ),
          ),
          const SizedBox(width: 12),
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
          Material(
            color: btnBg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(minWidth: 68, minHeight: 36),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                alignment: Alignment.center,
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    fontFamily: fontFam,
                    fontFamilyFallback: fontFallbacks,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: btnFg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
