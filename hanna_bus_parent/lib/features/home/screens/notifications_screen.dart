import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_badge.dart';
import '../../../core/widgets/hanna_button.dart';
import '../../../core/widgets/hanna_card.dart';
import '../../../core/widgets/hanna_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);

    final filters = [
      (key: 'all', label: s.all),
      (key: 'boarding', label: s.tr('Boarding', 'الصعود', 'Montee')),
      (key: 'arrival', label: s.tr('Arrival', 'الوصول', 'Arrivee')),
      (key: 'delay', label: s.tr('Delays', 'التأخير', 'Retards')),
    ];

    final filtered = state.notifications
        .where((n) => _filter == 'all' || n.category == _filter)
        .toList();

    return Scaffold(
      body: HannaBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(HannaSpace.lg, HannaSpace.md, HannaSpace.lg, 0),
                child: HannaHeader(
                  title: s.alertsTitle,
                  showBack: true,
                  trailing: HannaButton(
                    label: s.markAllRead,
                    variant: HannaButtonVariant.secondary,
                    fullWidth: false,
                    compact: true,
                    onPressed: state.unreadNotificationsCount == 0
                        ? null
                        : state.markAllNotificationsRead,
                  ),
                ),
              ),
              const SizedBox(height: HannaSpace.sm),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: HannaSpace.lg),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, idx) {
                    final f = filters[idx];
                    return ChoiceChip(
                      label: Text(f.label),
                      selected: _filter == f.key,
                      onSelected: (_) => setState(() => _filter = f.key),
                      backgroundColor: t.surface,
                      selectedColor: t.heroSurface,
                      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _filter == f.key ? t.onHero : t.text,
                            fontWeight: FontWeight.w700,
                          ),
                      side: BorderSide(color: _filter == f.key ? t.heroSurface : t.border),
                    );
                  },
                ),
              ),
              const SizedBox(height: HannaSpace.sm),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          s.tr(
                            'No alerts in this category yet.',
                            'لا توجد تنبيهات في هذا التصنيف حاليا.',
                            'Aucune alerte dans cette categorie.',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: t.textMuted,
                              ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(HannaSpace.lg),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: HannaSpace.sm),
                        itemBuilder: (_, index) {
                          final item = filtered[index];
                          final IconData icon;
                          final HannaBadgeTone tone;
                          switch (item.category) {
                            case 'arrival':
                              icon = LucideIcons.shieldCheck;
                              tone = HannaBadgeTone.success;
                              break;
                            case 'delay':
                              icon = LucideIcons.clock;
                              tone = HannaBadgeTone.warning;
                              break;
                            default:
                              icon = LucideIcons.bus;
                              tone = HannaBadgeTone.accent;
                          }
                          return HannaCard(
                            onTap: () => state.markNotificationRead(item.id),
                            borderColor: item.isRead ? t.border : t.actionPrimary,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HannaBadge(label: item.dayGroup, icon: icon, tone: tone),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                          ),
                                          if (!item.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: t.actionPrimary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.body,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: t.textMuted,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.timeLabel,
                                        style: HannaTypography.mono(size: 12, color: t.titleSoft),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
