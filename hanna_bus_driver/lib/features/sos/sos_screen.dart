import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/services/call_source.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/hanna_tokens.dart';
import '../../core/widgets/driver_widgets.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key, required this.state, this.calls});
  final DriverState state;
  final CallSource? calls;
  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with WidgetsBindingObserver {
  String type = 'accident';
  Timer? timer;
  bool holding = false, sent = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void cancel() {
    timer?.cancel();
    if (mounted) setState(() => holding = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) cancel();
  }

  void hold() {
    if (widget.state.busy || sent || holding) return;
    setState(() => holding = true);
    timer = Timer(const Duration(seconds: 3), () async {
      if (!mounted || !holding) return;
      cancel();
      final ok = await widget.state.sos(type);
      if (mounted) setState(() => sent = ok);
    });
  }

  Future<void> callSchool() async {
    const number = String.fromEnvironment('HANNA_SCHOOL_PHONE');
    if (number.isNotEmpty) {
      await call(number);
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).t('schoolUnavailable'))),
      );
    }
  }

  Future<void> call(String number) async {
    bool ok = false;
    try {
      ok = await (widget.calls ?? PhoneCallSource()).dial(number);
    } catch (_) {
      /* Show a localized error below. */
    }
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).t('callFailed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final s = AppStrings.of(context);
      final t = HannaTokens.of(context);
      final types = s.list('fleet', 's_types');
      final calls = s.list('fleet', 's_calls');
      return DriverPage(
        state: widget.state,
        title: s.design('fleet', 's_title'),
        children: [
          Text(s.t('sosHint')),
          SectionTitle(s.design('fleet', 's_what')),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < 4; i++)
                ChoiceChip(
                  label: Text(types[i][0].toString()),
                  selected:
                      type ==
                      ['accident', 'breakdown', 'medical', 'security'][i],
                  onSelected: holding || widget.state.busy || sent
                      ? null
                      : (_) => setState(
                          () => type = [
                            'accident',
                            'breakdown',
                            'medical',
                            'security',
                          ][i],
                        ),
                ),
            ],
          ),
          Center(
            child: Semantics(
              button: true,
              label: s.design('fleet', 's_hold'),
              child: Listener(
                key: const Key('sos-hold'),
                onPointerDown: (_) => hold(),
                onPointerUp: (_) => cancel(),
                onPointerCancel: (_) => cancel(),
                child: Focus(
                  onKeyEvent: (node, event) {
                    if (event.logicalKey.keyLabel == ' ' ||
                        event.logicalKey.keyLabel == 'Enter') {
                      if (event is KeyDownEvent) {
                        hold();
                      } else if (event is KeyUpEvent) {
                        cancel();
                      }
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: AnimatedContainer(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    height: 190,
                    width: 190,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: holding
                          ? t.actionDestructive.withValues(alpha: .8)
                          : t.actionDestructive,
                      border: Border.all(color: t.destructiveBorder, width: 8),
                    ),
                    child: Text(
                      sent
                          ? s.t('sosSent')
                          : holding
                          ? s.t('release')
                          : s.design('fleet', 's_hold'),
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: t.onDestructive),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text(s.t('sosLocation')),
          SectionTitle(s.design('fleet', 's_call')),
          DriverButton(
            '${calls[0][1]} · 14',
            secondary: true,
            onPressed: () => call('14'),
          ),
          DriverButton(
            '${calls[1][1]} · 17',
            secondary: true,
            onPressed: () => call('17'),
          ),
          DriverButton(
            '${calls[2][0]} · ${calls[2][1]}',
            secondary: true,
            onPressed: callSchool,
          ),
        ],
      );
    },
  );
}
