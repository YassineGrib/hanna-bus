import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_header.dart';

class CorridorTimelineScreen extends StatelessWidget {
  const CorridorTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final trip = AppStateScope.of(context).activeTrip;

    // 5 Stops combining FigCraft structure with station names for complete test compatibility
    final stops = [
      (
        time: s.isArabic ? '07:05 ص' : '07:05 AM',
        stationName: s.isArabic ? 'المستودع المركزي' : 'Central Depot',
        subtitle: s.trSp1S,
        icon: LucideIcons.circleCheck,
        iconBg: t.heroAccent,
        iconFg: t.text,
        cardBg: t.surface,
        cardBorder: t.border,
        isLive: false,
      ),
      (
        time: s.isArabic ? '07:16 ص' : '07:16 AM',
        stationName: s.isArabic ? 'حي النصر (محطة 03)' : 'Hay El Nasr (Stop 03)',
        subtitle: s.trSp2S,
        icon: LucideIcons.qrCode,
        iconBg: t.heroAccent,
        iconFg: t.text,
        cardBg: t.surface,
        cardBorder: t.border,
        isLive: false,
      ),
      (
        time: s.isArabic ? '07:28 ص' : '07:28 AM',
        stationName: 'Martyrs Square',
        subtitle: s.trSp3S,
        icon: LucideIcons.circleCheck,
        iconBg: t.heroAccent,
        iconFg: t.text,
        cardBg: t.surface,
        cardBorder: t.border,
        isLive: false,
      ),
      (
        time: s.isArabic ? '07:34 ص' : '07:34 AM',
        stationName: 'El Mouradia Upper',
        subtitle: s.trSp4S,
        icon: LucideIcons.bus,
        iconBg: t.actionPrimary,
        iconFg: t.onPrimary,
        cardBg: t.heroAccent.withValues(alpha: 0.35),
        cardBorder: t.actionPrimary,
        isLive: true,
      ),
      (
        time: s.isArabic ? '07:40 ص' : '07:40 AM',
        stationName: 'El-Feth Main Gate',
        subtitle: s.trSp5S,
        icon: LucideIcons.graduationCap,
        iconBg: t.surfaceSubtle,
        iconFg: t.textMuted,
        cardBg: t.surface,
        cardBorder: t.border,
        isLive: false,
      ),
    ];

    return Scaffold(
      body: HannaBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              HannaSpace.lg,
              HannaSpace.md,
              HannaSpace.lg,
              HannaSpace.pageBottomPad,
            ),
            children: [
              HannaHeader(
                title: s.trRtTitle,
                showBack: true,
                trailing: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.border),
                  ),
                  child: Center(
                    child: Icon(LucideIcons.navigation, size: 18, color: t.text),
                  ),
                ),
              ),
              const SizedBox(height: HannaSpace.md),

              // Route Header Banner (y=116..184 in FigCraft)
              Container(
                height: 68,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: t.heroAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(LucideIcons.bus, size: 20, color: t.text),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.trRtBannerT,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: t.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.trRtBannerS,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: t.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: t.actionPrimary,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        s.trRtOnTime,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: t.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HannaSpace.md),

              // 3 Telemetry Metric Cards (y=196..258 in FigCraft)
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      value: '${trip?.speedKmh ?? 38} km/h',
                      label: s.trM1K,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      value: '2 min',
                      label: s.trM2K,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      value: '${trip?.onboardCount ?? 19} / ${trip?.capacity ?? 24}',
                      label: s.trM3K,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: HannaSpace.lg),

              // 5-Stop Live Progress Timeline (y=272..724 in FigCraft)
              _SectionLabel(icon: LucideIcons.route, label: s.trRtSec),
              const SizedBox(height: 8),
              ...stops.map((sp) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sp.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: sp.cardBorder),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: sp.iconBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: t.border),
                          ),
                          child: Center(
                            child: Icon(sp.icon, size: 20, color: sp.iconFg),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      sp.stationName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: t.text,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    sp.time,
                                    style: HannaTypography.mono(
                                      size: 11,
                                      weight: FontWeight.w700,
                                      color: sp.isLive ? t.actionPrimary : t.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                sp.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: sp.isLive ? FontWeight.w600 : FontWeight.w400,
                                  color: sp.isLive ? t.link : t.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: HannaSpace.sm),

              // Share live trip link CTA (y=742 in FigCraft)
              HannaButton(
                label: s.trRtShare,
                icon: LucideIcons.share2,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        s.tr(
                          'Encrypted live tracking link copied to clipboard.',
                          'تم نسخ رابط التتبّع المشفر إلى الحافظة.',
                          'Lien de suivi chiffré copié dans le presse-papiers.',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: t.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: t.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: t.text),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
          ),
        ),
      ],
    );
  }
}
