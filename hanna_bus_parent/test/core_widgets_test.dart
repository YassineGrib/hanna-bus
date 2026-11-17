import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_parent/core/l10n/app_strings.dart';
import 'package:hanna_bus_parent/core/theme/hanna_tokens.dart';
import 'package:hanna_bus_parent/core/theme/hanna_typography.dart';
import 'package:hanna_bus_parent/core/widgets/hanna_background.dart';
import 'package:hanna_bus_parent/core/widgets/hanna_badge.dart';
import 'package:hanna_bus_parent/core/widgets/hanna_button.dart';
import 'package:hanna_bus_parent/core/widgets/hanna_card.dart';
import 'package:hanna_bus_parent/core/widgets/hanna_floating_nav_bar.dart';
import 'package:hanna_bus_parent/core/widgets/hanna_header.dart';
import 'package:hanna_bus_parent/core/widgets/hanna_hero_card.dart';
import 'package:hanna_bus_parent/core/widgets/hanna_picker_sheet.dart';
import 'package:hanna_bus_parent/core/widgets/hanna_text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _harness(Widget child, {Brightness brightness = Brightness.light}) {
  HannaTypography.useGoogleFonts = false;
  return MaterialApp(
    theme: HannaTheme.build(
      palette: HannaPalette.mustard,
      brightness: brightness,
      locale: const Locale('en'),
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('Shared UI System widgets', () {
    testWidgets('HannaButton enforces loading/disabled states and token intent', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _harness(
          Column(
            children: [
              HannaButton(
                label: 'Track Live',
                onPressed: () => taps++,
              ),
              HannaButton(
                label: 'Busy',
                isLoading: true,
                onPressed: () => taps++,
              ),
              const HannaButton(
                label: 'Delete Account',
                variant: HannaButtonVariant.destructive,
                onPressed: null,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Track Live'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(taps, equals(1));

      await tester.tap(find.text('Busy'));
      await tester.pump();
      expect(taps, equals(1));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('HannaTextField shows error text and toggles obscured password', (tester) async {
      await tester.pumpWidget(
        _harness(
          const Padding(
            padding: EdgeInsets.all(16),
            child: HannaTextField(
              label: 'Password',
              obscureText: true,
              errorText: 'Must be at least 8 characters',
            ),
          ),
        ),
      );

      expect(find.text('Must be at least 8 characters'), findsOneWidget);
      await tester.tap(find.byIcon(LucideIcons.eye));
      await tester.pump();
      expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
    });

    testWidgets('HannaPickerSheet opens modal selector without DropdownButton', (tester) async {
      String current = 'bus04';
      await tester.pumpWidget(
        _harness(
          StatefulBuilder(
            builder: (context, setState) {
              return HannaPickerSheet<String>(
                label: 'Assigned Bus',
                value: current,
                options: const [
                  HannaPickerOption(value: 'bus04', label: 'Bus 04 - Hydra'),
                  HannaPickerOption(value: 'bus02', label: 'Bus 02 - El Biar'),
                ],
                onChanged: (val) => setState(() => current = val),
              );
            },
          ),
        ),
      );

      expect(find.byType(DropdownButton<String>), findsNothing);
      expect(find.text('Bus 04 - Hydra'), findsOneWidget);

      await tester.tap(find.text('Bus 04 - Hydra'));
      await tester.pumpAndSettle();
      expect(find.text('Bus 02 - El Biar'), findsOneWidget);

      await tester.tap(find.text('Bus 02 - El Biar'));
      await tester.pumpAndSettle();
      expect(current, equals('bus02'));
    });

    testWidgets('HannaFloatingNavBar highlights active item and switches tabs', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        _harness(
          StatefulBuilder(
            builder: (context, setState) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: HannaFloatingNavBar(
                  currentIndex: selected,
                  onTap: (i) => setState(() => selected = i),
                  strings: const AppStrings(Locale('en')),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-item-1')));
      await tester.pumpAndSettle();
      expect(selected, equals(1));
      expect(find.text('Track'), findsOneWidget);
    });

    testWidgets('HannaBackground, HannaHeroCard, HannaHeader, HannaCard, HannaBadge render cleanly', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _harness(
          HannaBackground(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                HannaHeader(
                  title: 'Morning Hub',
                  subtitle: 'Hydra North',
                ),
                SizedBox(height: 12),
                HannaHeroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HannaBadge(label: 'Live GPS', tone: HannaBadgeTone.accent),
                      SizedBox(height: 8),
                      Text('Bus 04 approaching', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                HannaCard(
                  child: Text('Full hairline card content'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Morning Hub'), findsOneWidget);
      expect(find.text('Bus 04 approaching'), findsOneWidget);
      expect(find.text('Full hairline card content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
