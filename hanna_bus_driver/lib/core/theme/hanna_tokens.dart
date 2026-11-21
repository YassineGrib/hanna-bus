import 'package:flutter/material.dart';
import 'hanna_typography.dart';

enum HannaPalette {
  mustard('mustard'),
  tealGray('tealGray'),
  ocean('ocean');

  const HannaPalette(this.apiValue);
  final String apiValue;

  static HannaPalette fromApi(String? value) {
    return HannaPalette.values.firstWhere(
      (p) => p.apiValue == value || p.name == value,
      orElse: () => HannaPalette.mustard,
    );
  }
}

abstract final class HannaSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double minTouch = 48;
  static const double pageBottomPad = 120;
}

abstract final class HannaRadius {
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double pill = 999;
}

@immutable
class HannaTokens extends ThemeExtension<HannaTokens> {
  const HannaTokens({
    required this.palette,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.titleSoft,
    required this.actionPrimary,
    required this.onPrimary,
    required this.link,
    required this.accent,
    required this.onAccent,
    required this.heroSurface,
    required this.onHero,
    required this.onHeroMuted,
    required this.heroAccent,
    required this.onHeroAccent,
    required this.actionDestructive,
    required this.onDestructive,
    required this.destructiveSurface,
    required this.destructiveBorder,
    required this.success,
    required this.onSuccess,
    required this.successSurface,
    required this.successBorder,
    required this.warning,
    required this.onWarning,
    required this.warningSurface,
    required this.warningBorder,
    required this.mapBg,
    required this.mapPark,
    required this.mapBlock,
    required this.mapRoad,
    required this.abstractWarm,
    required this.abstractCool,
  });

  final HannaPalette palette;
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color titleSoft;
  final Color actionPrimary;
  final Color onPrimary;
  final Color link;
  final Color accent;
  final Color onAccent;
  final Color heroSurface;
  final Color onHero;
  final Color onHeroMuted;
  final Color heroAccent;
  final Color onHeroAccent;
  final Color actionDestructive;
  final Color onDestructive;
  final Color destructiveSurface;
  final Color destructiveBorder;
  final Color success;
  final Color onSuccess;
  final Color successSurface;
  final Color successBorder;
  final Color warning;
  final Color onWarning;
  final Color warningSurface;
  final Color warningBorder;
  final Color mapBg;
  final Color mapPark;
  final Color mapBlock;
  final Color mapRoad;
  final Color abstractWarm;
  final Color abstractCool;

  bool get isDark => brightness == Brightness.dark;

  static HannaTokens of(BuildContext context) {
    return Theme.of(context).extension<HannaTokens>() ??
        forPalette(HannaPalette.mustard, Theme.of(context).brightness);
  }

