import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/models.dart';
import '../../../core/theme/hanna_tokens.dart';
import '../../../core/theme/hanna_typography.dart';
import '../../../core/widgets/hanna_background.dart';
import '../../../core/widgets/hanna_header.dart';

class DriverMessageThreadScreen extends StatefulWidget {
  const DriverMessageThreadScreen({super.key});

  @override
  State<DriverMessageThreadScreen> createState() =>
      _DriverMessageThreadScreenState();
}

class _DriverMessageThreadScreenState extends State<DriverMessageThreadScreen> {
  final _scrollCtrl = ScrollController();
  final _textCtrl = TextEditingController();
  Timer? _pollTimer;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final state = AppStateScope.of(context);
      await _refreshMessages();
      if (!mounted || state.isOfflineDemoMode) return;
      _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (!mounted || state.isOfflineDemoMode) {
          _pollTimer?.cancel();
          return;
        }
        if (ModalRoute.of(context)?.isCurrent == true) _refreshMessages();
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  bool _refreshing = false;
  String? _error;

  Future<void> _refreshMessages() async {
    if (!mounted || _refreshing) return;
    _refreshing = true;
    final state = AppStateScope.of(context);
    final ok = await state.fetchDriverMessages();
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      await state.markAllDriverMessagesRead();
      if (mounted) {
        setState(
          () => _error = ok
              ? null
              : AppStrings.of(context).driverMessagesLoadError,
        );
        _scrollToBottom();
      }
    }
    _refreshing = false;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _textCtrl.text;
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;

    final s = AppStrings.of(context);
    if (trimmed.length < 3) {
      setState(() => _error = s.driverMessageTooShort);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final ok = await AppStateScope.of(context).sendDriverMessage(trimmed);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _error = ok ? null : s.driverMessageSendError;
      if (ok && presetText == null) _textCtrl.clear();
    });
    if (ok) _scrollToBottom();
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      if (iso.contains('T')) {
        final part = iso.split('T')[1];
        if (part.length >= 5) {
          return part.substring(0, 5);
        }
      }
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = HannaTokens.of(context);
    final state = AppStateScope.of(context);

    final child = state.selectedChild;
    final trip = state.activeTrip;
    final driverName =
        trip?.driverName ?? child?.driverName ?? s.driverSubtitle;
    final busNo = trip?.busNumber ?? child?.busNumber;

    final messages = state.driverMessages;

    return Scaffold(
      body: HannaBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HannaSpace.lg,
                  vertical: HannaSpace.sm,
                ),
                child: HannaHeader(
                  title: driverName,
                  showBack: true,
                  subtitle: busNo == null
                      ? s.driverThreadTitle
                      : '${s.driverSubtitle} (${s.tr('Bus', 'حافلة', 'Bus')} $busNo)',
                ),
              ),
              const Divider(height: 1, thickness: 1),

              // Message List
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(HannaSpace.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: t.heroAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    LucideIcons.messageSquare,
                                    size: 28,
                                    color: t.text,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                s.emptyThreadTitle,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s.emptyThreadSubtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: t.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                          horizontal: HannaSpace.lg,
                          vertical: HannaSpace.md,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final item = messages[index];
                          return _buildMessageBubble(context, item, t);
                        },
                      ),
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HannaSpace.lg,
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: t.actionDestructive),
                  ),
                ),
              // Quick replies strip
              _buildQuickReplies(context, s, t),

              // Composer bar
              _buildComposer(context, s, t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    DriverMessageItem item,
    HannaTokens t,
  ) {
    final isParent = item.isFromParent;
    final timeStr = _formatTime(item.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isParent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isParent) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: t.heroAccent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(LucideIcons.bus, size: 16, color: t.text),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              key: ValueKey('message-bubble-${item.id}'),
              constraints: const BoxConstraints(maxWidth: 290),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isParent ? t.actionPrimary : t.surface,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: const Radius.circular(16),
                  topEnd: const Radius.circular(16),
                  bottomStart: Radius.circular(isParent ? 16 : 4),
                  bottomEnd: Radius.circular(isParent ? 4 : 16),
                ),
                border: isParent ? null : Border.all(color: t.border),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    blurRadius: 4,
                    color: t.text.withValues(alpha: 0.04),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isParent
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: isParent ? t.onPrimary : t.text,
                      fontWeight: isParent ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: HannaTypography.mono(
                          size: 10,
                          color: isParent
                              ? t.onPrimary.withValues(alpha: 0.7)
                              : t.titleSoft,
                        ),
                      ),
                      if (isParent) ...[
                        const SizedBox(width: 4),
                        Icon(
                          item.isRead
                              ? LucideIcons.checkCheck
                              : LucideIcons.check,
                          size: 14,
                          color: t.onPrimary.withValues(
                            alpha: item.isRead ? 0.9 : 0.6,
                          ),
                          key: ValueKey('read-tick-${item.id}'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(BuildContext context, AppStrings s, HannaTokens t) {
    final replies = [
      s.quickReplyWait,
      s.quickReplyAbsent,
      s.quickReplyAtStop,
      s.quickReplyThankYou,
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: HannaSpace.lg),
        itemCount: replies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final text = replies[idx];
          return GestureDetector(
            onTap: () => _sendMessage(text),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: t.border),
              ),
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: t.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComposer(BuildContext context, AppStrings s, HannaTokens t) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HannaSpace.lg,
        vertical: HannaSpace.sm,
      ),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: t.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: t.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                key: const ValueKey('driver-message-input'),
                controller: _textCtrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: s.typeMessagePlaceholder,
                  hintStyle: TextStyle(color: t.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: TextStyle(fontSize: 14, color: t.text),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            key: const ValueKey('driver-message-send-btn'),
            onTap: _sending ? null : () => _sendMessage(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: t.actionPrimary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _sending
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: t.onPrimary,
                        ),
                      )
                    : Icon(LucideIcons.send, size: 18, color: t.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
