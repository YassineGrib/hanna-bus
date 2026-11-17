import 'package:flutter/material.dart';
import '../theme/hanna_tokens.dart';

enum HannaBadgeTone { neutral, accent, success, warning, destructive, hero }

class HannaBadge extends StatelessWidget {
  const HannaBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = HannaBadgeTone.neutral,
  });

  final String label;
  final IconData? icon;
  final HannaBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);

    late Color bg;
    late Color fg;
    late Color border;

    switch (tone) {
      case HannaBadgeTone.accent:
        bg = t.accent;
        fg = t.onAccent;
        border = t.accent;
        break;
      case HannaBadgeTone.success:
        bg = t.successSurface;
        fg = t.success;
        border = t.successBorder;
        break;
      case HannaBadgeTone.warning:
        bg = t.warningSurface;
        fg = t.warning;
        border = t.warningBorder;
        break;
      case HannaBadgeTone.destructive:
        bg = t.destructiveSurface;
        fg = t.actionDestructive;
        border = t.destructiveBorder;
        break;
      case HannaBadgeTone.hero:
        bg = t.heroAccent;
        fg = t.onHeroAccent;
        border = t.heroAccent;
        break;
      case HannaBadgeTone.neutral:
        bg = t.surfaceSubtle;
        fg = t.text;
        border = t.border;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(HannaRadius.pill),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