  static HannaTokens forPalette(HannaPalette palette, Brightness brightness) {
    final dark = brightness == Brightness.dark;

    final destructiveAction = dark
        ? const Color(0xFFEF5350)
        : const Color(0xFFC62828);
    final onDestructive = dark
        ? const Color(0xFF1A0808)
        : const Color(0xFFFFFFFF);
    final destructiveSurface = dark
        ? const Color(0xFF2D181A)
        : const Color(0xFFFDF2F2);
    final destructiveBorder = dark
        ? const Color(0xFF6E2D30)
        : const Color(0xFFF5C6C6);

    final success = dark ? const Color(0xFF4ADE80) : const Color(0xFF166534);
    final onSuccess = dark ? const Color(0xFF052E16) : const Color(0xFFFFFFFF);
    final successSurface = dark
        ? const Color(0xFF122B1D)
        : const Color(0xFFECFDF5);
    final successBorder = dark
        ? const Color(0xFF255739)
        : const Color(0xFFBBF7D0);

    final warning = dark ? const Color(0xFFFBBF24) : const Color(0xFF8A4B00);
    final onWarning = dark ? const Color(0xFF271500) : const Color(0xFFFFFFFF);
    final warningSurface = dark
        ? const Color(0xFF2D2212)
        : const Color(0xFFFFF7ED);
    final warningBorder = dark
        ? const Color(0xFF5F451A)
        : const Color(0xFFFED7AA);

    final mapBg = dark ? const Color(0xFF1B2024) : const Color(0xFFEFECE1);
    final mapPark = dark ? const Color(0xFF1E2E26) : const Color(0xFFDDE7DC);
    final mapBlock = dark ? const Color(0xFF252B31) : const Color(0xFFE6E1D2);
    final mapRoad = dark ? const Color(0xFF323941) : const Color(0xFFFFFFFF);

    switch (palette) {
      case HannaPalette.mustard:
        return HannaTokens(
          palette: palette,
          brightness: brightness,
          background: dark ? const Color(0xFF171612) : const Color(0xFFFFFDF5),
          surface: dark ? const Color(0xFF23211B) : const Color(0xFFFFFFFF),
          surfaceSubtle: dark
              ? const Color(0xFF2B2820)
              : const Color(0xFFFCF7E6),
          border: dark ? const Color(0xFF3D3624) : const Color(0xFFF7E7B5),
          text: dark ? const Color(0xFFFAF7EE) : const Color(0xFF2B2B2B),
          textMuted: dark ? const Color(0xFFB8B2A2) : const Color(0xFF5E5E5E),
          titleSoft: dark ? const Color(0xFF9A9484) : const Color(0xFF8C8C8C),
          actionPrimary: dark
              ? const Color(0xFFE5B328)
              : const Color(0xFFD4A017),
          onPrimary: dark ? const Color(0xFF1C1A14) : const Color(0xFF2B2B2B),
          link: dark ? const Color(0xFFF0C94C) : const Color(0xFF7A5A00),
          accent: dark ? const Color(0xFFD4A017) : const Color(0xFFF0C94C),
          onAccent: dark ? const Color(0xFF1C1A14) : const Color(0xFF2B2B2B),
          heroSurface: dark ? const Color(0xFF2B2820) : const Color(0xFF2B2B2B),
          onHero: dark ? const Color(0xFFFAF7EE) : const Color(0xFFFFFFFF),
          onHeroMuted: dark ? const Color(0xFFCFC8B6) : const Color(0xFFD6D0C0),
          heroAccent: const Color(0xFFF0C94C),
          onHeroAccent: const Color(0xFF1C1A14),
          actionDestructive: destructiveAction,
          onDestructive: onDestructive,
          destructiveSurface: destructiveSurface,
          destructiveBorder: destructiveBorder,
          success: success,
          onSuccess: onSuccess,
          successSurface: successSurface,
          successBorder: successBorder,
          warning: warning,
          onWarning: onWarning,
          warningSurface: warningSurface,
          warningBorder: warningBorder,
          mapBg: mapBg,
          mapPark: mapPark,
          mapBlock: mapBlock,
          mapRoad: mapRoad,
          abstractWarm: const Color(0xFFF0C94C),
          abstractCool: const Color(0xFFD4A017),
        );

      case HannaPalette.tealGray:
        return HannaTokens(
          palette: palette,
          brightness: brightness,
          background: dark ? const Color(0xFF12181B) : const Color(0xFFECEFF1),
          surface: dark ? const Color(0xFF1C2428) : const Color(0xFFFFFFFF),
          surfaceSubtle: dark
              ? const Color(0xFF232D32)
              : const Color(0xFFF4F6F8),
          border: dark ? const Color(0xFF2E3B41) : const Color(0xFFCFD8DC),
          text: dark ? const Color(0xFFEDF2F4) : const Color(0xFF263238),
          textMuted: dark ? const Color(0xFFA3B4BC) : const Color(0xFF546E7A),
          titleSoft: dark ? const Color(0xFF8699A3) : const Color(0xFF607D8B),
          actionPrimary: dark
              ? const Color(0xFF80CBC4)
              : const Color(0xFF455A64),
          onPrimary: dark ? const Color(0xFF12181B) : const Color(0xFFFFFFFF),
          link: dark ? const Color(0xFF80CBC4) : const Color(0xFF455A64),
          accent: dark ? const Color(0xFF4D9E97) : const Color(0xFF80CBC4),
          onAccent: dark ? const Color(0xFF12181B) : const Color(0xFF263238),
          heroSurface: dark ? const Color(0xFF202A2F) : const Color(0xFF263238),
          onHero: dark ? const Color(0xFFEDF2F4) : const Color(0xFFFFFFFF),
          onHeroMuted: dark ? const Color(0xFFB8C7CE) : const Color(0xFFCFD8DC),
          heroAccent: const Color(0xFF80CBC4),
          onHeroAccent: const Color(0xFF12181B),
          actionDestructive: destructiveAction,
          onDestructive: onDestructive,
          destructiveSurface: destructiveSurface,
          destructiveBorder: destructiveBorder,
          success: success,
          onSuccess: onSuccess,
          successSurface: successSurface,
          successBorder: successBorder,
          warning: warning,
          onWarning: onWarning,
          warningSurface: warningSurface,
          warningBorder: warningBorder,
          mapBg: mapBg,
          mapPark: mapPark,
          mapBlock: mapBlock,
          mapRoad: mapRoad,
          abstractWarm: const Color(0xFF80CBC4),
          abstractCool: const Color(0xFF607D8B),
        );

      case HannaPalette.ocean:
        return HannaTokens(
          palette: palette,
          brightness: brightness,
          background: dark ? const Color(0xFF0B1520) : const Color(0xFFE6F4F1),
          surface: dark ? const Color(0xFF132233) : const Color(0xFFFFFFFF),
          surfaceSubtle: dark
              ? const Color(0xFF192B40)
              : const Color(0xFFF0F9F8),
          border: dark ? const Color(0xFF223A52) : const Color(0xFFA8DADC),
          text: dark ? const Color(0xFFECF6F9) : const Color(0xFF0D1B2A),
          textMuted: dark ? const Color(0xFF9DB7C7) : const Color(0xFF3B5B70),
          titleSoft: dark ? const Color(0xFF85A1B4) : const Color(0xFF4F6D82),
          actionPrimary: dark
              ? const Color(0xFF29ADB2)
              : const Color(0xFF1B4965),
          onPrimary: dark ? const Color(0xFF0D1B2A) : const Color(0xFFFFFFFF),
          link: dark ? const Color(0xFF62D2D6) : const Color(0xFF1B4965),
          accent: dark ? const Color(0xFF1B4965) : const Color(0xFF29ADB2),
          onAccent: dark ? const Color(0xFFECF6F9) : const Color(0xFF0D1B2A),
          heroSurface: dark ? const Color(0xFF16293D) : const Color(0xFF0D1B2A),
          onHero: dark ? const Color(0xFFECF6F9) : const Color(0xFFFFFFFF),
          onHeroMuted: dark ? const Color(0xFFB5CEDB) : const Color(0xFFCBE6EA),
          heroAccent: const Color(0xFF62D2D6),
          onHeroAccent: const Color(0xFF0D1B2A),
          actionDestructive: destructiveAction,
          onDestructive: onDestructive,
          destructiveSurface: destructiveSurface,
          destructiveBorder: destructiveBorder,
          success: success,
          onSuccess: onSuccess,
          successSurface: successSurface,
          successBorder: successBorder,
          warning: warning,
          onWarning: onWarning,
          warningSurface: warningSurface,
          warningBorder: warningBorder,
          mapBg: mapBg,
          mapPark: mapPark,
          mapBlock: mapBlock,
          mapRoad: mapRoad,
          abstractWarm: const Color(0xFF62D2D6),
          abstractCool: const Color(0xFF29ADB2),
        );
    }
  }

