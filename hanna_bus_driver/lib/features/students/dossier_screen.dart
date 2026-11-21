import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/services/call_source.dart';
import '../../core/state/app_state.dart';
import '../../core/state/models.dart';
import '../../core/widgets/driver_widgets.dart';
import '../../core/widgets/hanna_hero_card.dart';
import '../../core/widgets/remote_page.dart';
import '../../core/theme/hanna_tokens.dart';

Future<void> dialContact(
  BuildContext context,
  String number,
  CallSource? source,
) async {
  bool ok = false;
  try {
    if (number.isNotEmpty) {
      ok = await (source ?? PhoneCallSource()).dial(number);
    }
  } catch (_) {
    /* Localized feedback. */
  }
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.of(context).t('callFailed'))),
    );
  }
}

class DossierScreen extends StatefulWidget {
  const DossierScreen({
    super.key,
    required this.state,
    required this.childId,
    this.calls,
    this.initialTab = 'transit',
  });
  final DriverState state;
  final String childId, initialTab;
  final CallSource? calls;
  @override
  State<DossierScreen> createState() => _DossierScreenState();
}

class _DossierScreenState extends State<DossierScreen> {
  late String tab = widget.initialTab;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context), t = HannaTokens.of(context);
    return RemotePage(
      state: widget.state,
      title: s.design('children', 'dossier_title'),
      load: () => widget.state.dossier(widget.childId),
      content: (context, data) {
        final student = data['student'] as Map,
            section = data[tab] as Map? ?? {};
        return [
          HannaHeroCard(
            child: Column(
              children: [
                Text(
                  label(student['name'], s.language),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: t.onHero),
                ),
                Text(
                  '${student['student_code'] ?? ''}',
                  style: TextStyle(color: t.onHeroMuted),
                ),
                Text(
                  '${student['grade'] ?? ''} · ${student['seat_number'] ?? ''}',
                  style: TextStyle(color: t.onHeroMuted),
                ),
                Text(
                  s.t(
                    student['absent'] == true
                        ? 'absent'
                        : student['transit_status'] ?? 'waiting',
                  ),
                  style: TextStyle(color: t.onHero),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final item in ['transit', 'medical', 'guardian'])
                ChoiceChip(
                  key: Key('dossier-$item'),
                  label: Text(
                    s.design(
                      'children',
                      item == 'transit'
                          ? 'tab_transit'
                          : item == 'medical'
                          ? 'tab_med'
                          : 'tab_guard',
                    ),
                  ),
                  selected: tab == item,
                  onSelected: (_) => setState(() => tab = item),
                ),
            ],
          ),
          for (final key
              in tab == 'transit'
                  ? [
                      'bus_number',
                      'seat_number',
                      'stop_name',
                      'stop_time',
                      'return_time',
                      'dismissal_rule',
                    ]
                  : tab == 'medical'
                  ? [
                      'blood_type',
                      'allergies',
                      'chronic_conditions',
                      'first_aid_protocol',
                    ]
                  : ['name', 'phone', 'backup_phone'])
            DataRowCard(s.t(key), label(section[key], s.language)),
          if (tab == 'guardian') ...[
            for (final key in ['phone', 'backup_phone'])
              if ('${section[key] ?? ''}'.isNotEmpty)
                DriverButton(
                  '${s.t('call')} · ${s.t(key)}',
                  key: Key('guardian-$key'),
                  onPressed: () =>
                      dialContact(context, '${section[key]}', widget.calls),
                ),
            DataRowCard(
              s.t('dismissal_rule'),
              label(data['transit']?['dismissal_rule'], s.language),
            ),
          ],
        ];
      },
    );
  }
}
