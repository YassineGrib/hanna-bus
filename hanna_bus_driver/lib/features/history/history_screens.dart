import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/state/models.dart';
import '../../core/theme/hanna_tokens.dart';
import '../../core/widgets/driver_widgets.dart';
import '../../core/widgets/hanna_card.dart';
import '../../core/widgets/hanna_hero_card.dart';
import '../../core/widgets/remote_page.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.state});
  final DriverState state;
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String period = 'week';
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      children: [
        Expanded(
          child: RemotePage(
            key: ValueKey(period),
            state: widget.state,
            title: s.design('fleet', 'h_title'),
            load: () => widget.state.history(period),
            content: (context, data) => [
              Wrap(
                spacing: 8,
                children: [
                  for (final p in ['week', 'month', 'all'])
                    HannaChoiceChip(
                      label: Text(s.t(p)),
                      selected: p == period,
                      onSelected: (_) => setState(() => period = p),
                    ),
                ],
              ),
              MetricGrid(
                values: Map<String, dynamic>.from(data['totals'] ?? {}),
              ),
              SectionTitle(s.design('fleet', 'h_sec')),
              if ((data['trips'] as List? ?? []).isEmpty) Text(s.t('empty')),
              for (final trip in data['trips'] ?? <Json>[])
                HannaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip['date']} · ${s.t(trip['period'])}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(label(trip['route_name'], s.language)),
                      Text(
                        '${trip['departure_time']} · ${trip['arrival_time']}',
                      ),
                      Text('${trip['students']} ${s.t('students')}'),
                      Text(
                        '${s.t(trip['status_code'])}${trip['status_code'] == 'delayed' ? ' · ${trip['delay_minutes']} ${s.t('minutes')}' : ''}',
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
}

class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key, required this.values});
  final Json values;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final entry in values.entries)
          SizedBox(
            width: (constraints.maxWidth - 12) / 2,
            child: DataRowCard(
              AppStrings.of(context).t(entry.key),
              '${entry.value}${entry.key == 'on_time_rate' ? '%' : ''}',
            ),
          ),
      ],
    ),
  );
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.state});
  final DriverState state;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context), t = HannaTokens.of(context);
    return RemotePage(
      state: state,
      title: s.design('fleet', 'p_title'),
      load: state.stats,
      content: (context, data) => [
        HannaHeroCard(
          child: Column(
            children: [
              Text(
                '${data['rating'] ?? 0}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: t.onHero,
                ),
              ),
              Text(s.t('rating'), style: TextStyle(color: t.onHero)),
              Text(
                '${data['trips_count'] ?? 0} ${s.t('trips')}',
                style: TextStyle(color: t.onHeroMuted),
              ),
            ],
          ),
        ),
        MetricGrid(
          values: {
            for (final key in [
              'on_time_rate',
              'trips_this_month',
              'km_this_month',
              'safe_scans',
            ])
              key: data[key] ?? 0,
          },
        ),
        SectionTitle(s.design('fleet', 'p_chart')),
        HannaCard(
          child: WeekdayChart(
            days: List<Json>.from(
              (data['per_weekday'] as List? ?? []).map(
                (e) => Map<String, dynamic>.from(e),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WeekdayChart extends StatelessWidget {
  const WeekdayChart({super.key, required this.days});
  final List<Json> days;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context), t = HannaTokens.of(context);
    final labels = s.list('fleet', 'days');
    final max = days.fold<num>(
      1,
      (m, d) => (d['trips'] as num) > m ? d['trips'] as num : m,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final day in days)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Text(
                    '${day['trips']}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 100 * (day['trips'] as num) / max + 2,
                    decoration: BoxDecoration(
                      color: t.actionPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day['weekday'] is num
                        ? '${labels[(day['weekday'] as num).toInt().clamp(0, 4)]}'
                        : label(day['weekday'], s.language),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
