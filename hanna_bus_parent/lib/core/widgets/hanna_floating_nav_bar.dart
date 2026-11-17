import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../l10n/app_strings.dart';
import '../motion/hanna_motion.dart';
import '../theme/hanna_tokens.dart';

class HannaFloatingNavBar extends StatelessWidget {
  const HannaFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.strings,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final duration = HannaMotion.effectiveDuration(context, HannaMotion.durationControl);

    final items = [
      (icon: LucideIcons.house, label: strings.navHome),
      (icon: LucideIcons.mapPin, label: strings.navTrack),
      (icon: LucideIcons.users, label: strings.navChildren),
      (icon: LucideIcons.user, label: strings.navProfile),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(HannaSpace.md, 0, HannaSpace.md, HannaSpace.sm),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: t.heroSurface,
            borderRadius: BorderRadius.circular(HannaRadius.pill),
            border: Border.all(
              color: t.heroAccent.withValues(alpha: 0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: t.isDark ? 0.45 : 0.24),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;
              return Flexible(
                flex: selected ? 2 : 1,
                child: HannaPressable(
                  key: ValueKey('nav-item-$index'),
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(HannaRadius.pill),
                  semanticLabel: item.label,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: HannaMotion.easeOutExpo,
                    height: 46,
                    padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 10),
                    decoration: BoxDecoration(
                      color: selected ? t.heroAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(HannaRadius.pill),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 19,
                          color: selected ? t.onHeroAccent : t.onHeroMuted,
                        ),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: t.onHeroAccent,
                                    fontSize: 13,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
