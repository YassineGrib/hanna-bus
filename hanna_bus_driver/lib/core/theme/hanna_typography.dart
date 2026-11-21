import 'package:flutter/material.dart';
import 'hanna_tokens.dart';

abstract final class HannaTypography {
  /// Font family names matching pubspec.yaml asset declarations.
  static const String fontArabic = 'IBM Plex Sans Arabic';
  static const String fontLatin = 'Inter';

  static const List<String> fallbackArabic = [
    'IBM Plex Sans Arabic',
    'Inter',
    'sans-serif',
  ];

  static const List<String> fallbackLatin = [
    'Inter',
    'IBM Plex Sans Arabic',
    'sans-serif',
  ];

  /// Set to false to ensure bundled asset fonts are always used without HTTP calls.
  static bool useGoogleFonts = false;

  static bool isArabicLocale(Locale locale) => locale.languageCode == 'ar';

  static String familyFor(Locale locale) =>
      isArabicLocale(locale) ? fontArabic : fontLatin;

  static List<String> fallbacksFor(Locale locale) =>
      isArabicLocale(locale) ? fallbackArabic : fallbackLatin;

  static TextStyle style(
    BuildContext context, {
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    final locale = Localizations.localeOf(context);
    final arabic = isArabicLocale(locale);
    final t = HannaTokens.of(context);
    return TextStyle(
      fontFamily: arabic ? fontArabic : fontLatin,
      fontFamilyFallback: arabic ? fallbackArabic : fallbackLatin,
      fontSize: arabic && size <= 17 ? size + 1 : size,
      fontWeight: weight,
      color: color ?? t.text,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _base({
    required Locale locale,
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    final arabic = isArabicLocale(locale);
    return TextStyle(
      fontFamily: arabic ? fontArabic : fontLatin,
      fontFamilyFallback: arabic ? fallbackArabic : fallbackLatin,
      fontSize: arabic && size <= 17 ? size + 1 : size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle mono({
    required double size,
    FontWeight weight = FontWeight.w600,
    required Color color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Courier New', 'monospace'],
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  static TextTheme buildTextTheme({
    required HannaTokens tokens,
    required Locale locale,
  }) {
    final arabic = isArabicLocale(locale);
    return TextTheme(
      displayLarge: _base(
        locale: locale,
        size: 32,
        weight: FontWeight.w800,
        color: tokens.text,
        height: arabic ? 1.25 : 1.12,
        letterSpacing: arabic ? 0 : -0.6,
      ),
      headlineMedium: _base(
        locale: locale,
        size: 24,
        weight: FontWeight.w700,
        color: tokens.text,
        height: arabic ? 1.3 : 1.2,
        letterSpacing: arabic ? 0 : -0.3,
      ),
      titleLarge: _base(
        locale: locale,
        size: 18,
        weight: FontWeight.w700,
        color: tokens.text,
        height: arabic ? 1.35 : 1.25,
      ),
      titleMedium: _base(
        locale: locale,
        size: 16,
        weight: FontWeight.w600,
        color: tokens.text,
        height: arabic ? 1.35 : 1.3,
      ),
      bodyLarge: _base(
        locale: locale,
        size: 15,
        weight: FontWeight.w500,
        color: tokens.text,
        height: arabic ? 1.55 : 1.45,
      ),
      bodyMedium: _base(
        locale: locale,
        size: 14,
        weight: FontWeight.w400,
        color: tokens.text,
        height: arabic ? 1.55 : 1.45,
      ),
      bodySmall: _base(
        locale: locale,
        size: 12,
        weight: FontWeight.w500,
        color: tokens.textMuted,
        height: arabic ? 1.45 : 1.35,
      ),
      labelLarge: _base(
        locale: locale,
        size: 14,
        weight: FontWeight.w700,
        color: tokens.text,
        height: 1.2,
      ),
      labelSmall: _base(
        locale: locale,
        size: 11,
        weight: FontWeight.w600,
        color: tokens.titleSoft,
        height: 1.2,
        letterSpacing: arabic ? 0 : 0.4,
      ),
    );
  }
}
