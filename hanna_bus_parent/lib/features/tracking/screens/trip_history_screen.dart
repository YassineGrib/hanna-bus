import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_header.dart';
import 'attendance_analytics_screen.dart';
import 'trip_replay_screen.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  String _activeFilter = 'all'; // 'all', 'morning', 'return'

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final child = state.selectedChild;

    final trips = state.tripHistory.where((tr) {
      if (_activeFilter == 'morning') return tr.period == 'morning';
      if (_activeFilter == 'return') return tr.period == 'return';
      return true;
    }).toList();

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
                title: s.trHsTitle,
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
                    child: Icon(LucideIcons.calendar, size: 18, color: t.text),
                  ),
                ),
              ),
              const SizedBox(height: HannaSpace.md),

              // Child & Month Filter Selectors (y=116 in FigCraft)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: t.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(LucideIcons.user, size: 16, color: t.text),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              child != null ? '${child.fullName.split(" ").first} M.' : 'Youssef M.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: t.text,
                              ),
                            ),
                          ),
                          Icon(LucideIcons.chevronDown, size: 14, color: t.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: t.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(LucideIcons.calendar, size: 16, color: t.text),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.isArabic ? 'نوفمبر 2026' : 'Nov 2026',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: t.text,
                              ),
                            ),
                          ),
                          Icon(LucideIcons.chevronDown, size: 14, color: t.textMuted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter Chips (y=168 in FigCraft)
              Row(
                children: [
                  _FilterChip(
                    label: s.isArabic ? 'الكل (42)' : 'All',
                    selected: _activeFilter == 'all',
                    onTap: () => setState(() => _activeFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: s.isArabic ? 'الصباح (21)' : 'Morning',
                    selected: _activeFilter == 'morning',
                    onTap: () => setState(() => _activeFilter = 'morning'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: s.isArabic ? 'العودة (21)' : 'Return',
                    selected: _activeFilter == 'return',
                    onTap: () => setState(() => _activeFilter = 'return'),
                  ),
                ],
              ),
              const SizedBox(height: HannaSpace.md),

              // 3 Summary KPI blocks (y=210..272 in FigCraft)
              Row(
                children: [
                  Expanded(
                    child: _KpiBlock(value: '42', label: s.trHk1K),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _KpiBlock(value: '100%', label: s.trHk2K),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _KpiBlock(value: '98%', label: s.trHk3K),
                  ),
                ],
              ),
              const SizedBox(height: HannaSpace.lg),

              // Group 1: Yesterday · Mon 09 Nov (y=284 in FigCraft)
              _SectionLabel(icon: LucideIcons.calendar, label: s.trHsD1),
              const SizedBox(height: 8),
              if (_activeFilter == 'all' || _activeFilter == 'return')
                _TripCard(
                  title: s.trH1T,
                  routeSubtitle: s.trH1S,
                  timeWindow: '15:30 -> 15:54',
                  badgeText: s.trH1B,
                  isTraffic: false,
                  onTap: () => _openReplay(context, trips.firstOrNull?.id ?? 'tr-1'),
                ),
              if (_activeFilter == 'all' || _activeFilter == 'morning') ...[
                const SizedBox(height: 8),
                _TripCard(
                  title: s.trH2T,
                  routeSubtitle: s.trH2S,
                  timeWindow: '07:25 -> 07:49',
                  badgeText: s.trH1B,
                  isTraffic: false,
                  onTap: () => _openReplay(context, trips.length > 1 ? trips[1].id : 'tr-2'),
                ),
              ],
              const SizedBox(height: HannaSpace.lg),

              // Group 2: Sun 08 Nov (y=502 in FigCraft)
              _SectionLabel(icon: LucideIcons.calendar, label: s.trHsD2),
              const SizedBox(height: 8),
              if (_activeFilter == 'all' || _activeFilter == 'return')
                _TripCard(
                  title: s.trH3T,
                  routeSubtitle: s.trH3S,
                  timeWindow: '15:30 -> 15:58',
                  badgeText: s.trH3B,
                  isTraffic: true,
                  onTap: () => _openReplay(context, trips.firstOrNull?.id ?? 'tr-1'),
                ),
              if (_activeFilter == 'all' || _activeFilter == 'morning') ...[
                const SizedBox(height: 8),
                _TripCard(
                  title: s.trH4T,
                  routeSubtitle: s.trH4S,
                  timeWindow: '07:25 -> 07:49',
                  badgeText: s.trH1B,
                  isTraffic: false,
                  onTap: () => _openReplay(context, trips.length > 1 ? trips[1].id : 'tr-2'),
                ),
              ],
              const SizedBox(height: HannaSpace.lg),

              // Attendance Report CTA Button (y=742 in FigCraft)
              HannaButton(
                label: s.trAnTitle,
                icon: LucideIcons.barChart2,
                variant: HannaButtonVariant.secondary,
                onPressed: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const AttendanceAnalyticsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReplay(BuildContext context, String tripId) {
    Navigator.of(context).push(
      HannaMotion.route(TripReplayScreen(tripId: tripId)),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? t.actionPrimary : t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? t.actionPrimary : t.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? t.onPrimary : t.text,
          ),
        ),
      ),
    );
  }
}

class _KpiBlock extends StatelessWidget {
  const _KpiBlock({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Container(
      height: 60,
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
            style: HannaTypography.mono(
              size: 16,
              weight: FontWeight.w700,
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

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.title,
    required this.routeSubtitle,
    required this.timeWindow,
    required this.badgeText,
    required this.isTraffic,
    required this.onTap,
  });

  final String title;
  final String routeSubtitle;
  final String timeWindow;
  final String badgeText;
  final bool isTraffic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: t.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.border),
                  ),
                  child: Center(
                    child: Icon(LucideIcons.bus, size: 22, color: t.text),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        routeSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: t.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeWindow,
                        style: HannaTypography.mono(
                          size: 11,
                          color: t.link,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTraffic ? t.actionPrimary : t.heroAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isTraffic ? t.onPrimary : t.text,
                    ),
                  ),
                ),
              ],
            ),
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
