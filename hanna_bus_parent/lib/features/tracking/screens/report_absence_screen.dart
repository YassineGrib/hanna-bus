import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_badge.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_card.dart';
import '../../../core/widgets/hanna_header.dart';
import '../../../core/widgets/hanna_picker_sheet.dart';
import '../../../core/widgets/hanna_text_field.dart';

class ReportAbsenceScreen extends StatefulWidget {
  const ReportAbsenceScreen({super.key});

  @override
  State<ReportAbsenceScreen> createState() => _ReportAbsenceScreenState();
}

class _ReportAbsenceScreenState extends State<ReportAbsenceScreen> {
  String? _childId;
  String _selectedReason = 'Illness';
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _childId ??= AppStateScope.of(context).selectedChild?.id;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitAbsence(AppStateController state, String id) async {
    final s = AppStrings.of(context);
    setState(() => _saving = true);
    final customNote = _noteCtrl.text.trim();
    final reason = customNote.isNotEmpty ? '$_selectedReason: $customNote' : _selectedReason;
    await state.reportAbsence(id, reason: reason);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s.tr(
            'Absence notice confirmed for today.',
            'تم تأكيد بلاغ الغياب لليوم.',
            'Absence confirmee pour aujourd hui.',
          ),
        ),
      ),
    );
    Navigator.of(context).maybePop();
  }

  Future<void> _resumeRide(AppStateController state, String id) async {
    setState(() => _saving = true);
    await state.resumeRideToday(id);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final children = state.children;
    final targetChild = children.firstWhere(
      (c) => c.id == _childId,
      orElse: () => children.first,
    );

    final reasons = [
      'Illness',
      'Family Travel',
      'Medical Appointment',
      'Parent Pickup',
    ];

    return Scaffold(
      body: HannaBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(HannaSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HannaHeader(title: s.quickReportAbsence, showBack: true),
                const SizedBox(height: HannaSpace.lg),
                if (children.isNotEmpty) ...[
                  HannaPickerSheet<String>(
                    label: s.tr('Select Child', 'اختر الابن', 'Selectionner l enfant'),
                    value: targetChild.id,
                    leadingIcon: LucideIcons.user,
                    options: children
                        .map((c) => HannaPickerOption(
                              value: c.id,
                              label: c.fullName,
                              subtitle: 'Bus ${c.busNumber} · ${c.stopName}',
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _childId = val),
                  ),
                  const SizedBox(height: HannaSpace.md),
                ],
                HannaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HannaBadge(
                        label: s.transitLabel(targetChild.transitStatus),
                        tone: targetChild.isAbsentToday
                            ? HannaBadgeTone.destructive
                            : HannaBadgeTone.neutral,
                      ),
                      const SizedBox(height: HannaSpace.md),
                      Text(
                        s.tr('Reason', 'سبب الغياب', 'Motif'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: HannaSpace.xs),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: reasons.map((r) {
                          final selected = _selectedReason == r;
                          return ChoiceChip(
                            label: Text(r),
                            selected: selected,
                            onSelected: (_) => setState(() => _selectedReason = r),
                            backgroundColor: t.surfaceSubtle,
                            selectedColor: t.heroSurface,
                            labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: selected ? t.onHero : t.text,
                                  fontWeight: FontWeight.w700,
                                ),
                            side: BorderSide(color: selected ? t.heroSurface : t.border),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: HannaSpace.md),
                      HannaTextField(
                        label: s.tr('Optional Note for Driver', 'ملاحظة للسائق', 'Note pour le chauffeur'),
                        controller: _noteCtrl,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: HannaSpace.lg),
                if (targetChild.isAbsentToday)
                  HannaButton(
                    label: s.cancelAbsenceAction,
                    icon: LucideIcons.circleCheck,
                    isLoading: _saving,
                    onPressed: () => _resumeRide(state, targetChild.id),
                  )
                else
                  HannaButton(
                    label: s.confirmAbsenceAction,
                    icon: LucideIcons.calendar,
                    variant: HannaButtonVariant.destructive,
                    isLoading: _saving,
                    onPressed: () => _submitAbsence(state, targetChild.id),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
