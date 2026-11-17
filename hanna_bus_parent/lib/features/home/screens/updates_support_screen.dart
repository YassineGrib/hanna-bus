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
import '../../../core/widgets/hanna_text_field.dart';

class UpdatesSupportScreen extends StatefulWidget {
  const UpdatesSupportScreen({super.key});

  @override
  State<UpdatesSupportScreen> createState() => _UpdatesSupportScreenState();
}

class _UpdatesSupportScreenState extends State<UpdatesSupportScreen> {
  String _recipient = 'driver';
  final _messageCtrl = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final s = AppStrings.of(context);
    final text = _messageCtrl.text.trim();
    if (text.length < 3) {
      setState(() {
        _error = s.tr(
          'Enter at least 3 characters before sending.',
          'اكتب 3 أحرف على الأقل قبل الإرسال.',
          'Ecrivez au moins 3 caracteres.',
        );
      });
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });
    final state = AppStateScope.of(context);
    final ok = await state.sendSupportMessage(
      recipientType: _recipient,
      childId: state.selectedChild?.id,
      message: text,
    );
    if (!mounted) return;
    setState(() => _sending = false);

    if (ok) {
      _messageCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.tr(
              'Message sent to $_recipient.',
              'تم إرسال رسالتك بنجاح.',
              'Message envoye avec succes.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);

    return Scaffold(
      body: HannaBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(HannaSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HannaHeader(title: s.updatesTitle, showBack: true),
                const SizedBox(height: HannaSpace.lg),
                ...state.bulletins.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: HannaSpace.sm),
                    child: HannaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              HannaBadge(
                                label: item.tag.toUpperCase(),
                                icon: LucideIcons.newspaper,
                                tone: item.tag == 'safety'
                                    ? HannaBadgeTone.success
                                    : HannaBadgeTone.accent,
                              ),
                              Text(
                                item.publishedAt.split('T').first,
                                style: HannaTypography.mono(size: 12, color: t.titleSoft),
                              ),
                            ],
                          ),
                          const SizedBox(height: HannaSpace.sm),
                          Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            item.body,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: t.textMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: HannaSpace.md),
                HannaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        s.tr('Direct Contact Dispatch', 'رسالة سريعة للنقل', 'Contact transport direct'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: HannaSpace.sm),
                      Row(
                        children: [
                          Expanded(
                            child: HannaButton(
                              label: s.messageDriverTab,
                              compact: true,
                              selected: _recipient == 'driver',
                              variant: HannaButtonVariant.secondary,
                              onPressed: () => setState(() => _recipient = 'driver'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: HannaButton(
                              label: s.messageCoordinatorTab,
                              compact: true,
                              selected: _recipient == 'coordinator',
                              variant: HannaButtonVariant.secondary,
                              onPressed: () => setState(() => _recipient = 'coordinator'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: HannaSpace.md),
                      HannaTextField(
                        label: s.tr('Message', 'الرسالة', 'Message'),
                        controller: _messageCtrl,
                        maxLines: 3,
                        hintText: s.messagePlaceholder,
                        errorText: _error,
                        onChanged: (_) => setState(() => _error = null),
                      ),
                      const SizedBox(height: HannaSpace.md),
                      HannaButton(
                        label: s.sendMessage,
                        icon: LucideIcons.send,
                        isLoading: _sending,
                        onPressed: _send,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
