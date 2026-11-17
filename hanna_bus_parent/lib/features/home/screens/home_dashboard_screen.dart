import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/models.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_badge.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_card.dart';
import '../../../core/widgets/hanna_hero_card.dart';
import 'notifications_screen.dart';
import 'quick_qr_pass_screen.dart';
import 'updates_support_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    super.key,
    required this.onOpenTrack,
    required this.onOpenChildren,
    required this.onOpenHistory,
  });

  final VoidCallback onOpenTrack;
  final VoidCallback onOpenChildren;
  final VoidCallback onOpenHistory;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isMorning = true;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final activeChild = state.selectedChild;
    final trip = state.activeTrip;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: t.actionPrimary,
        onRefresh: state.refreshDashboardData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _buildTopGreeting(context, state, s, t),
            if (state.isOfflineDemoMode) ...[
              const SizedBox(height: 8),
              HannaCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: t.surfaceSubtle,
                child: Row(
                  children: [
                    Icon(LucideIcons.sparkles, size: 14, color: t.link),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.offlineBanner,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: t.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (state.children.isNotEmpty) ...[
              _buildChildSwitcherStrip(context, state, activeChild, t),
              const SizedBox(height: 8),
            ],
            _buildPeriodToggle(context, s, t),
            const SizedBox(height: 12),
            HannaMotionEntrance(
              withScale: true,
              child: _buildLiveHeroCard(context, s, t, activeChild, trip),
            ),
            const SizedBox(height: 18),
            HannaMotionEntrance(
              delay: const Duration(milliseconds: 50),
              child: _buildQuickActionsSection(context, state, s, t, activeChild),
            ),
            const SizedBox(height: 18),
            HannaMotionEntrance(
              delay: const Duration(milliseconds: 100),
              child: _buildFamilyBoardSection(context, state, s, t),
            ),
            const SizedBox(height: 18),
            HannaMotionEntrance(
              delay: const Duration(milliseconds: 150),
              child: _buildSchoolUpdatesSection(context, state, s, t),
            ),
            const SizedBox(height: 85),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodToggle(BuildContext context, AppStrings s, HannaTokens t) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38,
            child: HannaButton(
              label: s.periodMorning,
              compact: true,
              selected: _isMorning,
              variant: HannaButtonVariant.secondary,
              icon: LucideIcons.sun,
              onPressed: () => setState(() => _isMorning = true),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 38,
            child: HannaButton(
              label: s.periodReturn,
              compact: true,
              selected: !_isMorning,
              variant: HannaButtonVariant.secondary,
              icon: LucideIcons.moon,
              onPressed: () => setState(() => _isMorning = false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopGreeting(
    BuildContext context,
    AppStateController state,
    AppStrings s,
    HannaTokens t,
  ) {
    final unread = state.unreadNotificationsCount;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: t.accent.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(color: t.actionPrimary, width: 1.5),
          ),
          child: Center(
            child: Icon(LucideIcons.user, size: 22, color: t.text),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.goodMorning,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: t.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                state.currentUser.name.isNotEmpty ? state.currentUser.name : 'Karim Mansouri',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              HannaMotion.route(const NotificationsScreen()),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: t.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.border),
                ),
                child: Center(
                  child: Icon(LucideIcons.bell, size: 19, color: t.text),
                ),
              ),
              if (unread > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: t.actionDestructive,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unread',
                      style: TextStyle(
                        color: t.onDestructive,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChildSwitcherStrip(
    BuildContext context,
    AppStateController state,
    ChildProfile? active,
    HannaTokens t,
  ) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final child = state.children[index];
          final firstName = child.fullName.split(' ').first;
          final selected = child.id == active?.id;
          return GestureDetector(
            onTap: () => state.selectChild(child.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? t.heroSurface : t.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? t.heroSurface : t.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: child.isAbsentToday
                          ? t.actionDestructive
                          : (selected ? t.heroAccent : t.success),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    firstName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? t.onHero : t.text,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveHeroCard(
    BuildContext context,
    AppStrings s,
    HannaTokens t,
    ChildProfile? child,
    ActiveTripData? trip,
  ) {
    final eta = child?.isAbsentToday == true
        ? 0
        : (_isMorning ? (trip?.etaMinutes ?? child?.etaMinutes ?? 6) : 14);
    final busNo = child?.busNumber ?? trip?.busNumber ?? '04';
    final progress = child?.isAbsentToday == true
        ? 0.0
        : (_isMorning ? (trip?.progress ?? child?.progress ?? 0.68) : 0.25);
    final stopName = child?.stopName ?? trip?.currentStreet ?? 'Hydra North';
    final windowTime = _isMorning ? (child?.stopTime ?? '07:25') : (child?.returnTime ?? '15:30');

    final etaDisplay = child?.isAbsentToday == true
        ? s.transitLabel('absent')
        : (s.isArabic ? '$eta دقائق' : '$eta min');

    final childName = s.isArabic
        ? (child != null && child.fullName.contains('Youssef')
            ? 'يوسف منصوري'
            : (child != null && child.fullName.contains('Amina')
                ? 'أمينة منصوري'
                : (child != null && child.fullName.contains('Rayan')
                    ? 'ريان منصوري'
                    : (child?.fullName ?? 'يوسف م.'))))
        : (child?.fullName ?? 'Youssef M.');

    return HannaHeroCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HannaBadge(
                label: 'BUS $busNo',
                icon: LucideIcons.bus,
                tone: HannaBadgeTone.hero,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  trip?.routeName ?? stopName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.onHeroMuted,
                      ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: t.onHero.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(HannaRadius.sm),
                ),
                child: Text(
                  child?.studentCode ?? 'HB-304',
                  style: HannaTypography.mono(
                    size: 11,
                    color: t.heroAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            etaDisplay,
            style: TextStyle(
              color: t.onHero,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            child != null
                ? '$childName: ${s.transitLabel(child.transitStatus)} ($windowTime)'
                : '$s.activeBusRide ($windowTime)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: t.onHeroMuted,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(HannaRadius.pill),
            child: LinearProgressIndicator(
              value: progress.clamp(0.05, 1.0),
              minHeight: 5,
              backgroundColor: t.onHero.withValues(alpha: 0.16),
              valueColor: AlwaysStoppedAnimation<Color>(t.heroAccent),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  stopName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: t.onHeroMuted,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: HannaTypography.mono(size: 11, color: t.heroAccent),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: widget.onOpenTrack,
                    icon: Icon(LucideIcons.navigation, size: 15, color: t.onPrimary),
                    label: Text(
                      s.trackLiveCta,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: t.onPrimary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.actionPrimary,
                      foregroundColor: t.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDriverCallSheet(context, s, t, child),
                    icon: Icon(LucideIcons.phone, size: 15, color: t.onHero),
                    label: Text(
                      s.quickCallDriver,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: t.onHero,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.onHero,
                      side: BorderSide(color: t.onHero.withValues(alpha: 0.35)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(
    BuildContext context,
    AppStateController state,
    AppStrings s,
    HannaTokens t,
    ChildProfile? child,
  ) {
    final absent = child?.isAbsentToday == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.tr('Quick Actions', 'إجراءات سريعة', 'Actions rapides'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. QR Pass
            _CompactSquircleAction(
              icon: LucideIcons.qrCode,
              label: s.quickQrPass,
              bgColor: t.accent.withValues(alpha: 0.7),
              iconColor: t.text,
              borderColor: t.actionPrimary.withValues(alpha: 0.5),
              onTap: () {
                Navigator.of(context).push(
                  HannaMotion.route(const QuickQrPassScreen()),
                );
              },
            ),
            // 2. Report Absence
            _CompactSquircleAction(
              icon: absent ? LucideIcons.circleCheck : LucideIcons.calendar,
              label: absent ? s.quickResumeRide : s.quickReportAbsence,
              bgColor: absent ? t.destructiveSurface : t.surface,
              iconColor: absent ? t.actionDestructive : t.text,
              borderColor: absent ? t.destructiveBorder : t.border,
              onTap: child == null
                  ? null
                  : () async {
                      if (absent) {
                        await state.resumeRideToday(child.id);
                      } else {
                        await state.reportAbsence(child.id);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              absent
                                  ? s.tr(
                                      'Ride resumed for ${child.fullName}.',
                                      'تم استئناف رحلة ${child.fullName}.',
                                      'Trajet repris pour ${child.fullName}.',
                                    )
                                  : s.tr(
                                      'Absence sent to Bus ${child.busNumber} driver.',
                                      'تم إرسال إشعار الغياب لسائق الحافلة ${child.busNumber}.',
                                      'Absence envoyée au chauffeur Bus ${child.busNumber}.',
                                    ),
                            ),
                          ),
                        );
                      }
                    },
            ),
            // 3. Schedule
            _CompactSquircleAction(
              icon: LucideIcons.clock,
              label: s.tr('Schedule', 'البرنامج', 'Planning'),
              bgColor: t.surface,
              iconColor: t.text,
              borderColor: t.border,
              onTap: () {
                if (child != null) {
                  state.selectChild(child.id);
                }
                widget.onOpenChildren();
              },
            ),
            // 4. SOS Call
            _CompactSquircleAction(
              icon: LucideIcons.phoneCall,
              label: s.tr('SOS Call', 'طوارئ', 'Appel SOS'),
              bgColor: t.destructiveSurface,
              iconColor: t.actionDestructive,
              borderColor: t.destructiveBorder,
              onTap: () => _showDriverCallSheet(context, s, t, child),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFamilyBoardSection(
    BuildContext context,
    AppStateController state,
    AppStrings s,
    HannaTokens t,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                s.todayFamilyRides,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onOpenHistory,
              child: Text(
                s.seeHistory,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: t.link,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...state.children.map((child) {
          final isArrived = child.transitStatus == 'arrived';
          final isOnBus = child.transitStatus == 'on_bus';
          final isAbsent = child.transitStatus == 'absent';

          final (badgeBg, badgeFg, badgeText) = isAbsent
              ? (t.destructiveSurface, t.actionDestructive, s.transitLabel('absent'))
              : (isOnBus
                  ? (t.actionPrimary, t.onPrimary, s.isArabic ? 'في الحافلة · ${child.etaMinutes} د' : 'On Bus · ${child.etaMinutes}m')
                  : (isArrived
                      ? (t.heroAccent, t.text, s.isArabic ? 'في المدرسة' : 'At School')
                      : (t.surfaceSubtle, t.textMuted, s.isArabic ? 'في المنزل' : 'At Home')));

          final childName = s.isArabic
              ? (child.fullName.contains('Youssef')
                  ? 'يوسف منصوري'
                  : (child.fullName.contains('Amina')
                      ? 'أمينة منصوري'
                      : (child.fullName.contains('Rayan') ? 'ريان منصوري' : child.fullName)))
              : child.fullName;

          final busSub = s.isArabic
              ? 'حافلة ${child.busNumber} · ${child.stopName}'
              : 'Bus ${child.busNumber} · ${child.stopName}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: child.id == state.selectedChild?.id ? t.actionPrimary : t.border,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    await state.selectChild(child.id);
                    widget.onOpenChildren();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isOnBus ? t.accent : t.background,
                            shape: BoxShape.circle,
                            border: Border.all(color: t.border),
                          ),
                          child: Center(
                            child: Icon(LucideIcons.bus, size: 18, color: t.text),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                childName,
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
                                busSub,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: badgeFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSchoolUpdatesSection(
    BuildContext context,
    AppStateController state,
    AppStrings s,
    HannaTokens t,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                s.tr('School & Route Updates', 'تحديثات المدرسة والمسار', 'Infos école & trajet'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  HannaMotion.route(const UpdatesSupportScreen()),
                );
              },
              child: Text(
                s.tr('All updates', 'كل الإعلانات', 'Tout voir'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: t.link,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: t.accent.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(LucideIcons.megaphone, size: 20, color: t.text),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.tr('Afternoon Return · 03:20 PM', 'رحلة العودة · 03:20 م', 'Retour après-midi · 15h20'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: t.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.tr(
                        'East Gate pickup confirmed for both buses.',
                        'موعد الصعود مؤكّد من البوابة الشرقية للحافلتين.',
                        'Embarquement Portail Est confirmé pour les deux bus.',
                      ),
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
      ],
    );
  }

  void _showDriverCallSheet(
    BuildContext context,
    AppStrings s,
    HannaTokens t,
    ChildProfile? child,
  ) {
    final driver = child?.driverName ?? 'Ahmed Benali';
    final phone = child?.driverPhone ?? '+213 550 77 88 99';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HannaRadius.xl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(HannaSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.quickCallDriver, style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: HannaSpace.xs),
                Text(
                  '$driver · Bus ${child?.busNumber ?? '04'}',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: t.textMuted),
                ),
                const SizedBox(height: HannaSpace.sm),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    phone,
                    style: HannaTypography.mono(size: 18, color: t.link),
                  ),
                ),
                const SizedBox(height: HannaSpace.lg),
                HannaButton(
                  label: '${s.callNow} ($phone)',
                  icon: LucideIcons.phone,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          s.tr(
                            'Dialing $driver on $phone',
                            'جاري الاتصال بالسائق $driver على $phone',
                            'Appel de $driver au $phone',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompactSquircleAction extends StatelessWidget {
  const _CompactSquircleAction({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, size: 22, color: iconColor),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: t.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
