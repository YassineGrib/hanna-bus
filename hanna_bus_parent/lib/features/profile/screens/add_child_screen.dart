import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';
import '../../../core/widgets/hanna_text_field.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _nameCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _routeCtrl = TextEditingController();
  bool _linking = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = AppStrings.of(context);
    if (_schoolCtrl.text.isEmpty) _schoolCtrl.text = s.valSchoolGradeDefault;
    if (_routeCtrl.text.isEmpty) _routeCtrl.text = s.valBusRouteDefault;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    _codeCtrl.dispose();
    _routeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = AppStrings.of(context);
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = s.lblStudentName);
      return;
    }
    setState(() {
      _linking = true;
      _error = null;
    });

    final state = AppStateScope.of(context);
    final code = _codeCtrl.text.trim().isNotEmpty ? _codeCtrl.text.trim() : 'HB-2026-9911';
    await state.linkChildByCode(
      studentCode: code,
      fullName: _nameCtrl.text.trim(),
      schoolName: _schoolCtrl.text.trim(),
      busNumber: _routeCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _linking = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.linkChildBtn)),
    );
    Navigator.of(context).pop();
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
                    Text(
                      s.addChildTitle,
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
              ),
              const SizedBox(height: 14),

              // Subtitle
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 325),
                  child: Text(
                    s.addChildSub,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontFam,
                      fontFamilyFallback: fontFallbacks,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: t.textMuted,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Child photo uploader (76x76 circle)
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: t.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.border, width: 2.0),
                  ),
                  child: Center(
                    child: HannaIcon('camera', size: 28, color: t.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form fields
              HannaTextField(
                label: s.lblStudentName,
                hintText: s.phStudentName,
                controller: _nameCtrl,
                prefixIconName: 'user',
                errorText: _error,
              ),
              const SizedBox(height: 18),
              HannaTextField(
                label: s.lblSchoolGrade,
                controller: _schoolCtrl,
                prefixIconName: 'graduation-cap',
              ),
              const SizedBox(height: 18),
              HannaTextField(
                label: s.lblStudentId,
                hintText: s.phStudentId,
                controller: _codeCtrl,
                prefixIconName: 'qr-code',
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 18),
              HannaTextField(
                label: s.lblBusRoute,
                controller: _routeCtrl,
                prefixIconName: 'bus',
              ),
              const SizedBox(height: 32),

              // Link Child Action Button
              HannaButton(
                label: s.linkChildBtn,
                leadIconName: 'plus',
                isLoading: _linking,
                onPressed: _submit,
                variant: HannaButtonVariant.primary,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
