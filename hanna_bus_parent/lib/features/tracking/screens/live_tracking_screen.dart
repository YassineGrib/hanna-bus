import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_header.dart';
import '../../settings/screens/notification_prefs_screen.dart';
import '../widgets/live_route_map.dart';
import 'attendance_analytics_screen.dart';
import 'corridor_timeline_screen.dart';
import 'live_boarding_alerts_screen.dart';
import 'trip_history_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key, this.onBack, this.tileProvider});
  final VoidCallback? onBack;
  final TileProvider? tileProvider;

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final state = AppStateScope.maybeOf(context);
      if (state != null && !state.isOfflineDemoMode) {
        state.refreshActiveTrip();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final child = state.selectedChild;
    final trip = state.activeTrip;

    final eta = trip?.etaMinutes ?? child?.etaMinutes ?? 6;
    final busNo = trip?.busNumber ?? child?.busNumber ?? '04';
    final progress = trip?.progress ?? child?.progress ?? 0.68;

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
              // Header (y=44 in FigCraft)
              HannaHeader(
                title: s.trMapTitle,
                showBack: widget.onBack != null,
                onBack: widget.onBack,
                trailing: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      HannaMotion.route(const LiveBoardingAlertsScreen()),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.border),
                    ),
                    child: Center(
                      child: Icon(LucideIcons.radio, size: 18, color: t.text),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: HannaSpace.md),

              // Child Selector Pills (y=116 in FigCraft)
              if (state.children.isNotEmpty) ...[
                Row(
                  children: List.generate(state.children.length.clamp(0, 2), (idx) {
                    final c = state.children[idx];
                    final isSelected = c.id == child?.id;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => state.selectChild(c.id),
                        child: Container(
                          margin: EdgeInsets.only(right: idx == 0 ? 8 : 0),
                          height: 38,
                          decoration: BoxDecoration(
                            color: isSelected ? t.actionPrimary : t.surface,
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(
                              color: isSelected ? t.actionPrimary : t.border,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${c.fullName.split(' ').first} · Bus ${c.busNumber}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? t.onPrimary : t.textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
              ],

              // Active Proximity Alert Zone Banner
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const NotificationPrefsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.border),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.bell, size: 16, color: t.link),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.tr(
                            '${state.alertSettings.globalRadiusMeters}m proximity alert zone active',
                            'نطاق تنبيه الاقتراب ${state.alertSettings.globalRadiusMeters}م نشط',
                            'Zone d alerte de proximite ${state.alertSettings.globalRadiusMeters}m active',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: t.text,
                          ),
                        ),
                      ),
                      Icon(
                        s.isArabic ? LucideIcons.chevronLeft : LucideIcons.chevronRight,
                        size: 16,
                        color: t.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: HannaSpace.md),

              // Interactive Live Route Map Canvas (y=162 in FigCraft)
              LiveRouteMap(
                progress: progress,
                busNumber: busNo,
                streetLabel: trip?.currentStreet ?? 'Blvd des Martyrs',
                speedKmh: trip?.speedKmh ?? 38,
                height: 240,
                location: trip?.location,
                routePoints: trip?.routePoints,
                stations: trip?.stations,
                tileProvider: widget.tileProvider,
              ),
              const SizedBox(height: HannaSpace.md),

              // Bottom Live Ride Sheet (y=524 in FigCraft)
              Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: t.border),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, -4),
                      blurRadius: 20,
                      color: t.text.withValues(alpha: 0.08),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sheet Grabber line
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: t.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ETA Title & Subtitle
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            s.isArabic ? 'الوصول للمدرسة خلال $eta دقائق' : 'Arriving at School in $eta min',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                          ),
                        ),
                        Text(
                          '$eta min ETA',
                          style: HannaTypography.mono(
                            size: 14,
                            weight: FontWeight.w700,
                            color: t.link,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.trEtaSub,
                      style: TextStyle(
                        fontSize: 12,
                        color: t.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3-Step Route Progress Bar (y=608 in FigCraft)
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: t.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress.clamp(0.1, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: t.actionPrimary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.trSt1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.text),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            s.trSt2,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.link),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            s.trSt3,
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Driver & Quick Call Box (y=660 in FigCraft)
                    Container(
                      decoration: BoxDecoration(
                        color: t.background,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: t.border),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: t.heroAccent,
                              borderRadius: BorderRadius.circular(14),
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
                                  trip?.driverName ?? child?.driverName ?? s.trDrvNameDefault,
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
                                  trip?.plateNumber != null ? '${trip!.plateNumber} · Seat ${child?.seatNumber ?? "A2"}' : s.trDrvSubDefault,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: t.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Call Button
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Calling ${trip?.driverName ?? "Ahmed Benali"}...')),
                              );
                            },
                            child: Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: t.actionPrimary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                s.trBtnCall,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: t.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Open Route Stops CTA
                    HannaButton(
                      label: s.trRtTitle,
                      icon: LucideIcons.route,
                      onPressed: () {
                        Navigator.of(context).push(
                          HannaMotion.route(const CorridorTimelineScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    // Quick navigation actions row
                    Row(
                      children: [
                        Expanded(
                          child: HannaButton(
                            label: s.historyTab,
                            icon: LucideIcons.history,
                            variant: HannaButtonVariant.secondary,
                            compact: true,
                            onPressed: () {
                              Navigator.of(context).push(
                                HannaMotion.route(const TripHistoryScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: HannaButton(
                            label: s.analyticsTab,
                            icon: LucideIcons.barChart2,
                            variant: HannaButtonVariant.secondary,
                            compact: true,
                            onPressed: () {
                              Navigator.of(context).push(
                                HannaMotion.route(const AttendanceAnalyticsScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
