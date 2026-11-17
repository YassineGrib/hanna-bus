import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';
import 'appearance_settings_screen.dart';
import 'delete_account_screen.dart';
import 'language_settings_screen.dart';
import 'notification_prefs_screen.dart';
import 'terms_privacy_screen.dart';

class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  void _showLogoutDialog(BuildContext context, AppStateController state, AppStrings s, HannaTokens t, String fontFam, List<String> fontFallbacks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: HannaIcon('sign-out', size: 22, color: t.text),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        s.cfLogoutTitle,
                        style: TextStyle(
                          fontFamily: fontFam,
                          fontFamilyFallback: fontFallbacks,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  s.cfLogoutBody,
                  style: TextStyle(
                    fontFamily: fontFam,
                    fontFamilyFallback: fontFallbacks,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: t.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: t.border),
                        ),
                        child: Text(
                          s.cfCancelBtn,
                          style: TextStyle(
                            fontFamily: fontFam,
                            fontFamilyFallback: fontFallbacks,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await state.logout();
                          if (context.mounted) {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: t.actionPrimary,
                          foregroundColor: t.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          s.signOut,
                          style: TextStyle(
                            fontFamily: fontFam,
                            fontFamilyFallback: fontFallbacks,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: t.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final locale = Localizations.localeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

    final isDark = state.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: t.background,
      body: HannaBackground(
        variant: HannaBackgroundVariant.sweep,
        child: SafeArea(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              // Header with Back Button and Gear
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: t.border,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: SizedBox(
                              width: 42,
                              height: 42,
                              child: Center(
                                child: HannaIcon(
                                  isRtl ? 'arrow-right' : 'arrow-left',
                                  size: 20,
                                  color: t.text,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          s.settingsTitle,
                          style: TextStyle(
                            fontFamily: fontFam,
                            fontFamilyFallback: fontFallbacks,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: Center(
                        child: HannaIcon('gear', size: 22, color: t.text),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Section: Appearance & Alerts
              _SettingsSectionHeader(
                iconName: 'palette',
                title: s.secAppearance,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.border, width: 1.0),
                ),
                child: Column(
                  children: [
                    // Row 1: Theme Palette
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          HannaMotion.route(const AppearanceSettingsScreen()),
                        );
                      },
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: t.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: t.border, width: 1.0),
                              ),
                              child: Center(
                                child: HannaIcon('palette', size: 18, color: t.text),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.rowTheme,
                                style: TextStyle(
                                  fontFamily: fontFam,
                                  fontFamilyFallback: fontFallbacks,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: t.text,
                                ),
                              ),
                            ),
                            // Swatches
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A017),
                                shape: BoxShape.circle,
                                border: Border.all(color: state.palette == HannaPalette.mustard ? t.text : Colors.transparent, width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFF455A64),
                                shape: BoxShape.circle,
                                border: Border.all(color: state.palette == HannaPalette.tealGray ? t.text : t.border, width: 1.0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              state.palette == HannaPalette.mustard
                                  ? s.valThemeMustard
                                  : (state.palette == HannaPalette.tealGray ? 'Teal' : 'Ocean'),
                              style: TextStyle(
                                fontFamily: fontFam,
                                fontFamilyFallback: fontFallbacks,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: t.link,
                              ),
                            ),
                            const SizedBox(width: 8),
                            HannaIcon(isRtl ? 'caret-left' : 'caret-right', size: 16, color: t.textMuted),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),

                    // Row 2: Light / Dark Mode Segmented Control
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: t.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: t.border, width: 1.0),
                            ),
                            child: Center(
                              child: HannaIcon(isDark ? 'moon' : 'sun', size: 18, color: t.text),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s.rowMode,
                              style: TextStyle(
                                fontFamily: fontFam,
                                fontFamilyFallback: fontFallbacks,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: t.text,
                              ),
                            ),
                          ),
                          // Segmented pill (122x34 in design)
                          Container(
                            height: 34,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: t.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: t.border, width: 1.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => state.setBrightness(Brightness.light),
                                  borderRadius: BorderRadius.circular(9),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: !isDark ? t.actionPrimary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Text(
                                      s.modeLight,
                                      style: TextStyle(
                                        fontFamily: fontFam,
                                        fontFamilyFallback: fontFallbacks,
                                        fontSize: 12,
                                        fontWeight: !isDark ? FontWeight.w700 : FontWeight.w600,
                                        color: !isDark ? t.onPrimary : t.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => state.setBrightness(Brightness.dark),
                                  borderRadius: BorderRadius.circular(9),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isDark ? t.actionPrimary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Text(
                                      s.modeDark,
                                      style: TextStyle(
                                        fontFamily: fontFam,
                                        fontFamilyFallback: fontFallbacks,
                                        fontSize: 12,
                                        fontWeight: isDark ? FontWeight.w700 : FontWeight.w600,
                                        color: isDark ? t.onPrimary : t.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),

                    // Row 3: Notifications
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          HannaMotion.route(const NotificationPrefsScreen()),
                        );
                      },
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: t.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: t.border, width: 1.0),
                              ),
                              child: Center(
                                child: HannaIcon('bell', size: 18, color: t.text),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.rowNotifications,
                                    style: TextStyle(
                                      fontFamily: fontFam,
                                      fontFamilyFallback: fontFallbacks,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: t.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.subNotifications,
                                    style: TextStyle(
                                      fontFamily: fontFam,
                                      fontFamilyFallback: fontFallbacks,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: t.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Switch control (48x28 in design)
                            Switch(
                              value: true,
                              activeThumbColor: t.onPrimary,
                              activeTrackColor: t.actionPrimary,
                              inactiveThumbColor: t.surface,
                              inactiveTrackColor: t.border,
                              onChanged: (_) {
                                Navigator.of(context).push(
                                  HannaMotion.route(const NotificationPrefsScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: General
              _SettingsSectionHeader(
                iconName: 'gear',
                title: s.secGeneral,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.border, width: 1.0),
                ),
                child: Column(
                  children: [
                    // Language Row
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          HannaMotion.route(const LanguageSettingsScreen()),
                        );
                      },
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: t.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: t.border, width: 1.0),
                              ),
                              child: Center(
                                child: HannaIcon('translate', size: 18, color: t.text),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.rowLanguage,
                                style: TextStyle(
                                  fontFamily: fontFam,
                                  fontFamilyFallback: fontFallbacks,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: t.text,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: t.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: t.border, width: 1.0),
                              ),
                              child: Text(
                                s.valLanguage,
                                style: TextStyle(
                                  fontFamily: fontFam,
                                  fontFamilyFallback: fontFallbacks,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: t.text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            HannaIcon(isRtl ? 'caret-left' : 'caret-right', size: 16, color: t.textMuted),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),

                    // Terms & Privacy Row
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          HannaMotion.route(const TermsPrivacyScreen()),
                        );
                      },
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: t.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: t.border, width: 1.0),
                              ),
                              child: Center(
                                child: HannaIcon('file-text', size: 18, color: t.text),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.rowTerms,
                                style: TextStyle(
                                  fontFamily: fontFam,
                                  fontFamilyFallback: fontFallbacks,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: t.text,
                                ),
                              ),
                            ),
                            HannaIcon(isRtl ? 'caret-left' : 'caret-right', size: 16, color: t.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: Account
              _SettingsSectionHeader(
                iconName: 'user',
                title: s.secAccount,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 12),

              // Secondary Button: Log out
              HannaButton(
                label: s.signOut,
                leadIconName: 'sign-out',
                variant: HannaButtonVariant.secondary,
                onPressed: () => _showLogoutDialog(context, state, s, t, fontFam, fontFallbacks),
              ),
              const SizedBox(height: 18),

              // Delete Account Card: 357x142 in DSURF with DBORD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: t.destructiveSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.destructiveBorder, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        HannaIcon('trash', size: 20, color: t.actionDestructive),
                        const SizedBox(width: 8),
                        Text(
                          s.deleteAccountTitle,
                          style: TextStyle(
                            fontFamily: fontFam,
                            fontFamilyFallback: fontFallbacks,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: t.actionDestructive,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.deleteCardSub,
                      style: TextStyle(
                        fontFamily: fontFam,
                        fontFamilyFallback: fontFallbacks,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: t.textMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Material(
                      color: t.actionDestructive,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            HannaMotion.route(const DeleteAccountScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 46,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HannaIcon('trash', size: 18, color: t.onDestructive),
                              const SizedBox(width: 8),
                              Text(
                                s.deleteAccountTitle,
                                style: TextStyle(
                                  fontFamily: fontFam,
                                  fontFamilyFallback: fontFallbacks,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: t.onDestructive,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Version
              Center(
                child: Text(
                  s.appVersion,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: t.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader({
    required this.title,
    this.iconName,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
  });

  final String title;
  final String? iconName;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (iconName != null) ...[
          HannaIcon(iconName!, size: 18, color: tokens.text),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontFamily: fontFam,
              fontFamilyFallback: fontFallbacks,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: tokens.text,
            ),
          ),
        ),
      ],
    );
  }
}
