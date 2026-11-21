import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/core/theme/hanna_tokens.dart';
import 'package:hanna_bus_driver/core/theme/hanna_typography.dart';

double _channelLinear(int c) {
  final s = c / 255.0;
  return s <= 0.03928
      ? s / 12.92
      : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
}

double _relativeLuminance(Color color) {
  final r = _channelLinear((color.r * 255.0).round());
  final g = _channelLinear((color.g * 255.0).round());
  final b = _channelLinear((color.b * 255.0).round());
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color a, Color b) {
  final l1 = _relativeLuminance(a);
  final l2 = _relativeLuminance(b);
  final hi = math.max(l1, l2);
  final lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  HannaTypography.useGoogleFonts = false;

  for (final palette in HannaPalette.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${palette.name} ${brightness.name} selected chip labels contrast on primary',
        (tester) async {
          final theme = HannaTheme.build(
            palette: palette,
            brightness: brightness,
            locale: const Locale('en'),
          );
          final tokens = theme.extension<HannaTokens>()!;
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: Wrap(
                  children: [
                    ChoiceChip(
                      label: const Text('Morning Route'),
                      selected: true,
                      onSelected: (_) {},
                    ),
                    FilterChip(
                      label: const Text('Selected filter'),
                      selected: true,
                      onSelected: (_) {},
                    ),
                    ChoiceChip(
                      label: const Text('Upcoming route'),
                      selected: false,
                      onSelected: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          );
          for (final label in ['Morning Route', 'Selected filter']) {
            final element = tester.element(find.text(label));
            final color = DefaultTextStyle.of(element).style.color!;
            expect(color, tokens.onPrimary);
            expect(
              _contrastRatio(color, tokens.actionPrimary),
              greaterThanOrEqualTo(4.5),
            );
          }
          expect(
            DefaultTextStyle.of(
              tester.element(find.text('Upcoming route')),
            ).style.color,
            tokens.text,
          );
          expect(theme.chipTheme.selectedColor, tokens.actionPrimary);
        },
      );
    }
  }

  group('HannaTokens 120-pair WCAG AA contrast audit', () {
    for (final palette in HannaPalette.values) {
      for (final brightness in Brightness.values) {
        test(
          '${palette.name} (${brightness.name}) passes all 20 semantic contrast pairs',
          () {
            final tokens = HannaTokens.forPalette(palette, brightness);

            final normalPairs = <String, (Color, Color)>{
              'text on background': (tokens.text, tokens.background),
              'text on surface': (tokens.text, tokens.surface),
              'textMuted on background': (tokens.textMuted, tokens.background),
              'textMuted on surface': (tokens.textMuted, tokens.surface),
              'link on background': (tokens.link, tokens.background),
              'link on surface': (tokens.link, tokens.surface),
              'onPrimary on actionPrimary': (
                tokens.onPrimary,
                tokens.actionPrimary,
              ),
              'onAccent on accent': (tokens.onAccent, tokens.accent),
              'onHero on heroSurface': (tokens.onHero, tokens.heroSurface),
              'onHeroMuted on heroSurface': (
                tokens.onHeroMuted,
                tokens.heroSurface,
              ),
              'heroAccent on heroSurface': (
                tokens.heroAccent,
                tokens.heroSurface,
              ),
              'onHeroAccent on heroAccent': (
                tokens.onHeroAccent,
                tokens.heroAccent,
              ),
              'onDestructive on actionDestructive': (
                tokens.onDestructive,
                tokens.actionDestructive,
              ),
              'actionDestructive on destructiveSurface': (
                tokens.actionDestructive,
                tokens.destructiveSurface,
              ),
              'onSuccess on success': (tokens.onSuccess, tokens.success),
              'success on successSurface': (
                tokens.success,
                tokens.successSurface,
              ),
              'onWarning on warning': (tokens.onWarning, tokens.warning),
              'warning on warningSurface': (
                tokens.warning,
                tokens.warningSurface,
              ),
              'text on surfaceSubtle': (tokens.text, tokens.surfaceSubtle),
            };

            for (final entry in normalPairs.entries) {
              final ratio = _contrastRatio(entry.value.$1, entry.value.$2);
              expect(
                ratio,
                greaterThanOrEqualTo(4.5),
                reason:
                    '${palette.name}/${brightness.name} "${entry.key}" contrast was ${ratio.toStringAsFixed(2)} (< 4.5)',
              );
            }

            final softTitleRatio = _contrastRatio(
              tokens.titleSoft,
              tokens.background,
            );
            expect(
              softTitleRatio,
              greaterThanOrEqualTo(3.0),
              reason:
                  '${palette.name}/${brightness.name} "titleSoft on background" was ${softTitleRatio.toStringAsFixed(2)} (< 3.0)',
            );
          },
        );
      }
    }

    test(
      'ThemeData attaches HannaTokens ThemeExtension and Arabic/Latin font config',
      () {
        final enTheme = HannaTheme.build(
          palette: HannaPalette.mustard,
          brightness: Brightness.light,
          locale: const Locale('en'),
        );
        final arTheme = HannaTheme.build(
          palette: HannaPalette.ocean,
          brightness: Brightness.dark,
          locale: const Locale('ar'),
        );

        final enTokens = enTheme.extension<HannaTokens>();
        final arTokens = arTheme.extension<HannaTokens>();

        expect(enTokens, isNotNull);
        expect(arTokens, isNotNull);
        expect(enTokens!.actionPrimary, equals(const Color(0xFFD4A017)));
        expect(arTokens!.actionPrimary, equals(const Color(0xFF29ADB2)));
        expect(HannaTypography.isArabicLocale(const Locale('ar')), isTrue);
        expect(HannaTypography.isArabicLocale(const Locale('en')), isFalse);
        expect(
          HannaTypography.familyFor(const Locale('ar')),
          equals('IBM Plex Sans Arabic'),
        );
        expect(HannaTypography.familyFor(const Locale('en')), equals('Inter'));
        expect(
          arTheme.textTheme.displayLarge!.fontFamily,
          equals('IBM Plex Sans Arabic'),
        );
        expect(
          arTheme.textTheme.bodyMedium!.fontFamily,
          equals('IBM Plex Sans Arabic'),
        );
        expect(
          arTheme.textTheme.labelLarge!.fontFamily,
          equals('IBM Plex Sans Arabic'),
        );
        expect(enTheme.textTheme.displayLarge!.fontFamily, equals('Inter'));
        expect(
          enTheme.textTheme.displayLarge!.fontSize,
          greaterThanOrEqualTo(28),
        );
      },
    );
  });
}
