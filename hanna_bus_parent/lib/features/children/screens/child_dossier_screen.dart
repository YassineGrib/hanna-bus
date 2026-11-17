import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/models.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_header.dart';
import '../../home/screens/quick_qr_pass_screen.dart';
import 'add_edit_child_screen.dart';
import 'manage_child_screen.dart';

class ChildDossierScreen extends StatefulWidget {
  const ChildDossierScreen({
    super.key,
    required this.childId,
    this.onOpenTrack,
  });

  final String childId;
  final VoidCallback? onOpenTrack;

  @override
  State<ChildDossierScreen> createState() => _ChildDossierScreenState();
}

class _ChildDossierScreenState extends State<ChildDossierScreen> {
  int _activeTab = 0; // 0: Personal, 1: Educative, 2: Medical, 3: Schedule
  int _selectedDayIndex = 0; // 0..4 (Sun..Thu)

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);

    final child = state.children.firstWhere(
      (c) => c.id == widget.childId,
      orElse: () => state.selectedChild ?? state.children.first,
    );

    final (headerTitle, headerIcon) = switch (_activeTab) {
      1 => (s.chEdTitle, LucideIcons.school),
      2 => (s.chMdTitle, LucideIcons.heartPulse),
      3 => (s.chTmTitle, LucideIcons.calendar),
      _ => (s.chDpTitle, LucideIcons.pencil),
    };

    return Scaffold(
      body: HannaBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              HannaSpace.lg,
              HannaSpace.md,
              HannaSpace.lg,
              HannaSpace.pageBottomPad,
            ),
            children: [
              // Header with back button and active tab icon action
              HannaHeader(
                title: headerTitle,
                showBack: true,
                trailing: GestureDetector(
                  onTap: () {
                    if (_activeTab == 0) {
                      Navigator.of(context).push(
                        HannaMotion.route(AddEditChildScreen(existingChild: child)),
                      );
                    } else {
                      Navigator.of(context).push(
                        HannaMotion.route(ManageChildScreen(childId: child.id)),
                      );
                    }
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.border),
                    ),
                    child: Center(
                      child: Icon(headerIcon, size: 18, color: t.text),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: HannaSpace.md),

              // Shared Child Mini Header (y=114 in FigCraft)
              _ChildMiniHeader(
                child: child,
                activeTab: _activeTab,
                onTabChanged: (idx) => setState(() => _activeTab = idx),
              ),
              const SizedBox(height: HannaSpace.md),

              // Active Tab Content
              switch (_activeTab) {
                1 => _buildEducativeTab(context, s, t, child),
                2 => _buildMedicalTab(context, s, t, child),
                3 => _buildScheduleTab(context, s, t, child),
                _ => _buildPersonalTab(context, s, t, child),
              },
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 0: PERSONAL & QR PASS (Screen 3)
  // ==========================================
  Widget _buildPersonalTab(
    BuildContext context,
    AppStrings s,
    HannaTokens t,
    ChildProfile child,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Student ID & QR Boarding Pass Card (y=232 in FigCraft)
        Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: t.border),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 6),
                blurRadius: 18,
                color: t.text.withValues(alpha: 0.07),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 96x96 QR Box
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        HannaMotion.route(const QuickQrPassScreen()),
                      );
                    },
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: t.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.border),
                      ),
                      child: Center(
                        child: Icon(LucideIcons.qrCode, size: 68, color: t.text),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${child.grade} · ${child.schoolName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: t.textMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Pass bus pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: t.heroAccent.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.bus, size: 15, color: t.text),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Bus ${child.busNumber} · Seat ${child.seatNumber}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: t.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                s.chDpQrSub,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: t.link,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: HannaSpace.lg),

        // 2. Personal & Guardian Info Card (y=408 in FigCraft)
        _SectionLabel(icon: LucideIcons.users, label: s.chDpSecPers),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _DossierRow(
                icon: LucideIcons.user,
                label: s.chDpR1K,
                value: child.fullName,
              ),
              _rowDivider(t),
              _DossierRow(
                icon: LucideIcons.calendar,
                label: s.chDpR2K,
                value: '${child.birthDate} (8 yrs)',
              ),
              _rowDivider(t),
              _DossierRow(
                icon: LucideIcons.contact,
                label: s.chDpR3K,
                value: '#${child.studentCode} · Nat ID ${child.nationalId}',
                isMono: true,
              ),
              _rowDivider(t),
              _DossierRow(
                icon: LucideIcons.users,
                label: s.chDpR4K,
                value: s.isArabic ? 'كريم م. (الأب) · سارة م. (الأم)' : 'Karim M. & Sara M.',
              ),
              _rowDivider(t),
              _DossierRow(
                icon: LucideIcons.mapPin,
                label: s.chDpR5K,
                value: child.stopName,
              ),
            ],
          ),
        ),
        const SizedBox(height: HannaSpace.lg),

        // CTA: Edit Personal Details
        HannaButton(
          label: s.chDpEditBtn,
          icon: LucideIcons.pencil,
          variant: HannaButtonVariant.secondary,
          onPressed: () {
            Navigator.of(context).push(
              HannaMotion.route(AddEditChildScreen(existingChild: child)),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: EDUCATIVE INFO (Screen 4)
  // ==========================================
  Widget _buildEducativeTab(
    BuildContext context,
    AppStrings s,
    HannaTokens t,
    ChildProfile child,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. School & Classroom Card (y=232 in FigCraft)
        _SectionLabel(icon: LucideIcons.school, label: s.chEdSecSch),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _DossierRow(
                icon: LucideIcons.building2,
                label: s.chEdR1K,
                value: child.schoolName,
              ),
              _rowDivider(t),
              _DossierRow(
                icon: LucideIcons.graduationCap,
                label: s.chEdR2K,
                value: '${child.grade} · ${child.classRoom}',
              ),
              _rowDivider(t),
              _DossierRow(
                icon: LucideIcons.bookOpen,
                label: s.chEdR3K,
                value: child.homeroomTeacher,
              ),
              _rowDivider(t),
              _DossierRow(
                icon: LucideIcons.phone,
                label: s.chEdR4K,
                value: child.transportCoordinator,
              ),
            ],
          ),
        ),
        const SizedBox(height: HannaSpace.lg),

        // 2. Transport & Gate Rules (y=496 in FigCraft)
        _SectionLabel(icon: LucideIcons.shieldCheck, label: s.chEdSecTr),
        const SizedBox(height: 8),
        _RuleCard(
          icon: LucideIcons.bus,
          iconBg: t.heroAccent,
          title: s.chEdT1T,
          subtitle: 'Assigned Seat ${child.seatNumber} (${s.isArabic ? "الصف الأمامي" : "Front Row"})',
        ),
        const SizedBox(height: 10),
        _RuleCard(
          icon: LucideIcons.mapPin,
          iconBg: t.surfaceSubtle,
          title: s.chEdT2T,
          subtitle: s.chEdT2S,
        ),
        const SizedBox(height: 10),
        _RuleCard(
          icon: LucideIcons.shieldCheck,
          iconBg: t.heroAccent.withValues(alpha: 0.45),
          title: s.chEdT3T,
          subtitle: '${child.dismissalRule} · ${s.chEdT3S}',
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: MEDICAL INFO (Screen 5)
  // ==========================================
  Widget _buildMedicalTab(
    BuildContext context,
    AppStrings s,
    HannaTokens t,
    ChildProfile child,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Blood Type & Insurance Row (y=230 in FigCraft)
        Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: t.destructiveSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: t.destructiveBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(LucideIcons.heartPulse, size: 20, color: t.actionDestructive),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${s.isArabic ? "فصيلة الدم:" : "Blood Type:"} ${child.bloodType}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: t.actionDestructive,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: t.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(LucideIcons.shieldCheck, size: 20, color: t.text),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        child.insuranceNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
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
        const SizedBox(height: HannaSpace.lg),

        // 2. Allergies & Conditions (y=288 in FigCraft)
        _SectionLabel(icon: LucideIcons.alertCircle, label: s.chMdSecCond),
        const SizedBox(height: 8),
        _ConditionCard(
          icon: LucideIcons.alertCircle,
          iconBg: t.actionDestructive,
          iconFg: Colors.white,
          cardBg: t.destructiveSurface,
          cardBorder: t.destructiveBorder,
          title: child.allergies.isNotEmpty ? child.allergies : s.chMdC1T,
          subtitle: s.chMdC1S,
        ),
        const SizedBox(height: 10),
        _ConditionCard(
          icon: LucideIcons.checkCircle2,
          iconBg: t.heroAccent,
          iconFg: t.text,
          cardBg: t.surface,
          cardBorder: t.border,
          title: s.chMdC2T,
          subtitle: s.chMdC2S,
        ),
        const SizedBox(height: HannaSpace.lg),

        // 3. Driver & First-Aid Protocol (y=484 in FigCraft)
        _SectionLabel(icon: LucideIcons.heartPulse, label: s.chMdSecProt),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            child.firstAidProtocol.isNotEmpty ? child.firstAidProtocol : s.chMdProtB,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: t.text,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: HannaSpace.lg),

        // 4. Authorized Pediatrician Card (y=616 in FigCraft)
        _SectionLabel(icon: LucideIcons.stethoscope, label: s.chMdSecDoc),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: t.heroAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(LucideIcons.stethoscope, size: 22, color: t.text),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.pediatricianName.isNotEmpty ? child.pediatricianName : s.chMdDocT,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: t.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      child.pediatricianPhone.isNotEmpty ? '${child.schoolName} Clinic · ${child.pediatricianPhone}' : s.chMdDocS,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: t.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Call action button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${child.pediatricianName}...')),
                  );
                },
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: t.actionPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    s.chMdCallBtn,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: t.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: HannaSpace.lg),

        // Update medical record CTA
        HannaButton(
          label: s.chMdUpdBtn,
          icon: LucideIcons.pencil,
          variant: HannaButtonVariant.secondary,
          onPressed: () {
            Navigator.of(context).push(
              HannaMotion.route(AddEditChildScreen(existingChild: child)),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: SCHEDULE / TIME PROGRAMME (Screen 6)
  // ==========================================
  Widget _buildScheduleTab(
    BuildContext context,
    AppStrings s,
    HannaTokens t,
    ChildProfile child,
  ) {
    final days = [
      s.chDSun,
      s.chDMon,
      s.chDTue,
      s.chDWed,
      s.chDThu,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. 5 Day Selector Pills (y=230 in FigCraft)
        Row(
          children: List.generate(days.length, (idx) {
            final isAct = idx == _selectedDayIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = idx),
                child: Container(
                  margin: EdgeInsets.only(right: idx < days.length - 1 ? 6 : 0),
                  height: 36,
                  decoration: BoxDecoration(
                    color: isAct ? t.actionPrimary : t.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAct ? t.actionPrimary : t.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    days[idx],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isAct ? FontWeight.w700 : FontWeight.w600,
                      color: isAct ? t.onPrimary : t.text,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: HannaSpace.lg),

        // 2. Morning Ride · To School (y=280 in FigCraft)
        _SectionLabel(icon: LucideIcons.bus, label: s.chTmSecAm),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _TimelineStepRow(
                icon: LucideIcons.bus,
                iconBg: t.surfaceSubtle,
                iconFg: t.text,
                title: '07:05 AM · Bus ${child.busNumber} Departs',
                subtitle: s.chTm1S,
              ),
              _rowDivider(t),
              _TimelineStepRow(
                icon: LucideIcons.mapPin,
                iconBg: t.heroAccent,
                iconFg: t.text,
                title: '${child.stopTime} AM · Home Pickup',
                subtitle: '${child.stopName} · ${s.isArabic ? "مسح رمز QR" : "QR Check-in"}',
              ),
              _rowDivider(t),
              _TimelineStepRow(
                icon: LucideIcons.school,
                iconBg: t.actionPrimary,
                iconFg: t.onPrimary,
                title: '07:40 AM · School Arrival',
                subtitle: '${child.schoolName} · ${s.isArabic ? "البوابة الشرقية" : "East Gate"}',
              ),
            ],
          ),
        ),
        const SizedBox(height: HannaSpace.lg),

        // 3. School Hours Band (y=490 in FigCraft)
        _SectionLabel(icon: LucideIcons.bookOpen, label: s.chTmSecSch),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: t.heroAccent.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(LucideIcons.bookOpen, size: 16, color: t.text),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.chTm4T,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: t.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.chTm4S,
                      style: TextStyle(
                        fontSize: 11,
                        color: t.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: HannaSpace.lg),

        // 4. Afternoon Ride · Return Home (y=582 in FigCraft)
        _SectionLabel(icon: LucideIcons.bus, label: s.chTmSecPm),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _TimelineStepRow(
                icon: LucideIcons.qrCode,
                iconBg: t.heroAccent,
                iconFg: t.text,
                title: '${child.returnTime} · School Boarding',
                subtitle: 'Bus ${child.busNumber} · East Gate QR Check-in',
              ),
              _rowDivider(t),
              _TimelineStepRow(
                icon: LucideIcons.checkCircle2,
                iconBg: t.actionPrimary,
                iconFg: t.onPrimary,
                title: '03:45 PM · Home Drop-off',
                subtitle: '${child.stopName} · Guardian handoff',
              ),
            ],
          ),
        ),
        const SizedBox(height: HannaSpace.lg),

        // Request schedule change CTA
        HannaButton(
          label: s.chTmBtn,
          icon: LucideIcons.clock,
          variant: HannaButtonVariant.secondary,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.tr('Schedule change request submitted.', 'تم إرسال طلب تعديل المواعيد.', 'Demande envoyée.'))),
            );
          },
        ),
      ],
    );
  }

  Widget _rowDivider(HannaTokens t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(height: 1, color: t.border),
    );
  }
}

