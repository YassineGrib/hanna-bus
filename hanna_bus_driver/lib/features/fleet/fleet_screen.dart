import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/state/models.dart';
import '../../core/widgets/driver_widgets.dart';
import '../../core/widgets/hanna_card.dart';
import '../../core/widgets/hanna_hero_card.dart';
import '../../core/theme/hanna_tokens.dart';

class FleetScreen extends StatelessWidget {
  const FleetScreen({super.key, required this.state});
  final DriverState state;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) {
      final s = AppStrings.of(context);
      final t = HannaTokens.of(context);
      final bus = state.currentBus;
      return DriverPage(
        state: state,
        title: s.design('fleet', 'f_title'),
        children: [
          if (bus != null)
            HannaHeroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.design('fleet', 'f_active'),
                    style: TextStyle(color: t.heroAccent),
                  ),
                  Text(
                    '${s.t('bus')} ${bus.number}',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: t.onHero),
                  ),
                  Text(
                    '${label(bus.line, s.language)} · ${bus.plate}',
                    style: TextStyle(color: t.onHeroMuted),
                  ),
                ],
              ),
            ),
          SectionTitle(s.design('fleet', 'f_week')),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.rotation.length,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final day = state.rotation[i];
                return SizedBox(
                  width: 88,
                  child: HannaCard(
                    selected: day.today,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          s.list('fleet', 'days')[i].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(day.bus ?? s.t('unassigned')),
                        if (day.today)
                          Text(
                            s.t('today'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SectionTitle(s.design('fleet', 'f_avail')),
          for (final other in state.buses)
            HannaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${s.t('bus')} ${other.number} · ${label(other.line, s.language)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${other.capacity} ${s.t('seats')} · ${s.t(other.status)}',
                  ),
                  if (!other.current) ...[
                    const SizedBox(height: 12),
                    DriverButton(
                      '${s.t('switch')} ${other.number}',
                      key: Key('switch-${other.id}'),
                      onPressed:
                          state.busy ||
                              other.status != 'available' ||
                              state.trip?.active == true
                          ? null
                          : () => state.switchBus(other.id),
                    ),
                  ],
                ],
              ),
            ),
          Text(s.design('fleet', 'f_note')),
        ],
      );
    },
  );
}
