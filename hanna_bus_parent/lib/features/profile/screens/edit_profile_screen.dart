import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_icon.dart';
import '../../../core/widgets/hanna_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _backupCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _stopCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Default demo values if empty
    _nameCtrl = TextEditingController(text: 'Karim Mansouri');
    _phoneCtrl = TextEditingController(text: '+213 550 12 34 56');
    _backupCtrl = TextEditingController(text: '+213 551 98 76 54');
    _emailCtrl = TextEditingController(text: 'k.mansouri@mail.dz');
    _stopCtrl = TextEditingController(text: 'Hay El Nasr, Algiers');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = AppStateScope.of(context).currentUser;
    final isArabic = HannaTypography.isArabicLocale(Localizations.localeOf(context));
    if (user.name.isNotEmpty) _nameCtrl.text = user.name;
    if (user.phone.isNotEmpty) _phoneCtrl.text = user.phone;
    if (user.email.isNotEmpty) _emailCtrl.text = user.email;
    if (user.primaryBusStop.isNotEmpty) {
      _stopCtrl.text = user.primaryBusStop;
    } else {
      _stopCtrl.text = isArabic ? 'حي النصر، الجزائر' : 'Hay El Nasr, Algiers';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _backupCtrl.dispose();
    _emailCtrl.dispose();
    _stopCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final state = AppStateScope.of(context);
    await state.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      backupPhone: _backupCtrl.text.trim(),
      primaryBusStop: _stopCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.of(context).saveChanges),
      ),
    );
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
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
              // Top Bar Header with Circular Back Button
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
                        s.editProfileTitle,
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
              const SizedBox(height: 24),

              // Avatar edit center (88x88 in design)
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: t.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: t.actionPrimary, width: 2.0),
                          ),
                          child: Center(
                            child: HannaIcon('user', size: 36, color: t.text),
                          ),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: t.actionPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(color: t.surface, width: 2.0),
                            ),
                            child: Center(
                              child: HannaIcon('camera', size: 16, color: t.onPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.changePhoto)),
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text(
                          s.changePhoto,
                          style: TextStyle(
                            fontFamily: fontFam,
                            fontFamilyFallback: fontFallbacks,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: t.link,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fields: Full name, Phone, Emergency backup, Email, Stop picker
              HannaTextField(
                label: s.lblFullName,
                controller: _nameCtrl,
                prefixIconName: 'user',
              ),
              const SizedBox(height: 18),
              HannaTextField(
                label: s.lblPhone,
                controller: _phoneCtrl,
                prefixIconName: 'phone',
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 18),
              HannaTextField(
                label: s.lblBackupPhone,
                controller: _backupCtrl,
                prefixIconName: 'phone-call',
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 18),
              HannaTextField(
                label: s.lblEmail,
                controller: _emailCtrl,
                prefixIconName: 'envelope-simple',
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 18),
              HannaTextField(
                label: s.lblHomeStop,
                controller: _stopCtrl,
                prefixIconName: 'map-pin',
              ),
              const SizedBox(height: 32),

              // Save Button (58px tall, 18px radius)
              HannaButton(
                label: s.saveChanges,
                leadIconName: 'check',
                isLoading: _saving,
                onPressed: _save,
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