// ==========================================
// SHARED CHILD MINI HEADER (y=114..218)
// ==========================================
class _ChildMiniHeader extends StatelessWidget {
  const _ChildMiniHeader({
    required this.child,
    required this.activeTab,
    required this.onTabChanged,
  });

  final ChildProfile child;
  final int activeTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final s = AppStrings.of(context);

    final tabs = [
      s.chTabPers,
      s.chTabEdu,
      s.chTabMed,
      s.chTabTime,
    ];

    return Column(
      children: [
        // Compact child banner (y=114, h=56 in FigCraft)
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: t.heroAccent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Icon(LucideIcons.graduationCap, size: 18, color: t.text),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      child.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: t.text,
                      ),
                    ),
                    Text(
                      'Bus ${child.busNumber} · Seat ${child.seatNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: t.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: t.actionPrimary,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Text(
                  s.transitLabel(child.transitStatus),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: t.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 4-Tab Bar (y=178, h=40 in FigCraft)
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.border),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(tabs.length, (idx) {
              final isAct = idx == activeTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isAct ? t.actionPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tabs[idx],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isAct ? FontWeight.w700 : FontWeight.w600,
                        color: isAct ? t.onPrimary : t.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// HELPER WIDGETS
// ==========================================
class _DossierRow extends StatelessWidget {
  const _DossierRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMono = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isMono;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: t.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: t.border),
          ),
          child: Center(
            child: Icon(icon, size: 16, color: t.text),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: t.textMuted,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isMono
                ? HannaTypography.mono(size: 13, color: t.text)
                : TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                  ),
          ),
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.border),
            ),
            child: Center(
              child: Icon(icon, size: 22, color: t.text),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.textMuted,
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

class _ConditionCard extends StatelessWidget {
  const _ConditionCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.cardBg,
    required this.cardBorder,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final Color cardBg;
  final Color cardBorder;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(icon, size: 22, color: iconFg),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.textMuted,
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

class _TimelineStepRow extends StatelessWidget {
  const _TimelineStepRow({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: t.border),
          ),
          child: Center(
            child: Icon(icon, size: 16, color: iconFg),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: t.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: t.text),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
          ),
        ),
      ],
    );
  }
}
