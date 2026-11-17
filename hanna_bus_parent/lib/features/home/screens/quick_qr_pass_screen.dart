import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/motion/hanna_motion.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_badge.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_card.dart';
import '../../../core/widgets/hanna_header.dart';
import '../../../core/widgets/hanna_hero_card.dart';

class QuickQrPassScreen extends StatelessWidget {
  const QuickQrPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);
    final child = state.selectedChild;
    final snap = state.cachedQrPass;

    final name = child?.fullName ?? snap?.childName ?? 'Youssef Mansouri';
    final code = child?.studentCode ?? snap?.studentCode ?? 'HB-304';
    final bus = child?.busNumber ?? snap?.busNumber ?? '04';
    final stop = child?.stopName ?? snap?.stopName ?? 'Hydra North - Stop 04';
    final payload = snap?.qrPayload ?? 'HANNA-BUS|$code|BUS-$bus|$name';

    return Scaffold(
      body: HannaBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(HannaSpace.lg),
            child: HannaMotionEntrance(
              withScale: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HannaHeader(title: s.qrPassTitle, showBack: true),
                  const SizedBox(height: HannaSpace.md),
                  if (state.children.length > 1) ...[
                    Row(
                      children: state.children.map((c) {
                        final isSelected = c.id == (child?.id ?? state.children.first.id);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => state.selectChild(c.id),
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isSelected ? t.actionPrimary : t.surface,
                                  borderRadius: BorderRadius.circular(19),
                                  border: Border.all(
                                    color: isSelected ? t.actionPrimary : t.border,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${c.fullName.split(' ').first} · Bus ${c.busNumber}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? t.onPrimary : t.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: HannaSpace.md),
                  ],
                  HannaHeroCard(
                    padding: const EdgeInsets.all(HannaSpace.xl),
                    child: Column(
                      children: [
                        HannaBadge(
                          label: s.tr(
                            'Offline-Ready Gate Pass',
                            'بطاقة جاهزة دون اتصال',
                            'Pass valide hors ligne',
                          ),
                          icon: LucideIcons.shieldCheck,
                          tone: HannaBadgeTone.hero,
                        ),
                        const SizedBox(height: HannaSpace.md),
                        Text(
                          name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: t.onHero,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bus $bus · $stop',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: t.onHeroMuted,
                              ),
                        ),
                        const SizedBox(height: HannaSpace.lg),
                        // Fixed bright surface for reliable barcode camera contrast in dark/light mode.
                        Container(
                          padding: const EdgeInsets.all(HannaSpace.md),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(HannaRadius.lg),
                          ),
                          child: QrImageView(
                            data: payload,
                            size: 200,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Color(0xFF1C1A14),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Color(0xFF1C1A14),
                            ),
                          ),
                        ),
                        const SizedBox(height: HannaSpace.md),
                        Text(
                          code,
                          style: HannaTypography.mono(
                            size: 18,
                            weight: FontWeight.w700,
                            color: t.heroAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: HannaSpace.md),
                  HannaCard(
                    child: Row(
                      children: [
                        Icon(LucideIcons.badgeCheck, size: 20, color: t.link),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s.qrPassBody,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: t.textMuted,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: HannaSpace.lg),
                  HannaButton(
                    label: s.tr('Save pass for offline use', 'حفظ البطاقة للاستخدام دون إنترنت', 'Enregistrer pour usage hors ligne'),
                    icon: LucideIcons.wallet,
                    variant: HannaButtonVariant.primary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            s.tr(
                              'QR boarding pass cached securely on device for offline scanning.',
                              'تم حفظ بطاقة QR في الذاكرة المحلية بنجاح.',
                              'Pass QR enregistré localement sur l\'appareil.',
                            ),
                          ),
                          backgroundColor: t.actionPrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: HannaSpace.sm),
                  HannaButton(
                    label: s.tr('Share pass with co-guardian', 'مشاركة البطاقة مع ولي الأمر الثاني', 'Partager avec le co-tuteur'),
                    icon: LucideIcons.share2,
                    variant: HannaButtonVariant.secondary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            s.tr(
                              'Pass link copied to clipboard.',
                              'تم نسخ رابط البطاقة إلى الحافظة.',
                              'Lien du pass copié dans le presse-papiers.',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
