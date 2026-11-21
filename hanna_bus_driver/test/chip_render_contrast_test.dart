import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/core/theme/hanna_tokens.dart';
import 'package:hanna_bus_driver/core/widgets/driver_widgets.dart';

double _contrast(Color a, Color b) {
  final l1 = math.max(a.computeLuminance(), b.computeLuminance());
  final l2 = math.min(a.computeLuminance(), b.computeLuminance());
  return (l1 + 0.05) / (l2 + 0.05);
}

/// Renders real ChoiceChips and measures the colour Flutter actually paints for each
/// label (the paragraph's resolved style), so a theme that is correct on paper but
/// resolves badly at runtime (seen on the emulator) fails here.
void main() {
  for (final palette in HannaPalette.values) {
    for (final brightness in Brightness.values) {
      testWidgets('chip labels are readable in ${palette.name} ${brightness.name}', (tester) async {
        final theme = HannaTheme.build(
          palette: palette,
          brightness: brightness,
          locale: const Locale('en'),
        );
        final tokens = HannaTokens.forPalette(palette, brightness);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Row(
                children: [
                  HannaChoiceChip(label: const Text('Selected chip'), selected: true, onSelected: (_) {}),
                  HannaChoiceChip(label: const Text('Plain chip'), selected: false, onSelected: (_) {}),
                  const HannaChoiceChip(label: Text('Running chip'), selected: true),
                  const HannaChoiceChip(label: Text('Locked chip'), selected: false),
                ],
              ),
            ),
          ),
        );

        Color painted(String text) {
          final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
          return paragraph.text.style!.color!;
        }

        expect(
          _contrast(painted('Selected chip'), tokens.actionPrimary),
          greaterThanOrEqualTo(4.5),
          reason: 'selected chip label ${painted('Selected chip')} on ${tokens.actionPrimary}',
        );
        expect(
          _contrast(painted('Plain chip'), tokens.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'plain chip label ${painted('Plain chip')} on ${tokens.surface}',
        );
        // Disabled chips (the running route is locked while a trip is active) stay readable.
        expect(
          _contrast(painted('Running chip'), tokens.actionPrimary),
          greaterThanOrEqualTo(4.5),
          reason: 'disabled selected chip label ${painted('Running chip')} on ${tokens.actionPrimary}',
        );
        expect(
          _contrast(painted('Locked chip'), tokens.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'disabled plain chip label ${painted('Locked chip')} on ${tokens.surface}',
        );
      });
    }
  }
}
