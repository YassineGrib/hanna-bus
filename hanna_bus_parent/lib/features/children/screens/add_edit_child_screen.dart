import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/models.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_header.dart';
import '../../../core/widgets/hanna_text_field.dart';

class AddEditChildScreen extends StatefulWidget {
  const AddEditChildScreen({super.key, this.existingChild});
  final ChildProfile? existingChild;

  @override
  State<AddEditChildScreen> createState() => _AddEditChildScreenState();
}

class _AddEditChildScreenState extends State<AddEditChildScreen> {
  late bool _isNewChildMode;
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _busCtrl = TextEditingController();
  final _medCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final c = widget.existingChild;
    _isNewChildMode = c == null;
    if (c != null) {
      _codeCtrl.text = c.studentCode;
      _nameCtrl.text = c.fullName;
      _dobCtrl.text = '${c.birthDate} · Blood ${c.bloodType}';
      _schoolCtrl.text = '${c.schoolName} · ${c.grade}';
      _busCtrl.text = 'Bus ${c.busNumber} · ${c.stopName}';
      _medCtrl.text = c.allergies.isNotEmpty ? c.allergies : 'No Medical Alerts';
    } else {
      _codeCtrl.text = '';
      _nameCtrl.text = 'Youssef Karim Mansouri';
      _dobCtrl.text = '14 Mar 2018 · Blood O+';
      _schoolCtrl.text = 'El Wiam Primary · Grade 3';
      _busCtrl.text = 'Bus 04 · Hay El Nasr Stop';
      _medCtrl.text = 'Asthma Inhaler (Front Pocket)';
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _schoolCtrl.dispose();
    _busCtrl.dispose();
    _medCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLinkCode() async {
    final s = AppStrings.of(context);
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() {
        _error = s.tr(
          'Please enter the student code.',
          'يرجى إدخال رمز الطالب.',
          'Veuillez entrer le code élève.',
        );
      });
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    await AppStateScope.of(context).linkChildByCode(studentCode: code);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).maybePop();
  }

  Future<void> _handleSave() async {
    final s = AppStrings.of(context);
    if (_codeCtrl.text.trim().isNotEmpty && _isNewChildMode && widget.existingChild == null) {
      await _handleLinkCode();
      return;
    }

    if (_nameCtrl.text.trim().length < 2) {
      setState(() {
        _error = s.tr(
          'Please enter a valid student name.',
          'يرجى إدخال اسم الطالب كاملاً.',
          'Veuillez entrer un nom valide.',
        );
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final busMatch = RegExp(r'Bus\s*(\d+)').firstMatch(_busCtrl.text);
    final busNum = busMatch?.group(1) ?? '04';

    await AppStateScope.of(context).saveChild(
      existingId: widget.existingChild?.id,
      fullName: _nameCtrl.text.trim(),
      studentCode: _codeCtrl.text.trim().isNotEmpty ? _codeCtrl.text.trim() : 'HB-304',
      schoolName: _schoolCtrl.text.trim(),
      grade: _schoolCtrl.text.contains('·') ? _schoolCtrl.text.split('·').last.trim() : 'Grade 3',
      busNumber: busNum,
      stopName: _busCtrl.text.contains('·') ? _busCtrl.text.split('·').last.trim() : _busCtrl.text.trim(),
      allergies: _medCtrl.text.trim(),
      dismissalRule: widget.existingChild?.dismissalRule ?? 'Authorized Parent QR Only',
    );

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);

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
                title: s.chAeTitle,
                showBack: true,
              ),
              const SizedBox(height: HannaSpace.md),

              // Mode segmented pill (y=116 in FigCraft)
              Container(
                height: 38,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: t.border),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNewChildMode = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: !_isNewChildMode ? t.actionPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            s.chAeModeEdit,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: !_isNewChildMode ? FontWeight.w700 : FontWeight.w600,
                              color: !_isNewChildMode ? t.onPrimary : t.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNewChildMode = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: _isNewChildMode ? t.actionPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            s.chAeModeAdd,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _isNewChildMode ? FontWeight.w700 : FontWeight.w600,
                              color: _isNewChildMode ? t.onPrimary : t.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HannaSpace.md),

              // Student Code Field (shown in New Child mode or top)
              if (_isNewChildMode) ...[
                HannaTextField(
                  controller: _codeCtrl,
                  label: s.tr('School Student Code (e.g. HB-2026-9911)', 'رمز الطالب (مثال: HB-2026-9911)', 'Code élève (ex. HB-2026-9911)'),
                  hintText: 'HB-2026-9911',
                  prefixIcon: LucideIcons.qrCode,
                ),
                const SizedBox(height: 8),
                HannaButton(
                  label: s.tr('Link Child Now', 'ربط التلميذ الآن', 'Lier l\'élève maintenant'),
                  icon: LucideIcons.link,
                  variant: HannaButtonVariant.heroAccent,
                  isLoading: _saving,
                  onPressed: _handleLinkCode,
                ),
                const SizedBox(height: HannaSpace.md),
              ],

              // Photo avatar uploader row (y=164 in FigCraft)
              Container(
                height: 68,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: t.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: t.heroAccent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Icon(LucideIcons.camera, size: 22, color: t.text),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        s.chAePhotoLbl,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: t.link,
                        ),
                      ),
                    ),
                    Icon(
                      s.isArabic ? LucideIcons.chevronLeft : LucideIcons.chevronRight,
                      size: 20,
                      color: t.textMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HannaSpace.md),

              // 5 Structured Form Fields (y=244..596 in FigCraft)
              HannaTextField(
                controller: _nameCtrl,
                label: s.chAeLblName,
                hintText: s.chAeLblName,
                prefixIcon: LucideIcons.user,
              ),
              const SizedBox(height: 12),

              HannaTextField(
                controller: _dobCtrl,
                label: s.chAeLblDob,
                hintText: s.chAeLblDob,
                prefixIcon: LucideIcons.calendar,
              ),
              const SizedBox(height: 12),

              HannaTextField(
                controller: _schoolCtrl,
                label: s.chAeLblSch,
                hintText: s.chAeLblSch,
                prefixIcon: LucideIcons.graduationCap,
              ),
              const SizedBox(height: 12),

              HannaTextField(
                controller: _busCtrl,
                label: s.chAeLblBus,
                hintText: s.chAeLblBus,
                prefixIcon: LucideIcons.bus,
              ),
              const SizedBox(height: 12),

              HannaTextField(
                controller: _medCtrl,
                label: s.chAeLblMed,
                hintText: s.chAeLblMed,
                prefixIcon: LucideIcons.heartPulse,
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: t.actionDestructive, fontSize: 13),
                ),
              ],

              const SizedBox(height: HannaSpace.lg),

              // Save CTA Button (y=742 in FigCraft)
              HannaButton(
                label: s.chAeSave,
                icon: LucideIcons.check,
                isLoading: _saving,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