  @override
  HannaTokens copyWith({HannaPalette? palette, Brightness? brightness}) {
    return forPalette(palette ?? this.palette, brightness ?? this.brightness);
  }

  @override
  HannaTokens lerp(covariant ThemeExtension<HannaTokens>? other, double t) {
    if (other is! HannaTokens) return this;
    return HannaTokens(
      palette: t < 0.5 ? palette : other.palette,
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      titleSoft: Color.lerp(titleSoft, other.titleSoft, t)!,
      actionPrimary: Color.lerp(actionPrimary, other.actionPrimary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      link: Color.lerp(link, other.link, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      heroSurface: Color.lerp(heroSurface, other.heroSurface, t)!,
      onHero: Color.lerp(onHero, other.onHero, t)!,
      onHeroMuted: Color.lerp(onHeroMuted, other.onHeroMuted, t)!,
      heroAccent: Color.lerp(heroAccent, other.heroAccent, t)!,
      onHeroAccent: Color.lerp(onHeroAccent, other.onHeroAccent, t)!,
      actionDestructive: Color.lerp(
        actionDestructive,
        other.actionDestructive,
        t,
      )!,
      onDestructive: Color.lerp(onDestructive, other.onDestructive, t)!,
      destructiveSurface: Color.lerp(
        destructiveSurface,
        other.destructiveSurface,
        t,
      )!,
      destructiveBorder: Color.lerp(
        destructiveBorder,
        other.destructiveBorder,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      mapBg: Color.lerp(mapBg, other.mapBg, t)!,
      mapPark: Color.lerp(mapPark, other.mapPark, t)!,
      mapBlock: Color.lerp(mapBlock, other.mapBlock, t)!,
      mapRoad: Color.lerp(mapRoad, other.mapRoad, t)!,
      abstractWarm: Color.lerp(abstractWarm, other.abstractWarm, t)!,
      abstractCool: Color.lerp(abstractCool, other.abstractCool, t)!,
    );
  }
}

abstract final class HannaTheme {
  static ThemeData build({
    required HannaPalette palette,
    required Brightness brightness,
    required Locale locale,
  }) {
    final t = HannaTokens.forPalette(palette, brightness);
    final textTheme = HannaTypography.buildTextTheme(tokens: t, locale: locale);
    final defaultFontFamily = HannaTypography.familyFor(locale);
    final fallbackFamilies = HannaTypography.fallbacksFor(locale);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: t.actionPrimary,
      onPrimary: t.onPrimary,
      secondary: t.accent,
      onSecondary: t.onAccent,
      error: t.actionDestructive,
      onError: t.onDestructive,
      surface: t.surface,
      onSurface: t.text,
      outline: t.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: defaultFontFamily,
      fontFamilyFallback: fallbackFamilies,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: t.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontFamily: defaultFontFamily,
          fontFamilyFallback: fallbackFamilies,
        ),
        labelStyle: TextStyle(
          fontFamily: defaultFontFamily,
          fontFamilyFallback: fallbackFamilies,
        ),
      ),
      extensions: [t],
      dividerTheme: DividerThemeData(color: t.border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: t.text,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.heroSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: t.onHero),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HannaRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
