import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../motion/hanna_motion.dart';
import '../theme/hanna_tokens.dart';

class HannaHeader extends StatelessWidget {
  const HannaHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final canPop = showBack || ModalRoute.of(context)?.canPop == true;

    return Row(
      children: [
        if (canPop) ...[
          HannaPressable(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(HannaRadius.pill),
            semanticLabel: 'Back',
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: t.surface,
                shape: BoxShape.circle,
                border: Border.all(color: t.border),
              ),
              child: Icon(
                LucideIcons.arrowLeftDir,
                size: 18,
                color: t.text,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}
