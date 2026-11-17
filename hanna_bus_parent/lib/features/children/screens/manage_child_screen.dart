import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/models.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_header.dart';
import '../../../core/widgets/hanna_picker_sheet.dart';

class ManageChildScreen extends StatefulWidget {
  const ManageChildScreen({super.key, required this.childId});
  final String childId;

  @override
  State<ManageChildScreen> createState() => _ManageChildScreenState();
}

class _ManageChildScreenState extends State<ManageChildScreen> {
  final TextEditingController _confirmCodeCtrl = TextEditingController();
  bool _absentPaused = false;

  @override
  void dispose() {
    _confirmCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);

    final matches = state.children.where((c) => c.id == widget.childId).toList();
    if (matches.isEmpty) {
      return Scaffold(
        body: HannaBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(HannaSpace.lg),
              child: HannaHeader(title: s.chDmTitle, showBack: true),
            ),
          ),
        ),
      );
    }
    final child = matches.first;
    if (_confirmCodeCtrl.text.isEmpty) {
      _confirmCodeCtrl.text = child.studentCode;
    }

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
              HannaHeader(
                title: s.chDmTitle,
                subtitle: child.fullName,
                showBack: true,
              ),
              const SizedBox(height: HannaSpace.md),

              // Bus Assignment Picker
              Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: t.border),
                ),
                padding: const EdgeInsets.all(14),
                child: HannaPickerSheet<String>(
                  label: s.tr('Assigned Bus Route', 'تعيين خط الحافلة', 'Bus assigné'),
                  value: child.busNumber,
                  leadingIcon: LucideIcons.bus,
                  options: const [
                    HannaPickerOption(value: '04', label: 'Bus 04 - Hydra North'),
                    HannaPickerOption(value: '02', label: 'Bus 02 - El Biar'),
                  ],
                  onChanged: (val) async {
                    await state.saveChild(
                      existingId: child.id,
                      fullName: child.fullName,
                      studentCode: child.studentCode,
                      schoolName: child.schoolName,
                      grade: child.grade,
                      busNumber: val,
                      stopName: child.stopName,
                      allergies: child.allergies,
                      dismissalRule: child.dismissalRule,
                    );
                  },
                ),
              ),
              const SizedBox(height: HannaSpace.lg),

              // 1. Temporary Absence Card (y=120..330 in FigCraft)
              _SectionLabel(
                icon: LucideIcons.calendar,
                label: s.chDmSecAbs,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: t.border),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      color: t.text.withValues(alpha: 0.05),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: t.heroAccent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(LucideIcons.calendar, size: 22, color: t.text),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s.chDmAbsT,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.isArabic
                          ? 'سيتم إشعار سائق الحافلة ${child.busNumber} بعدم ركوب ${child.fullName} اليوم، ويُستأنف الجدول تلقائيًا غدًا.'
                          : 'Notify Bus ${child.busNumber} driver that ${child.fullName} will not ride today. Schedule resumes tomorrow.',
                      style: TextStyle(
                        fontSize: 12,
                        color: t.textMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HannaButton(
                      label: _absentPaused
                          ? s.tr('Absence Reported Today', 'تم تسجيل الغياب لليوم', 'Absence enregistrée')
                          : s.chDmAbsBtn,
                      icon: _absentPaused ? LucideIcons.check : LucideIcons.calendar,
                      onPressed: () {
                        setState(() => _absentPaused = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              s.tr(
                                'Ride paused today for ${child.fullName}. Driver notified.',
                                'تم إيقاف رحلة اليوم لـ ${child.fullName} وإشعار السائق.',
                                'Trajet suspendu aujourd\'hui pour ${child.fullName}.',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HannaSpace.xl),

              // 2. Permanent Delete Child Card (y=362..740 in FigCraft)
              _SectionLabel(
                icon: LucideIcons.trash2,
                label: s.chDmSecDel,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: t.destructiveSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: t.destructiveBorder),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                      color: t.text.withValues(alpha: 0.08),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: t.actionDestructive,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.trash2, size: 24, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s.chDmDelT,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: t.actionDestructive,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.isArabic
                          ? 'يؤدي حذف ملف ${child.fullName} (#${child.studentCode}) إلى إلغاء بطاقة الصعود الرقمية QR وإيقاف كافة تنبيهات المسار.'
                          : 'Removing ${child.fullName} (#${child.studentCode}) revokes digital QR boarding pass and stops all live GPS alerts.',
                      style: TextStyle(
                        fontSize: 12,
                        color: t.textMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.chDmDelLbl,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: t.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: t.actionDestructive),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _confirmCodeCtrl,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: t.actionDestructive,
                          fontFamily: 'monospace',
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Destructive Delete CTA
                    HannaButton(
                      label: s.tr('Unlink Child', 'حذف ملف الطفل نهائيًا', 'Retirer l\'enfant'),
                      icon: LucideIcons.trash2,
                      variant: HannaButtonVariant.destructive,
                      onPressed: () => _confirmDelete(state, child, s, t),
                    ),
                    const SizedBox(height: 10),

                    // Keep Profile CTA
                    HannaButton(
                      label: s.chDmCancel,
                      variant: HannaButtonVariant.secondary,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    AppStateController state,
    ChildProfile child,
    AppStrings s,
    HannaTokens t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text(s.tr('Confirm Unlink', 'تأكيد الحذف', 'Confirmer le retrait')),
        content: Text(
          s.tr(
            'Are you sure you want to remove ${child.fullName} from your parent dashboard?',
            'هل أنت متأكد من حذف ${child.fullName} من لوحة ولي الأمر؟',
            'Voulez-vous retirer ${child.fullName} de votre tableau de bord ?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.tr('Cancel', 'إلغاء', 'Annuler')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: t.actionDestructive,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(s.tr('Confirm', 'تأكيد', 'Confirmer')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final nav = Navigator.of(context);
      await state.removeChild(child.id);
      if (mounted) {
        nav.maybePop();
      }
    }
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
