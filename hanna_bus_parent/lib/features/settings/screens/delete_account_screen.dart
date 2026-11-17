import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_icon.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _confirmCtrl = TextEditingController();
  bool _deleting = false;

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final s = AppStrings.of(context);
    final text = _confirmCtrl.text.trim();
    final expectedWord = s.cfDeleteKeyword;
    if (text.toUpperCase() != expectedWord.toUpperCase() && text != 'DELETE') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${s.cfDeleteLabel}: $expectedWord')),
      );
      return;
    }

    setState(() => _deleting = true);
    final state = AppStateScope.of(context);
    await state.deleteAccount(text);
    if (!mounted) return;
    setState(() => _deleting = false);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final locale = Localizations.localeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final fontFam = HannaTypography.familyFor(locale);
    final fontFallbacks = HannaTypography.fallbacksFor(locale);

    return Scaffold(
      backgroundColor: t.background,
      body: HannaBackground(
        variant: HannaBackgroundVariant.sweep,
        child: SafeArea(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              // Top Bar Header
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Material(
                      color: t.border,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: Center(
                            child: HannaIcon(
                              isRtl ? 'arrow-right' : 'arrow-left',
                              size: 20,
                              color: t.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        s.deleteAccountTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          fontFamily: fontFam,
                          fontFamilyFallback: fontFallbacks,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section Label: Permanent Account Deletion
              Text(
                s.cfSecDelete,
                style: TextStyle(
                  fontFamily: fontFam,
                  fontFamilyFallback: fontFallbacks,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 12),

              // Delete Modal Card: 357x386 in DSURF with DBORD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: t.destructiveSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: t.destructiveBorder, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: t.text.withValues(alpha: 0.08),
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: t.actionDestructive,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: HannaIcon('warning-circle', size: 24, color: t.onDestructive),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            s.cfDeleteTitle,
                            style: TextStyle(
                              fontFamily: fontFam,
                              fontFamilyFallback: fontFallbacks,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: t.actionDestructive,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      s.cfDeleteBody,
                      style: TextStyle(
                        fontFamily: fontFam,
                        fontFamilyFallback: fontFallbacks,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: t.textMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirmation keyword input
                    Text(
                      s.cfDeleteLabel,
                      style: TextStyle(
                        fontFamily: fontFam,
                        fontFamilyFallback: fontFallbacks,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: t.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: t.actionDestructive, width: 1.2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Center(
                        child: TextField(
                          controller: _confirmCtrl,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: s.cfDeleteKeyword,
                            hintStyle: TextStyle(
                              fontFamily: fontFam,
                              fontFamilyFallback: fontFallbacks,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: t.actionDestructive.withValues(alpha: 0.5),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: fontFam,
                            fontFamilyFallback: fontFallbacks,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: t.actionDestructive,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Destructive permanent button
                    Material(
                      color: t.actionDestructive,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: _deleting ? null : _delete,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: _deleting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(t.onDestructive),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    HannaIcon('trash', size: 18, color: t.onDestructive),
                                    const SizedBox(width: 8),
                                    Text(
                                      s.deleteAccountTitle,
                                      style: TextStyle(
                                        fontFamily: fontFam,
                                        fontFamilyFallback: fontFallbacks,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: t.onDestructive,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cancel button
                    Material(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: t.border, width: 1.0),
                          ),
                          child: Text(
                            s.cfCancelBtn,
                            style: TextStyle(
                              fontFamily: fontFam,
                              fontFamilyFallback: fontFallbacks,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: t.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
