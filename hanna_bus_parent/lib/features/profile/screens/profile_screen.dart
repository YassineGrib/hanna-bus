import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_icon.dart';
import '../../settings/screens/settings_hub_screen.dart';
import 'add_child_screen.dart';
import 'child_details_screen.dart';
import 'edit_profile_screen.dart';
import 'emergency_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onSignedOut});
  final VoidCallback? onSignedOut;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final user = state.currentUser;
    final children = state.children;
    final locale = Localizations.localeOf(context);
    final isArabic = HannaTypography.isArabicLocale(locale);
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

    return Scaffold(
      backgroundColor: t.background,
      body: HannaBackground(
        variant: HannaBackgroundVariant.sweep,
        child: SafeArea(
          bottom: false,
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
            children: [
              // Top Bar Header: "Profile" with edit pencil icon and settings gear
              _ProfileTopBar(
                title: s.profileTitle,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onEdit: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const EditProfileScreen()),
                  );
                },
                onSettings: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const SettingsHubScreen()),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Hero Card (357w x 94h in design)
              Container(
                constraints: const BoxConstraints(minHeight: 96),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: t.border.withValues(alpha: 0.9), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: t.text.withValues(alpha: 0.05),
                      offset: const Offset(0, 8),
                      blurRadius: 22,
                    ),
                    BoxShadow(
                      color: t.actionPrimary.withValues(alpha: 0.04),
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar Slot (60x60 with accent fill and primary border)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: t.accent.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: t.actionPrimary, width: 2.0),
                          ),
                          child: Center(
                            child: HannaIcon('user', size: 28, color: t.text),
                          ),
                        ),
                        PositionedDirectional(
                          bottom: 0,
                          end: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: t.actionPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(color: t.surface, width: 1.5),
                            ),
                            child: Center(
                              child: HannaIcon('camera', size: 10, color: t.onPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Name and Role / Children info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              user.name.isNotEmpty ? user.name : 'Karim Mansouri',
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: fontFam,
                                fontFamilyFallback: fontFallbacks,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: t.text,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HannaIcon('users', size: 14, color: t.textMuted),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  children.isNotEmpty
                                      ? s.tr(
                                          'Parent · ${children.length} Children',
                                          'ولي أمر · ${children.length} أطفال',
                                          'Parent · ${children.length} enfants',
                                        )
                                      : s.profRoleDefault,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontFamily: fontFam,
                                    fontFamilyFallback: fontFallbacks,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: t.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Verified Badge: Rich pill with check-circle icon
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: t.accent.withValues(alpha: 0.50),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: t.actionPrimary.withValues(alpha: 0.35),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HannaIcon('check-circle', size: 12, color: t.text),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                s.profVerified,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: TextStyle(
                                  fontFamily: fontFam,
                                  fontFamilyFallback: fontFallbacks,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: t.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Label: "My Children" with "+ Add child" link
              _SectionHeader(
                iconName: 'users',
                title: s.secMyChildren,
                actionLabel: s.addActionChild,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onAction: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const AddChildScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Children Cards
              _ChildRowCard(
                name: children.isNotEmpty ? children[0].fullName : (isArabic ? 'يوسف منصوري' : 'Youssef Mansouri'),
                subtitle: children.isNotEmpty
                    ? '${children[0].grade} · Bus ${children[0].busNumber}'
                    : (isArabic ? 'السنة 3 ابتدائي · حافلة 04' : 'Grade 3 · Bus 04'),
                badge: children.isNotEmpty ? s.transitLabel(children[0].transitStatus) : (isArabic ? 'في الحافلة' : 'On Bus'),
                isPrimaryBadge: true,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () {
                  final c = children.isNotEmpty ? children[0] : null;
                  Navigator.of(context).push(
                    HannaMotion.route(ChildDetailsScreen(child: c)),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ChildRowCard(
                name: children.length > 1 ? children[1].fullName : (isArabic ? 'أمينة منصوري' : 'Amina Mansouri'),
                subtitle: children.length > 1
                    ? '${children[1].grade} · Bus ${children[1].busNumber}'
                    : (isArabic ? 'السنة 1 متوسط · حافلة 02' : 'Grade 6 · Bus 02'),
                badge: children.length > 1 ? s.transitLabel(children[1].transitStatus) : (isArabic ? 'في المدرسة' : 'At School'),
                isPrimaryBadge: false,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () {
                  final c = children.length > 1 ? children[1] : null;
                  Navigator.of(context).push(
                    HannaMotion.route(ChildDetailsScreen(child: c)),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Section Label: "My Info"
              _SectionHeader(
                iconName: 'identification-card',
                title: s.secMyInfo,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 12),

              // My Info Card (357w x 162h in design)
              Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.border, width: 1.0),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      iconName: 'phone',
                      label: s.lblPhone,
                      value: user.phone.isNotEmpty ? user.phone : '+213 550 12 34 56',
                      isLatinValue: true,
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),
                    _InfoRow(
                      iconName: 'envelope-simple',
                      label: s.lblEmail,
                      value: user.email.isNotEmpty ? user.email : 'k.mansouri@mail.dz',
                      isLatinValue: true,
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),
                    _InfoRow(
                      iconName: 'map-pin',
                      label: s.lblHomeStop,
                      value: user.primaryBusStop.isNotEmpty
                          ? user.primaryBusStop
                          : (isArabic ? 'حي النصر، الجزائر' : 'Hay El Nasr, Algiers'),
                      isLatinValue: false,
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Label: "Urgent Calls"
              _SectionHeader(
                iconName: 'phone-call',
                title: s.secUrgentCalls,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 12),

              // Urgent Driver Card: 357w x 68h
              _UrgentCard(
                iconName: 'phone-call',
                title: s.urgentDriverTitle,
                subtitle: s.urgentDriverSub,
                buttonLabel: s.urgentCallBtn,
                isDestructive: false,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${s.urgentCallBtn}: Ahmed Benali (+213 550 00 00 04)'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Urgent SOS Card: 357w x 68h in DSURF with DBORD
              _UrgentCard(
                iconName: 'warning-circle',
                title: s.urgentSosTitle,
                subtitle: s.urgentSosSub,
                buttonLabel: s.urgentSosBtn,
                isDestructive: true,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
                onTap: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const EmergencyScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({
    required this.title,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
    required this.onEdit,
    required this.onSettings,
  });

  final String title;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;
  final VoidCallback onEdit;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: fontFam,
                fontFamilyFallback: fontFallbacks,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: tokens.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Material(
                key: const ValueKey('profile-settings-gear'),
                color: tokens.border,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onSettings,
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Center(
                      child: HannaIcon('gear', size: 20, color: tokens.text),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: tokens.border,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onEdit,
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Center(
                      child: HannaIcon('pencil-simple', size: 20, color: tokens.text),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.iconName,
    this.actionLabel,
    this.onAction,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
  });

  final String title;
  final String? iconName;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
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
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(width: 8),
          Flexible(
            fit: FlexFit.loose,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  actionLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: fontFam,
                    fontFamilyFallback: fontFallbacks,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: tokens.link,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChildRowCard extends StatelessWidget {
  const _ChildRowCard({
    required this.name,
    required this.subtitle,
    required this.badge,
    required this.isPrimaryBadge,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final String badge;
  final bool isPrimaryBadge;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tokens.border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: tokens.text.withValues(alpha: 0.03),
                offset: const Offset(0, 3),
                blurRadius: 10,
              ),
            ],
          ),
          // Natural RTL / LTR layout: leading icon -> content -> trailing status tag
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bus Icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isPrimaryBadge ? tokens.accent : tokens.border,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HannaIcon('bus', size: 20, color: tokens.text),
                ),
              ),
              const SizedBox(width: 12),

              // Name and Subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        fontFamily: fontFam,
                        fontFamilyFallback: fontFallbacks,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Status Badge: Always pinned to the trailing edge of the card
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPrimaryBadge ? tokens.actionPrimary : tokens.accent.withValues(alpha: 0.50),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPrimaryBadge ? tokens.actionPrimary : tokens.border,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    badge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: fontFam,
                      fontFamilyFallback: fontFallbacks,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isPrimaryBadge ? tokens.onPrimary : tokens.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.iconName,
    required this.label,
    required this.value,
    required this.isLatinValue,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
  });

  final String iconName;
  final String label;
  final String value;
  final bool isLatinValue;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tokens.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tokens.border, width: 1.0),
            ),
            child: Center(
              child: HannaIcon(iconName, size: 16, color: tokens.text),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: fontFam,
                fontFamilyFallback: fontFallbacks,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: tokens.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Directionality(
              textDirection: isLatinValue ? TextDirection.ltr : Directionality.of(context),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: Directionality.of(context) == TextDirection.rtl ? TextAlign.start : TextAlign.end,
                style: TextStyle(
                  fontFamily: isLatinValue ? 'Inter' : fontFam,
                  fontFamilyFallback: fontFallbacks,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: tokens.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgentCard extends StatelessWidget {
  const _UrgentCard({
    required this.iconName,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.isDestructive,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
    required this.onTap,
  });

  final String iconName;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final bool isDestructive;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDestructive ? tokens.destructiveSurface : tokens.surface;
    final border = isDestructive ? tokens.destructiveBorder : tokens.border;
    final iconBg = isDestructive ? tokens.actionDestructive : tokens.accent;
    final iconFg = isDestructive ? tokens.onDestructive : tokens.text;
    final btnBg = isDestructive ? tokens.actionDestructive : tokens.actionPrimary;
    final btnFg = isDestructive ? tokens.onDestructive : tokens.onPrimary;

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: tokens.text.withValues(alpha: 0.03),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: HannaIcon(iconName, size: 18, color: iconFg),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: fontFam,
                    fontFamilyFallback: fontFallbacks,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: tokens.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: fontFam,
                    fontFamilyFallback: fontFallbacks,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Compact, well-proportioned Call/SOS action button
          Material(
            color: btnBg,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                constraints: const BoxConstraints(minHeight: 32, maxHeight: 32),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: Text(
                  buttonLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: fontFam,
                    fontFamilyFallback: fontFallbacks,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: btnFg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
