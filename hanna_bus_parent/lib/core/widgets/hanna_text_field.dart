import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../motion/hanna_motion.dart';
import '../theme/hanna_tokens.dart';
import '../theme/hanna_typography.dart';
import 'hanna_icon.dart';

class HannaTextField extends StatefulWidget {
  const HannaTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.prefixIconName,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.isLoading = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.textDirection,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final String? prefixIconName;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool isLoading;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final TextDirection? textDirection;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<HannaTextField> createState() => _HannaTextFieldState();
}

class _HannaTextFieldState extends State<HannaTextField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;
  bool _hovered = false;
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _focus.addListener(() {
      if (mounted && _focused != _focus.hasFocus) {
        setState(() => _focused = _focus.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HannaTokens.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final duration = HannaMotion.effectiveDuration(context, HannaMotion.durationFast);

    final Color borderColor;
    if (!widget.enabled) {
      borderColor = t.border;
    } else if (hasError) {
      borderColor = t.actionDestructive;
    } else if (_focused) {
      borderColor = t.actionPrimary;
    } else if (_hovered) {
      borderColor = t.textMuted;
    } else {
      borderColor = t.border;
    }

    final hasContent = widget.controller != null && widget.controller!.text.isNotEmpty;
    final iconColor = hasError
        ? t.actionDestructive
        : ((_focused || hasContent) ? t.text : t.textMuted);

    final locale = Localizations.localeOf(context);
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: fontFam,
            fontFamilyFallback: fontFallbacks,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hasError ? t.actionDestructive : t.text,
          ),
        ),
        const SizedBox(height: 6),
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: duration,
            curve: HannaMotion.easeOutExpo,
            height: 54,
            decoration: BoxDecoration(
              color: widget.enabled
                  ? (hasError ? t.destructiveSurface : t.surface)
                  : t.surfaceSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: (_focused || hasError) ? 1.6 : 1.0,
              ),
            ),
            child: Center(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                obscureText: _obscured,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                textDirection: widget.textDirection,
                autofillHints: widget.autofillHints,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                style: TextStyle(
                  fontFamily: fontFam,
                  fontFamilyFallback: fontFallbacks,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: widget.enabled ? t.text : t.titleSoft,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontFamily: fontFam,
                    fontFamilyFallback: fontFallbacks,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: t.textMuted,
                  ),
                  prefixIcon: widget.prefixIconName != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                          child: HannaIcon(
                            widget.prefixIconName!,
                            size: 20,
                            color: iconColor,
                          ),
                        )
                      : (widget.prefixIcon != null
                          ? Icon(
                              widget.prefixIcon,
                              size: 20,
                              color: iconColor,
                            )
                          : null),
                  suffixIcon: widget.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : (widget.obscureText
                          ? IconButton(
                              tooltip: _obscured ? 'Show password' : 'Hide password',
                              onPressed: () => setState(() => _obscured = !_obscured),
                              icon: Icon(
                                _obscured ? LucideIcons.eye : LucideIcons.eyeOff,
                                size: 20,
                                color: t.textMuted,
                              ),
                            )
                          : widget.suffix),
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontFamily: fontFam,
                fontFamilyFallback: fontFallbacks,
                fontSize: 12,
                color: t.actionDestructive,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ] else if (widget.helperText != null && widget.helperText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: TextStyle(
              fontFamily: fontFam,
              fontFamilyFallback: fontFallbacks,
              fontSize: 12,
              color: t.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
