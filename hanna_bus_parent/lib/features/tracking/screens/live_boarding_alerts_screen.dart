import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_header.dart';
import '../../settings/screens/notification_prefs_screen.dart';

class LiveBoardingAlertsScreen extends StatelessWidget {
  const LiveBoardingAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);

    final events = [
      (
        title: s.trEv1T,
        subtitle: s.trEv1S,
        icon: LucideIcons.navigation,
        iconBg: t.actionPrimary,
        iconFg: t.onPrimary,
        cardBg: t.heroAccent.withValues(alpha: 0.35),
        cardBorder: t.actionPrimary,
      ),
      (
        title: s.trEv2T,
        subtitle: s.trEv2S,
        icon: LucideIcons.qrCode,
        iconBg: t.heroAccent,
        iconFg: t.text,
        cardBg: t.surface,
        cardBorder: t.border,
      ),
      (
        title: s.trEv3T,
        subtitle: s.trEv3S,
        icon: LucideIcons.bell,
        iconBg: t.heroAccent,
        iconFg: t.text,
        cardBg: t.surface,
        cardBorder: t.border,
      ),
      (
        title: s.trEv4T,
        subtitle: s.trEv4S,
        icon: LucideIcons.bus,
        iconBg: t.surfaceSubtle,
        iconFg: t.text,
        cardBg: t.surface,
        cardBorder: t.border,
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
                title: s.trAlTitle,
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
                    child: Icon(LucideIcons.bell, size: 18, color: t.text),
                  ),
                ),
              ),
              const SizedBox(height: HannaSpace.md),

              // Active Geofence Banner (y=118..198 in FigCraft)
              Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.actionPrimary),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: t.actionPrimary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(LucideIcons.radio, size: 22, color: t.onPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.trAlGeoT,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: t.text,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            s.isArabic
                                ? 'نصف قطر ${state.alertSettings.globalRadiusMeters} متر · إشعار فوري عند الوصول'
                                : '${state.alertSettings.globalRadiusMeters}m safety radius · Instant arrival check-in',
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
                  ],
                ),
              ),
              const SizedBox(height: HannaSpace.lg),

              // Today's Live Telemetry Feed (y=214..724 in FigCraft)
              _SectionLabel(icon: LucideIcons.activity, label: s.trAlSec),
              const SizedBox(height: 8),
              ...events.map((ev) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ev.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ev.cardBorder),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: ev.iconBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: t.border),
                          ),
                          child: Center(
                            child: Icon(ev.icon, size: 22, color: ev.iconFg),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ev.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: t.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ev.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: t.textMuted,
                                  height: 1.4,
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

              // Bottom Configure CTA (y=742 in FigCraft)
              HannaButton(
                label: s.trAlBtn,
                icon: LucideIcons.settings,
                variant: HannaButtonVariant.secondary,
                onPressed: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const NotificationPrefsScreen()),
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
