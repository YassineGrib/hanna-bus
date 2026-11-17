import 'package:flutter/material.dart';
import '../motion/hanna_motion.dart';
import '../theme/hanna_tokens.dart';
import '../theme/hanna_typography.dart';
import 'hanna_icon.dart';

enum HannaButtonVariant { primary, secondary, destructive, ghost, heroAccent }

class HannaButton extends StatefulWidget {
  const HannaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = HannaButtonVariant.primary,
    this.icon,
    this.leadIconName,
    this.trailIcon,
    this.trailIconName,
    this.isLoading = false,
    this.selected = false,
    this.fullWidth = true,
    this.compact = false,
    this.height,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final HannaButtonVariant variant;
  final IconData? icon;
  final String? leadIconName;
  final IconData? trailIcon;
  final String? trailIconName;
  final bool isLoading;
  final bool selected;
  final bool fullWidth;
  final bool compact;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<HannaButton> createState() => _HannaButtonState();
}

class _HannaButtonState extends State<HannaButton> {
  bool _hovered = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);

    late Color bg;
    late Color fg;
    late Color border;
    List<BoxShadow>? shadows;

    switch (widget.variant) {
      case HannaButtonVariant.primary:
        bg = t.actionPrimary;
        fg = t.onPrimary;
        border = t.actionPrimary;
        if (!t.isDark) {
          shadows = [
            BoxShadow(
              color: t.text.withValues(alpha: 0.16),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ];
        }
        break;
      case HannaButtonVariant.secondary:
        bg = widget.selected ? t.surfaceSubtle : t.surface;
        fg = t.text;
        border = widget.selected ? t.actionPrimary : t.border;
        break;
      case HannaButtonVariant.destructive:
        bg = t.actionDestructive;
        fg = t.onDestructive;
        border = t.actionDestructive;
        break;
      case HannaButtonVariant.ghost:
        bg = widget.selected ? t.surfaceSubtle : Colors.transparent;
        fg = t.link;
        border = widget.selected ? t.border : Colors.transparent;
        break;
      case HannaButtonVariant.heroAccent:
        bg = t.heroAccent;
        fg = t.onHeroAccent;
        border = t.heroAccent;
        break;
    }

    if (!_enabled && !widget.isLoading) {
      bg = bg == Colors.transparent ? Colors.transparent : t.surfaceSubtle;
      fg = t.titleSoft;
      border = t.border;
      shadows = null;
    } else if (_hovered && _enabled) {
      bg = Color.alphaBlend(fg.withValues(alpha: 0.06), bg);
    }

    final defaultRadius = widget.compact
        ? BorderRadius.circular(HannaRadius.md)
        : (widget.variant == HannaButtonVariant.primary
            ? BorderRadius.circular(18)
            : BorderRadius.circular(HannaRadius.lg));
    final radius = widget.borderRadius ?? defaultRadius;
    final duration = HannaMotion.effectiveDuration(context, HannaMotion.durationFast);

    final double effectiveHeight = widget.height ?? (widget.compact ? 42.0 : 58.0);

    return FocusableActionDetector(
      enabled: _enabled,
      onShowHoverHighlight: (v) => setState(() => _hovered = v),
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      child: HannaPressable(
        enabled: _enabled,
        onTap: widget.onPressed,
        borderRadius: radius,
        semanticLabel: widget.label,
        child: AnimatedContainer(
          duration: duration,
          curve: HannaMotion.easeOutExpo,
          height: effectiveHeight,
          constraints: BoxConstraints(
            minWidth: widget.compact ? 44 : 88,
          ),
          width: widget.fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 14 : 20,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            boxShadow: shadows,
            border: Border.all(
              color: _focused ? t.text : border,
              width: _focused ? 2.0 : (widget.selected ? 1.6 : 1.0),
            ),
          ),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                ),
                const SizedBox(width: 10),
              ] else if (widget.leadIconName != null) ...[
                HannaIcon(widget.leadIconName!, size: 18, color: fg),
                const SizedBox(width: 8),
              ] else if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Builder(
                  builder: (context) {
                    final locale = Localizations.localeOf(context);
                    final fontFam = HannaTypography.familyFor(locale);
                    final fontFallbacks = HannaTypography.fallbacksFor(locale);
                    final baseStyle = Theme.of(context).textTheme.labelLarge ??
                        TextStyle(fontFamily: fontFam, fontFamilyFallback: fontFallbacks);
                    return Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: baseStyle.copyWith(
                        fontFamily: fontFam,
                        fontFamilyFallback: fontFallbacks,
                        color: fg,
                        fontSize: widget.compact ? 14 : 17,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ),
              if (widget.trailIconName != null) ...[
                const SizedBox(width: 8),
                HannaIcon(widget.trailIconName!, size: 18, color: fg),
              ] else if (widget.trailIcon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.trailIcon, size: 18, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
