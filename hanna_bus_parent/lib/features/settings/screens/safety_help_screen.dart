import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_card.dart';
import '../../../core/widgets/hanna_header.dart';
import '../../home/screens/updates_support_screen.dart';
import 'terms_privacy_screen.dart';

class SafetyHelpScreen extends StatelessWidget {
  const SafetyHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);

    final rules = [
      (
        icon: LucideIcons.qrCode,
        title: s.tr('Always keep QR pass accessible', 'حافظ على بطاقة QR متاحة', 'Gardez le pass QR a portee'),
        body: s.tr(
          'Your parent handover QR code refreshes safely offline so school gates never stall.',
          'يعمل رمز التسليم QR محليا دون إنترنت لضمان سرعة التسليم عند البوابة.',
          'Votre pass QR fonctionne meme hors ligne au portail.',
        ),
      ),
      (
        icon: LucideIcons.clock,
        title: s.tr('Arrive 3 minutes before stop ETA', 'الوصول قبل موعد المحطة بـ 3 دقائق', 'Arrivez 3 min avant l heure'),
        body: s.tr(
          'Report any day off early before 06:45 AM so buses stay on schedule for every family.',
          'أبلغ عن الغياب قبل 06:45 صباحا ليلتزم السائق بموعد بقية العائلات.',
          'Signalez toute absence avant 06h45 pour fluidifier la tournee.',
        ),
      ),
      (
        icon: LucideIcons.shieldCheck,
        title: s.tr('Authorized dismissal verification', 'توثيق الاستلام المعتمد', 'Sortie verifiee uniquement'),
        body: s.tr(
          'Bus escorts only release children to listed guardians matching the student dossier.',
          'لا يتم تسليم الطالب إلا للأولياء المسجلين ضمن ملف الصلاحيات.',
          'Les accompagnateurs remettent l enfant uniquement aux tuteurs autorises.',
        ),
      ),
    ];

    return Scaffold(
      body: HannaBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(HannaSpace.lg),
            children: [
              HannaHeader(title: s.safetyHelpTitle, showBack: true),
              const SizedBox(height: HannaSpace.lg),
              ...rules.map((r) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: HannaSpace.sm),
                  child: HannaCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: t.surfaceSubtle,
                            borderRadius: BorderRadius.circular(HannaRadius.md),
                            border: Border.all(color: t.border),
                          ),
                          child: Icon(r.icon, size: 18, color: t.link),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.title, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                r.body,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: t.textMuted,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: HannaSpace.md),
              HannaButton(
                label: s.tr('Terms & Privacy Policy', 'الشروط وسياسة الخصوصية', 'Conditions & Confidentialite'),
                icon: LucideIcons.shieldCheck,
                variant: HannaButtonVariant.secondary,
                onPressed: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const TermsPrivacyScreen()),
                  );
                },
              ),
              const SizedBox(height: HannaSpace.sm),
              HannaButton(
                label: s.quickUpdates,
                icon: LucideIcons.messageCircle,
                onPressed: () {
                  Navigator.of(context).push(
                    HannaMotion.route(const UpdatesSupportScreen()),
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
