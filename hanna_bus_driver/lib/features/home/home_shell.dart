import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/motion/hanna_motion.dart';
import '../../core/state/app_state.dart';
import '../../core/state/models.dart';
import '../../core/theme/hanna_tokens.dart';
import '../../core/theme/hanna_typography.dart';
import '../../core/widgets/driver_widgets.dart';
import '../../core/widgets/hanna_card.dart';
import '../../core/widgets/hanna_hero_card.dart';
import '../../core/widgets/hanna_icon.dart';
import '../fleet/fleet_screen.dart';
import '../profile/profile_screens.dart';
import '../settings/settings_screens.dart';
import '../messages/messages_screen.dart';
import '../navigation/navigation_screen.dart';
import '../sos/sos_screen.dart';
import '../students/students_screen.dart';
import '../trip/trip_screens.dart';
import '../boarding/scanner_screen.dart';

void openDriverScreen(BuildContext context, Widget screen) =>
    Navigator.of(context).push(HannaMotion.route(screen));

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.state});
  final DriverState state;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final state = widget.state;
      final s = AppStrings.of(context);
      return DriverPage(
        key: ValueKey(index),
        state: state,
        back: false,
        title: index == 0
            ? label(state.profile['user']?['name'], s.language)
            : index == 1
            ? s.design('children', 'page_title')
            : s.design('navigation', 'page_title'),
        header: Row(
          children: [
            CircleAvatar(
              backgroundColor: HannaTokens.of(context).accent,
              child: HannaIcon('user', color: HannaTokens.of(context).onAccent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    index == 0
                        ? label(state.profile['user']?['name'], s.language)
                        : index == 1
                        ? s.design('children', 'page_title')
                        : s.design('navigation', 'page_title'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (index == 0)
                    InkWell(
                      onTap: () =>
                          openDriverScreen(context, FleetScreen(state: state)),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HannaIcon('bus', size: 14),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '${s.t('bus')} ${state.currentBus?.number ?? ''} · ${label(state.currentBus?.line, s.language)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const HannaIcon('caret-down', size: 14),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: s.t('messages'),
              onPressed: () =>
                  openDriverScreen(context, MessagesScreen(state: state)),
              icon: Badge(
                isLabelVisible: state.unreadCount > 0,
                label: Text('${state.unreadCount}'),
                child: const HannaIcon('chat-circle-text'),
              ),
            ),
            IconButton(
              tooltip: s.t('settings'),
              onPressed: () =>
                  openDriverScreen(context, SettingsScreen(state: state)),
              icon: const HannaIcon('gear'),
            ),
            IconButton(
              tooltip: s.design('fleet', 's_title'),
              onPressed: () =>
                  openDriverScreen(context, SosScreen(state: state)),
              icon: const HannaIcon('warning-circle'),
            ),
          ],
        ),
        bottom: DriverNav(
          index: index,
          onTap: (i) {
            if (i == 3) {
              openDriverScreen(context, ProfileScreen(state: state));
              return;
            }
            setState(() => index = i);
          },
        ),
        children: index == 0
            ? missionWidgets(context, state)
            : index == 1
            ? [StudentsContent(state: state)]
            : [NavigationContent(state: state)],
      );
    },
  );
}

