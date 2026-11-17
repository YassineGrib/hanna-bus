import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_icon.dart';

class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  State<NotificationPrefsScreen> createState() => _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends State<NotificationPrefsScreen> {
  bool _initialized = false;
  late int _radius;
  late bool _approaching;
  late bool _boarded;
  late bool _arrived;
  late bool _delays;
  late bool _criticalSound;
  late bool _smsBackup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final s = AppStateScope.of(context).alertSettings;
      _radius = s.globalRadiusMeters;
      _approaching = s.busApproaching;
      _boarded = s.childBoarded;
      _arrived = s.arrivedSafely;
      _delays = s.routeDelays;
      _criticalSound = s.criticalSosSound;
      _smsBackup = s.smsBackup;
      _initialized = true;
    }
  }

  void _persist() {
    final state = AppStateScope.of(context);
    final current = state.alertSettings;
    state.updateAlertSettings(
      current.copyWith(
        globalRadiusMeters: _radius,
        busApproaching: _approaching,
        childBoarded: _boarded,
        arrivedSafely: _arrived,
        routeDelays: _delays,
        criticalSosSound: _criticalSound,
        smsBackup: _smsBackup,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final locale = Localizations.localeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

    return Scaffold(
      backgroundColor: t.background,
      body: HannaBackground(
        variant: HannaBackgroundVariant.sweep,
        child: SafeArea(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              // Top Bar Header
              SizedBox(
                height: 44,
                child: Row(
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
                    Expanded(
                      child: Text(
                        s.nfTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          fontFamily: fontFam,
                          fontFamilyFallback: fontFallbacks,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section: Geofence Radius
              _SectionHeader(
                iconName: 'broadcast',
                title: s.nfSecGeofence,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.border, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: t.text.withValues(alpha: 0.04),
                      offset: const Offset(0, 4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            s.nfGeofenceTrigger,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: fontFam,
                              fontFamilyFallback: fontFallbacks,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: t.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Prominent Live Distance Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: t.accent.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: t.actionPrimary.withValues(alpha: 0.35),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HannaIcon('navigation-arrow', size: 12, color: t.text),
                              const SizedBox(width: 5),
                              Text(
                                s.nfDistanceFormatted(_radius),
                                style: TextStyle(
                                  fontFamily: fontFam,
                                  fontFamilyFallback: fontFallbacks,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: t.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.nfGeofenceDesc,
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

                    // Estimated Time Callout Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: t.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: t.border.withValues(alpha: 0.7)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HannaIcon('clock', size: 14, color: t.actionPrimary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              s.nfEstimatedTime(_radius),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: fontFam,
                                fontFamilyFallback: fontFallbacks,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: t.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Smooth Interactive Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6.0,
                        activeTrackColor: t.actionPrimary,
                        inactiveTrackColor: t.border,
                        thumbColor: t.actionPrimary,
                        overlayColor: t.accent.withValues(alpha: 0.35),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10.0,
                          elevation: 3.0,
                          pressedElevation: 6.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                      ),
                      child: Slider(
                        value: _radius.toDouble().clamp(100.0, 1500.0),
                        min: 100.0,
                        max: 1500.0,
                        divisions: 28, // 50m steps
                        onChanged: (val) {
                          final stepped = ((val / 50).round() * 50).clamp(100, 1500);
                          setState(() => _radius = stepped);
                        },
                        onChangeEnd: (_) => _persist(),
                      ),
                    ),

                    // Slider Range Limits
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s.nfDistanceMeters(100),
                            style: TextStyle(
                              fontFamily: fontFam,
                              fontFamilyFallback: fontFallbacks,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: t.textMuted,
                            ),
                          ),
                          Text(
                            s.nfDistanceMeters(1500),
                            style: TextStyle(
                              fontFamily: fontFam,
                              fontFamilyFallback: fontFallbacks,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: t.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quick Preset Shortcut Pills
                    Row(
                      children: [
                        Text(
                          s.nfQuickPresets,
                          style: TextStyle(
                            fontFamily: fontFam,
                            fontFamilyFallback: fontFallbacks,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: t.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            alignment: WrapAlignment.end,
                            children: [200, 500, 1000].map((preset) {
                              final isSelected = _radius == preset;
                              return InkWell(
                                onTap: () {
                                  setState(() => _radius = preset);
                                  _persist();
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? t.actionPrimary : t.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? t.actionPrimary : t.border,
                                    ),
                                  ),
                                  child: Text(
                                    s.nfDistanceMeters(preset),
                                    style: TextStyle(
                                      fontFamily: fontFam,
                                      fontFamilyFallback: fontFallbacks,
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? t.onPrimary : t.text,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Section: Live Bus & Child Alerts
              _SectionHeader(
                iconName: 'bus',
                title: s.nfSecBus,
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
                    _NotifToggleRow(
                      iconName: 'bus',
                      title: s.nf1Title,
                      subtitle: s.nf1Sub,
                      value: _approaching,
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                      onChanged: (v) {
                        setState(() => _approaching = v);
                        _persist();
                      },
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),
                    _NotifToggleRow(
                      iconName: 'qr-code',
                      title: s.nf2Title,
                      subtitle: s.nf2Sub,
                      value: _boarded,
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                      onChanged: (v) {
                        setState(() => _boarded = v);
                        _persist();
                      },
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),
                    _NotifToggleRow(
                      iconName: 'shield-check',
                      title: s.nf3Title,
                      subtitle: s.nf3Sub,
                      value: _arrived,
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                      onChanged: (v) {
                        setState(() => _arrived = v);
                        _persist();
                      },
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),
                    _NotifToggleRow(
                      iconName: 'clock',
                      title: s.nf4Title,
                      subtitle: s.nf4Sub,
                      value: _delays,
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                      onChanged: (v) {
                        setState(() => _delays = v);
                        _persist();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: Delivery Channels
              _SectionHeader(
                iconName: 'bell',
                title: s.nfSecChannels,
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
                    _NotifToggleRow(
                      iconName: 'bell',
                      title: s.nf5Title,
                      subtitle: s.nf5Sub,
                      value: _criticalSound,
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                      onChanged: (v) {
                        setState(() => _criticalSound = v);
                        _persist();
                      },
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),
                    _NotifToggleRow(
                      iconName: 'phone',
                      title: s.nf6Title,
                      subtitle: s.nf6Sub,
                      value: _smsBackup,
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                      onChanged: (v) {
                        setState(() => _smsBackup = v);
                        _persist();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifToggleRow extends StatelessWidget {
  const _NotifToggleRow({
    required this.iconName,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
    required this.onChanged,
  });

  final String iconName;
  final String title;
  final String subtitle;
  final bool value;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: value ? tokens.accent : tokens.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tokens.border, width: 1.0),
            ),
            child: Center(
              child: HannaIcon(iconName, size: 18, color: tokens.text),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
          Switch(
            value: value,
            activeThumbColor: tokens.onPrimary,
            activeTrackColor: tokens.actionPrimary,
            inactiveThumbColor: tokens.surface,
            inactiveTrackColor: tokens.border,
            onChanged: onChanged,
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
