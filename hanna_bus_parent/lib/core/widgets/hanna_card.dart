import 'package:flutter/material.dart';
import '../motion/hanna_motion.dart';
import '../theme/hanna_tokens.dart';

class HannaCard extends StatelessWidget {
  const HannaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(HannaSpace.md),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.selected = false,
    this.borderRadius = HannaRadius.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool selected;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final tokens = HannaTokens.of(context);
    final bg = backgroundColor ?? tokens.surface;
    final stroke = selected
        ? tokens.actionPrimary
        : (borderColor ?? tokens.border);

    final content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: stroke,
          width: selected ? 1.8 : 1.0,
        ),
        boxShadow: [
          if (!tokens.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return content;

    return HannaPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: content,
    );
  }
}
