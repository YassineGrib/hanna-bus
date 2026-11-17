import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/demo_seed.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_header.dart';
import '../widgets/attendance_bar_chart.dart';
import 'report_absence_screen.dart';

class AttendanceAnalyticsScreen extends StatelessWidget {
  const AttendanceAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final child = state.selectedChild;
    final data = state.analytics ?? DemoSeed.analytics(child?.id ?? 'c1', child?.fullName ?? 'Youssef Mansouri');

    return Scaffold(
      body: HannaBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              HannaHeader(
                title: s.trAnTitle,
                trailing: Icon(LucideIcons.barChart2, size: 22, color: t.text),
                showBack: true,
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '${data.childName} · ${data.monthLabel}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3 KPI Cards
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      value: '${data.completed}',
                      label: s.trAk1K,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _KpiCard(
                      value: '${data.absences}',
                      label: s.trAk2K,
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _KpiCard(
                      value: '${data.missedQr}',
                      label: s.trAk3K,
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Weekly Ride Regularity Bar Chart Card
              _SectionHeader(title: s.trAnSecChart),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: t.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AttendanceBarChart(
                  points: data.weeklyRegularity,
                  morningLabel: s.periodMorning,
                  returnLabel: s.periodReturn,
                ),
              ),
              const SizedBox(height: 22),

              // Safety & Punctuality Score Cards
              _SectionHeader(title: s.trAnSecSafe),
              const SizedBox(height: 10),
              _ScoreCard(
                icon: LucideIcons.clock,
                iconBg: t.accent,
                iconColor: t.text,
                title: s.trAnS1T,
                subtitle: s.trAnS1S,
              ),
              const SizedBox(height: 10),
              _ScoreCard(
                icon: LucideIcons.shieldCheck,
                iconBg: t.actionPrimary,
                iconColor: t.onPrimary,
                title: s.trAnS2T,
                subtitle: s.trAnS2S,
              ),
              const SizedBox(height: 24),

              // Export CTA
              HannaButton(
                label: s.trAnBtn,
                icon: LucideIcons.download,
                variant: HannaButtonVariant.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        s.tr(
                          'Monthly attendance report exported to Downloads (PDF)',
                          'تم تصدير تقرير المواظبة الشهري إلى التنزيلات (PDF)',
                          'Rapport mensuel exporté en PDF',
                        ),
                      ),
                      backgroundColor: t.actionPrimary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Report Absence Link
              HannaButton(
                label: s.quickReportAbsence,
                icon: LucideIcons.calendar,
                variant: HannaButtonVariant.secondary,
                onPressed: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const ReportAbsenceScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.value,
    required this.label,
    required this.isPrimary,
  });

  final String value;
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final bg = isPrimary ? t.actionPrimary : t.surface;
    final fg = isPrimary ? t.onPrimary : t.text;
    final subFg = isPrimary ? t.onPrimary : t.textMuted;
    final border = isPrimary ? t.actionPrimary : t.border;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: subFg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: t.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: t.textMuted,
        letterSpacing: 0.3,
      ),
    );
  }
}
