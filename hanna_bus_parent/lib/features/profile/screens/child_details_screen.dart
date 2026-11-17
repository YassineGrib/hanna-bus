import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/models.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';
import '../../tracking/screens/report_absence_screen.dart';

class ChildDetailsScreen extends StatelessWidget {
  const ChildDetailsScreen({super.key, this.child});
  final ChildProfile? child;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final locale = Localizations.localeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isArabic = HannaTypography.isArabicLocale(locale);
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

    final studentName = child?.fullName ?? (isArabic ? 'يوسف منصوري' : 'Youssef Mansouri');
    final studentSchool = child != null
        ? '${child!.schoolName} · ID #${child!.studentCode}'
        : s.cdSchoolDefault;
    final studentCode = child?.studentCode ?? 'HB-2026-9911';
    final studentBadge = child != null ? s.transitLabel(child!.transitStatus) : (isArabic ? 'في الحافلة' : 'On Bus');

    return Scaffold(
      backgroundColor: t.background,
      body: HannaBackground(
        variant: HannaBackgroundVariant.sweep,
        child: SafeArea(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              // Header with Back Button and Pencil
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
                          s.childDetailsTitle,
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
                    Material(
                      color: t.border,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.childDetailsTitle)),
                          );
                        },
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: Center(
                            child: HannaIcon('pencil-simple', size: 20, color: t.text),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Child Hero Card (357x88 in design)
              Container(
                constraints: const BoxConstraints(minHeight: 88),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: t.border, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: t.text.withValues(alpha: 0.04),
                      offset: const Offset(0, 4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: t.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: HannaIcon('graduation-cap', size: 28, color: t.text),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Directionality(
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: TextStyle(
                                  fontFamily: fontFam,
                                  fontFamilyFallback: fontFallbacks,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: t.text,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                studentSchool,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: TextStyle(
                                  fontFamily: fontFam,
                                  fontFamilyFallback: fontFallbacks,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: t.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: t.actionPrimary,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          studentBadge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            fontFamily: fontFam,
                            fontFamilyFallback: fontFallbacks,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: t.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Assigned Bus & Driver Section
              _SectionHeader(
                iconName: 'bus',
                title: s.cdSecBus,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 10),
              Container(
                height: 74,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: t.border, width: 1.0),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: t.accent.withValues(alpha: 0.40),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: HannaIcon('bus', size: 22, color: t.text),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child != null ? 'Bus ${child!.busNumber} · Morning & Return' : s.cdBusName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: fontFam,
                              fontFamilyFallback: fontFallbacks,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: t.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            child != null ? 'Driver: ${child!.driverName}' : s.cdBusSub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                    Material(
                      color: t.actionPrimary,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${s.urgentCallBtn}: Ahmed Benali')),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: HannaIcon('phone-call', size: 18, color: t.onPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Daily Stop Schedule Section
              _SectionHeader(
                iconName: 'clock',
                title: s.cdSecSched,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: t.border, width: 1.0),
                ),
                child: Column(
                  children: [
                    _ScheduleRow(
                      iconName: 'clock',
                      title: s.cdPickT,
                      timeSubtitle: s.cdPickS,
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                    ),
                    Divider(height: 1, thickness: 1, color: t.border),
                    _ScheduleRow(
                      iconName: 'clock',
                      title: s.cdDropT,
                      timeSubtitle: s.cdDropS,
                      fontFam: fontFam,
                      fontFallbacks: fontFallbacks,
                      tokens: t,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Digital Boarding Pass Section (357x190)
              _SectionHeader(
                iconName: 'qr-code',
                title: s.cdSecQr,
                fontFam: fontFam,
                fontFallbacks: fontFallbacks,
                tokens: t,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: t.border, width: 1.0),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: t.background,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: t.border, width: 1.0),
                      ),
                      child: Center(
                        child: QrImageView(
                          data: studentCode,
                          size: 88,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: t.text,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: t.text,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.cdQrTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: fontFam,
                        fontFamilyFallback: fontFallbacks,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: t.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.cdQrSub,
                      textAlign: TextAlign.center,
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
              const SizedBox(height: 28),

              // Report absence button
              HannaButton(
                label: s.cdBtnAbsence,
                leadIconName: 'info',
                variant: HannaButtonVariant.secondary,
                onPressed: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const ReportAbsenceScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
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

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.iconName,
    required this.title,
    required this.timeSubtitle,
    required this.fontFam,
    required this.fontFallbacks,
    required this.tokens,
  });

  final String iconName;
  final String title;
  final String timeSubtitle;
  final String fontFam;
  final List<String> fontFallbacks;
  final HannaTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tokens.background,
              borderRadius: BorderRadius.circular(10),
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
                  timeSubtitle,
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
        ],
      ),
    );
  }
}
