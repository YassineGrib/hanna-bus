import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../motion/hanna_motion.dart';
import '../state/app_state.dart';
import '../theme/hanna_tokens.dart';
import '../theme/hanna_typography.dart';
import 'hanna_background.dart';
import 'hanna_icon.dart';

/// A choice chip drawn by us instead of Material's ChoiceChip. Material washes out the
/// label of a disabled chip (seen on the emulator: the running route was barely readable),
/// and a disabled chip here is still information. Colours are explicit: on-primary text on
/// the primary fill when selected, text on the surface otherwise, muted text when locked.
class HannaChoiceChip extends StatelessWidget {
  const HannaChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final enabled = onSelected != null;
    // A disabled chip is still information (for example the route that is running), so
    // its label keeps full contrast: on-primary when selected, muted text otherwise.
    final color = selected ? t.onPrimary : (enabled ? t.text : t.textMuted);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: selected ? t.actionPrimary : t.border),
    );
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Material(
        color: selected ? t.actionPrimary : t.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? () => onSelected!(!selected) : null,
          customBorder: shape,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Icon(Icons.check, size: 16, color: t.onPrimary),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: color, fontWeight: FontWeight.w600),
                      child: label,
                    ),
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

class DriverButton extends StatelessWidget {
  const DriverButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.danger = false,
    this.secondary = false,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool danger, secondary;
  final String? icon;
  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final fg = danger
        ? t.onDestructive
        : secondary
        ? t.text
        : t.onPrimary;
    return HannaPressable(
      onTap: onPressed,
      enabled: onPressed != null,
      semanticLabel: label,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: onPressed == null
              ? t.surfaceSubtle
              : danger
              ? t.actionDestructive
              : secondary
              ? t.surface
              : t.actionPrimary,
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              HannaIcon(icon!, color: onPressed == null ? t.textMuted : fg),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: HannaTypography.style(
                  context,
                  size: 17,
                  weight: FontWeight.w700,
                  color: onPressed == null ? t.textMuted : fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverField extends StatelessWidget {
  const DriverField({
    super.key,
    required this.label,
    this.controller,
    this.icon = 'envelope-simple',
    this.obscure = false,
    this.onChanged,
    this.onSubmitted,
    this.latin = false,
    this.keyboard,
  });
  final String label, icon;
  final TextEditingController? controller;
  final bool obscure, latin;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboard;
  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      obscureText: obscure,
      keyboardType: keyboard,
      textDirection: latin ? TextDirection.ltr : null,
      style: HannaTypography.style(context, size: 15),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: t.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        constraints: const BoxConstraints(minHeight: 56),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(16),
          child: HannaIcon(icon, color: t.textMuted),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: t.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: t.border),
        ),
      ),
    );
  }
}

class DriverPage extends StatelessWidget {
  const DriverPage({
    super.key,
    required this.state,
    required this.title,
    required this.children,
    this.trailing,
    this.bottom,
    this.header,
    this.back = true,
  });
  final DriverState state;
  final String title;
  final List<Widget> children;
  final Widget? trailing, bottom;
  final Widget? header;
  final bool back;
  @override
  Widget build(BuildContext context) => Scaffold(
    extendBody: true,
    body: HannaBackground(
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                18,
                12,
                18,
                bottom == null ? 32 : 120,
              ),
              children: [
                header ??
                    Row(
                      children: [
                        if (back && Navigator.canPop(context))
                          const BackButton(),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        ?trailing,
                      ],
                    ),
                const SizedBox(height: 16),
                DriverFeedback(state: state),
                ...children.expand((w) => [w, const SizedBox(height: 14)]),
              ],
            ),
          ),
        ),
      ),
    ),
    bottomNavigationBar: bottom,
  );
}

class DriverFeedback extends StatelessWidget {
  const DriverFeedback({super.key, required this.state});
  final DriverState state;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.repository.isDemo)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              s.t('demo'),
              style: TextStyle(color: t.warning, fontWeight: FontWeight.w600),
            ),
          ),
        if (state.busy) const LinearProgressIndicator(),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              s.t(state.error!),
              style: TextStyle(color: t.actionDestructive),
            ),
          ),
        if (state.notice != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(s.t(state.notice!), style: TextStyle(color: t.success)),
          ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleMedium);
}
