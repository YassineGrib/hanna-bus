import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/services/scanner_source.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/hanna_tokens.dart';
import '../../core/widgets/driver_widgets.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, required this.state, this.source});
  final DriverState state;
  final ScannerSource? source;
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final ScannerSource source = widget.source ?? CameraScannerSource();
  final code = TextEditingController();
  String type = 'boarded';
  bool processing = false;
  final Set<String> accepted = {};
  @override
  void dispose() {
    unawaited(source.dispose());
    code.dispose();
    super.dispose();
  }

  String studentCode(String raw) {
    final pass = raw.trim().split('|');
    if (pass.length >= 2 && pass.first == 'HANNA-BUS') return pass[1].trim();
    try {
      final value = jsonDecode(raw);
      if (value is Map && value['student_code'] is String) {
        return value['student_code'];
      }
    } on FormatException {
      /* Plain student codes are also accepted. */
    }
    return raw.trim();
  }

  Future<void> scan(String raw, {bool manual = false}) async {
    final value = studentCode(raw);
    final key = '$type/$value';
    if (value.isEmpty ||
        processing ||
        widget.state.busy ||
        (!manual && accepted.contains(key))) {
      return;
    }
    setState(() => processing = true);
    final success = await widget.state.board(
      value,
      method: manual ? 'manual' : 'qr',
      type: type,
    );
    if (success) {
      accepted.add(key);
      unawaited(HapticFeedback.lightImpact());
      if (widget.state.settings['scan_chime'] == true) {
        unawaited(SystemSound.play(SystemSoundType.click));
      }
    }
    if (mounted) setState(() => processing = false);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final s = AppStrings.of(context);
      final t = HannaTokens.of(context);
      return DriverPage(
        state: widget.state,
        title: s.design('home', 'qr_title'),
        children: [
          Text(s.t('scanHint')),
          Wrap(
            spacing: 12,
            children: [
              for (final mode in ['boarded', 'alighted'])
                ChoiceChip(
                  label: Text(s.t(mode)),
                  selected: type == mode,
                  onSelected: processing
                      ? null
                      : (_) => setState(() => type = mode),
                ),
            ],
          ),
          if (widget.state.settings['scan_mode'] != 'bluetooth')
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 280,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    source.preview(
                      onCode: (raw) => scan(raw),
                      error: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(s.t('cameraDenied')),
                      ),
                    ),
                    IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            border: Border.all(color: t.heroAccent, width: 3),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Text(
            '${widget.state.onboard} / ${widget.state.students.length} · ${s.t('on_bus')}',
          ),
          DriverField(
            label: s.t('studentCode'),
            controller: code,
            icon: 'qr-code',
            latin: true,
            onSubmitted: widget.state.settings['scan_mode'] == 'bluetooth'
                ? (raw) => scan(raw)
                : null,
          ),
          DriverButton(
            s.t('confirm'),
            key: const Key('manual-board'),
            onPressed: processing || widget.state.busy
                ? null
                : () => scan(code.text, manual: true),
          ),
        ],
      );
    },
  );
}
