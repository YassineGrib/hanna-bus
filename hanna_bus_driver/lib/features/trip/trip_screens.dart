import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/driver_widgets.dart';
import '../../core/widgets/hanna_card.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({super.key, required this.state});
  final DriverState state;
  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  final items = {
    'tires': false,
    'brakes': false,
    'lights': false,
    'fuel': false,
  };
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final s = AppStrings.of(context);
      return DriverPage(
        state: widget.state,
        title: s.t('inspect'),
        children: [
          Text(s.t('inspectHint')),
          HannaCard(
            child: Column(
              children: [
                for (final key in items.keys)
                  CheckboxListTile(
                    key: Key('inspect-$key'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.t(key)),
                    value: items[key],
                    onChanged: widget.state.busy
                        ? null
                        : (v) => setState(() => items[key] = v == true),
                  ),
              ],
            ),
          ),
          DriverButton(
            s.t('saveInspection'),
            key: const Key('confirm-inspection'),
            onPressed: widget.state.busy || items.values.contains(false)
                ? null
                : () async {
                    if (await widget.state.inspect(items) && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
          ),
        ],
      );
    },
  );
}

class SafetyWalkScreen extends StatefulWidget {
  const SafetyWalkScreen({super.key, required this.state});
  final DriverState state;
  @override
  State<SafetyWalkScreen> createState() => _SafetyWalkScreenState();
}

class _SafetyWalkScreenState extends State<SafetyWalkScreen> {
  final checked = [false, false, false];
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final s = AppStrings.of(context);
      return DriverPage(
        state: widget.state,
        title: s.design('home', 'safe_proto'),
        children: [
          Text(
            s.design('home', 'safe_title'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(s.design('home', 'safe_sub')),
          HannaCard(
            child: Column(
              children: [
                for (var i = 0; i < 3; i++)
                  CheckboxListTile(
                    key: Key('walk-$i'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.t('walk${i + 1}')),
                    value: checked[i],
                    onChanged: widget.state.busy
                        ? null
                        : (v) => setState(() => checked[i] = v == true),
                  ),
              ],
            ),
          ),
          DriverButton(
            s.t('safeEnd'),
            key: const Key('confirm-safety'),
            onPressed: widget.state.busy || checked.contains(false)
                ? null
                : () async {
                    if (await widget.state.end(true) && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
          ),
        ],
      );
    },
  );
}

Future<void> showDelaySheet(BuildContext context, DriverState state) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DelaySheet(state: state),
    );

class DelaySheet extends StatefulWidget {
  const DelaySheet({super.key, required this.state});
  final DriverState state;
  @override
  State<DelaySheet> createState() => _DelaySheetState();
}

class _DelaySheetState extends State<DelaySheet> {
  int minutes = 5;
  String reason = 'traffic';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final s = AppStrings.of(context);
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.design('home', 'delay_title'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DriverFeedback(state: widget.state),
            Text(s.design('home', 'delay_pills_title')),
            Wrap(
              spacing: 12,
              children: [
                for (final n in [5, 10, 15, 30])
                  ChoiceChip(
                    label: Text('$n ${s.t('minutes')}'),
                    selected: minutes == n,
                    onSelected: (_) => setState(() => minutes = n),
                  ),
              ],
            ),
            Wrap(
              spacing: 10,
              children: [
                for (final r in ['traffic', 'breakdown', 'weather', 'other'])
                  ChoiceChip(
                    label: Text(s.t(r)),
                    selected: reason == r,
                    onSelected: (_) => setState(() => reason = r),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            DriverButton(
              s.t('broadcast'),
              onPressed: widget.state.busy
                  ? null
                  : () async {
                      if (await widget.state.delay(minutes, reason) &&
                          context.mounted) {
                        Navigator.pop(context);
                      }
                    },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.design('home', 'cancel')),
            ),
          ],
        ),
      );
    },
  );
}