List<Widget> missionWidgets(BuildContext context, DriverState state) {
  final s = AppStrings.of(context);
  final t = HannaTokens.of(context);
  final trip = state.trip;
  final active = trip?.active == true;
  final station =
      trip?.stations.where((stop) => stop.status == 'current').firstOrNull ??
      trip?.stations.where((stop) => stop.status != 'completed').firstOrNull;
  return [
    DriverButton(
      '${s.t('messages')} (${state.unreadCount})',
      secondary: true,
      onPressed: () => openDriverScreen(context, MessagesScreen(state: state)),
    ),
    if (state.trips.isNotEmpty)
      Wrap(
        spacing: 8,
        children: [
          for (final route in state.trips)
            HannaChoiceChip(
              key: Key('trip-${route.id}'),
              label: Text(
                s.design(
                  'home',
                  route.period == 'morning' ? 'shift_am' : 'shift_pm',
                ),
              ),
              selected: trip?.id == route.id,
              onSelected: active || state.busy
                  ? null
                  : (_) => state.selectTrip(route.id),
            ),
        ],
      ),
    if (trip == null) Text(s.t('noTrips')),
    if (trip != null) ...[
      if (!active && trip.status == 'scheduled')
        HannaCard(
          onTap: () =>
              openDriverScreen(context, InspectionScreen(state: state)),
          child: Row(
            children: [
              HannaIcon(
                state.inspected ? 'check-circle' : 'shield-check',
                color: state.inspected ? t.success : t.warning,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.t(state.inspected ? 'inspected' : 'inspectionRequired'),
                ),
              ),
            ],
          ),
        ),
      HannaHeroCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.t(
                active
                    ? 'active'
                    : trip.status == 'completed'
                    ? 'completed'
                    : 'scheduled',
              ),
              style: HannaTypography.style(
                context,
                size: 13,
                color: t.heroAccent,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              active && station != null
                  ? label(station.name, s.language)
                  : label(trip.route, s.language),
              style: HannaTypography.style(
                context,
                size: 22,
                color: t.onHero,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: t.onHero.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  for (final stat in [
                    (state.students.length, s.t('enrolled')),
                    (
                      state.students.where((s) => s.absent).length,
                      s.t('absent'),
                    ),
                    (trip.stations.length, s.t('stops')),
                  ])
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${stat.$1}',
                            style: HannaTypography.style(
                              context,
                              size: 24,
                              color: t.heroAccent,
                              weight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            stat.$2,
                            textAlign: TextAlign.center,
                            style: HannaTypography.style(
                              context,
                              size: 11,
                              color: t.onHeroMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (trip.status == 'scheduled')
              DriverButton(
                s.t('start'),
                key: const Key('start-route'),
                icon: 'arrow-right',
                onPressed: state.busy
                    ? null
                    : () {
                        if (!state.inspected) {
                          openDriverScreen(
                            context,
                            InspectionScreen(state: state),
                          );
                        } else {
                          state.start();
                        }
                      },
              ),
            if (active)
              DriverButton(
                s.design('home', 'act_qr'),
                icon: 'qr-code',
                onPressed: state.busy
                    ? null
                    : () => openDriverScreen(
                        context,
                        ScannerScreen(state: state),
                      ),
              ),
          ],
        ),
      ),
      if (active && state.locationIssue != null)
        HannaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.t(state.locationIssue!)),
              TextButton(
                onPressed: () => state.sendLocation(requestPermission: true),
                child: Text(s.t('retry')),
              ),
            ],
          ),
        ),
      if (active && station != null) ...[
        SectionTitle(
          '${s.design('home', 'nav_roster')} · ${label(station.name, s.language)}',
        ),
        Text(
          '${state.onboard} / ${state.students.where((p) => !p.absent).length} · ${s.t('on_bus')}',
        ),
        for (final student in state.students.where(
          (p) => station.students.any((c) => c.id == p.id),
        ))
          StudentCard(student: student, state: state),
      ],
      SectionTitle(s.design('home', 'sec_actions')),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final action
              in <({String icon, String title, VoidCallback? tap})>[
                (
                  icon: 'qr-code',
                  title: s.design('home', 'act_qr'),
                  tap: active
                      ? () => openDriverScreen(
                          context,
                          ScannerScreen(state: state),
                        )
                      : null,
                ),
                (
                  icon: 'megaphone',
                  title: s.design('home', 'act_delay'),
                  tap: active ? () => showDelaySheet(context, state) : null,
                ),
                (
                  icon: 'users',
                  title: s.t('absent'),
                  tap: () => openDriverScreen(
                    context,
                    StudentsScreen(state: state, absentOnly: true),
                  ),
                ),
              ])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: HannaCard(
                  padding: const EdgeInsets.all(12),
                  onTap: action.tap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HannaIcon(
                        action.icon,
                        color: action.tap == null ? t.textMuted : t.link,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.title,
                        style: HannaTypography.style(
                          context,
                          size: 12,
                          weight: FontWeight.w700,
                          color: action.tap == null ? t.textMuted : t.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      SectionTitle(s.design('home', 'sec_stops')),
      for (final stop in trip.stations)
        StationCard(state: state, station: stop),
      if (active)
        DriverButton(
          s.t('end'),
          key: const Key('end-trip'),
          secondary: true,
          onPressed: state.busy
              ? null
              : () => openDriverScreen(context, SafetyWalkScreen(state: state)),
        ),
    ],
    DriverButton(
      s.t('refresh'),
      secondary: true,
      onPressed: state.busy ? null : () => state.run(state.refresh),
    ),
  ];
}

class StationCard extends StatelessWidget {
  const StationCard({super.key, required this.state, required this.station});
  final DriverState state;
  final Station station;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    return HannaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: t.accent,
                child: HannaIcon(
                  station.status == 'completed' ? 'check' : 'map-pin',
                  color: t.onAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label(station.name, s.language),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${station.time} · ${station.students.length} ${s.design('home', 'nav_roster')}',
                    ),
                    Text(
                      s.t(
                        station.status == 'completed'
                            ? 'stopCompleted'
                            : station.status,
                      ),
                      style: TextStyle(color: t.link),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (state.trip?.active == true) ...[
            const SizedBox(height: 10),
            DriverButton(
              s.design('navigation', 'btn_arrived'),
              key: Key('arrive-${station.id}'),
              secondary: true,
              onPressed: state.busy ? null : () => state.arrive(station.id),
            ),
          ],
        ],
      ),
    );
  }
}

class DriverNav extends StatelessWidget {
  const DriverNav({super.key, required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final items = [
      ('house', 'nav_home'),
      ('users', 'nav_roster'),
      ('map-pin', 'nav_nav'),
      ('user', 'nav_prof'),
    ];
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: t.heroSurface,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: t.text.withValues(alpha: .16),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var i = 0; i < 4; i++)
                  Expanded(
                    flex: i == index ? 2 : 1,
                    child: Semantics(
                      selected: i == index,
                      button: true,
                      label: s.design('home', items[i].$2),
                      child: Tooltip(
                        message: s.design('home', items[i].$2),
                        child: InkWell(
                          key: Key('nav-$i'),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => onTap(i),
                          child: AnimatedContainer(
                            duration: HannaMotion.effectiveDuration(
                              context,
                              HannaMotion.durationControl,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            height: 56,
                            decoration: BoxDecoration(
                              color: i == index
                                  ? t.actionPrimary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HannaIcon(
                                  items[i].$1,
                                  color: i == index
                                      ? t.onPrimary
                                      : t.onHeroMuted,
                                ),
                                if (i == index) ...[
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      s.design('home', items[i].$2),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: HannaTypography.style(
                                        context,
                                        size: 12,
                                        color: t.onPrimary,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
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
