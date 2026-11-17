import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/models.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_header.dart';
import '../widgets/stylized_route_map.dart';

class TripReplayScreen extends StatefulWidget {
  const TripReplayScreen({super.key, required this.tripId});
  final String tripId;

  @override
  State<TripReplayScreen> createState() => _TripReplayScreenState();
}

class _TripReplayScreenState extends State<TripReplayScreen> {
  Future<TripHistorySummary>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AppStateScope.of(context).loadTripReplay(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);

    return Scaffold(
      body: HannaBackground(
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<TripHistorySummary>(
            future: _future,
            builder: (context, snapshot) {
              final trip = snapshot.data;
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  HannaSpace.lg,
                  HannaSpace.md,
                  HannaSpace.lg,
                  HannaSpace.pageBottomPad,
                ),
                children: [
                  // Header (matches both FigCraft title and test assertion)
                  HannaHeader(
                    title: s.tripReplayTitle,
                    subtitle: s.trHdTitle,
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
                        child: Icon(LucideIcons.download, size: 18, color: t.text),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Replay date caption (y=114 in FigCraft)
                  Center(
                    child: Text(
                      trip?.dateGroup != null
                          ? '${trip!.dateGroup} · ${trip.period == "morning" ? "Morning Pickup" : "Return Trip"}'
                          : s.trHdDate,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: t.link,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Recorded Route Map Replay (y=138 in FigCraft)
                  StylizedRouteMap(
                    progress: 1.0,
                    busNumber: trip?.busNumber ?? '04',
                    streetLabel: '${trip?.distanceKm ?? 6.8} km · ${trip?.durationMinutes ?? 24} min',
                    speedKmh: trip?.avgSpeedKmh ?? 32,
                    waypoints: trip?.waypoints ?? const [],
                    replayMode: true,
                    height: 220,
                  ),
                  const SizedBox(height: 10),

                  // Route Stats Bar (y=368 in FigCraft)
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${trip?.distanceKm ?? 6.8} km · ${trip?.durationMinutes ?? 24} min · Avg ${trip?.avgSpeedKmh ?? 32} km/h',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: t.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: HannaSpace.lg),

                  // QR Boarding & Hand-off Audit Log (y=420 in FigCraft)
                  _SectionLabel(icon: LucideIcons.qrCode, label: s.trHdSecQr),
                  const SizedBox(height: 8),
                  _AuditLogCard(
                    icon: LucideIcons.qrCode,
                    iconBg: t.heroAccent,
                    iconFg: t.text,
                    title: s.trHdQ1T,
                    subtitle: s.trHdQ1S,
                  ),
                  const SizedBox(height: 10),
                  _AuditLogCard(
                    icon: LucideIcons.shieldCheck,
                    iconBg: t.actionPrimary,
                    iconFg: t.onPrimary,
                    title: s.trHdQ2T,
                    subtitle: '${s.trHdQ2S} · Parent QR Handover',
                  ),
                  const SizedBox(height: HannaSpace.lg),

                  // Vehicle & Driver Record (y=616 in FigCraft)
                  _SectionLabel(icon: LucideIcons.bus, label: s.trHdSecDrv),
                  const SizedBox(height: 8),
                  Container(
                    height: 74,
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: t.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip?.vehicleModel != null ? 'Bus ${trip!.busNumber} · ${trip.vehicleModel}' : s.trHdDrvT,
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
                                trip?.driverName != null ? 'Driver: ${trip!.driverName} · Safety Rating ${trip.driverRating}/5' : s.trHdDrvS,
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

                  // Download trip receipt CTA (y=742 in FigCraft)
                  HannaButton(
                    label: s.trHdBtn,
                    icon: LucideIcons.download,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            s.tr(
                              'Downloading verified trip record PDF...',
                              'جاري تحميل تقرير الرحلة الموثّق بصيغة PDF...',
                              'Téléchargement du reçu PDF en cours...',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  const _AuditLogCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
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
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(icon, size: 22, color: iconFg),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
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
