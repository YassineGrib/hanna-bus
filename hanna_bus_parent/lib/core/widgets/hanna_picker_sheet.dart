import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../motion/hanna_motion.dart';
import '../theme/hanna_tokens.dart';

class HannaPickerOption<T> {
  const HannaPickerOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
}

class HannaPickerSheet<T> extends StatelessWidget {
  const HannaPickerSheet({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.leadingIcon,
    this.enabled = true,
  });

  final String label;
  final T value;
  final List<HannaPickerOption<T>> options;
  final ValueChanged<T> onChanged;
  final IconData? leadingIcon;
  final bool enabled;

  HannaPickerOption<T> get _selectedOption {
    for (final opt in options) {
      if (opt.value == value) return opt;
    }
    return options.first;
  }

  Future<void> _openSheet(BuildContext context) async {
    final t = HannaTokens.of(context);
    final chosen = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: t.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HannaRadius.xl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              HannaSpace.lg,
              HannaSpace.sm,
              HannaSpace.lg,
              HannaSpace.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: t.border,
                      borderRadius: BorderRadius.circular(HannaRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: HannaSpace.md),
                Text(label, style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: HannaSpace.sm),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(ctx).height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final opt = options[index];
                      final isSelected = opt.value == value;
                      return HannaPressable(
                        onTap: () => Navigator.of(ctx).pop(opt.value),
                        borderRadius: BorderRadius.circular(HannaRadius.md),
                        semanticLabel: opt.label,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? t.surfaceSubtle : t.background,
                            borderRadius: BorderRadius.circular(HannaRadius.md),
                            border: Border.all(
                              color: isSelected ? t.actionPrimary : t.border,
                              width: isSelected ? 1.6 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (opt.icon != null) ...[
                                Icon(
                                  opt.icon,
                                  size: 18,
                                  color: isSelected ? t.link : t.textMuted,
                                ),
                                const SizedBox(width: 10),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.label,
                                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                            color: isSelected ? t.text : t.text,
                                          ),
                                    ),
                                    if (opt.subtitle != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        opt.subtitle!,
                                        style: Theme.of(ctx).textTheme.bodySmall,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(LucideIcons.check, size: 18, color: t.link),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (chosen != null) {
      onChanged(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final selected = _selectedOption;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        HannaPressable(
          enabled: enabled,
          onTap: () => _openSheet(context),
          borderRadius: BorderRadius.circular(HannaRadius.md),
          semanticLabel: '$label: ${selected.label}',
          child: Container(
            constraints: const BoxConstraints(minHeight: HannaSpace.minTouch),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: enabled ? t.surface : t.surfaceSubtle,
              borderRadius: BorderRadius.circular(HannaRadius.md),
              border: Border.all(color: t.border),
            ),
            child: Row(
              children: [
                if (leadingIcon != null || selected.icon != null) ...[
                  Icon(
                    selected.icon ?? leadingIcon,
                    size: 18,
                    color: t.textMuted,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    selected.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(LucideIcons.chevronDown, size: 18, color: t.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
