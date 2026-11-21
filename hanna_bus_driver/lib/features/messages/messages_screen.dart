import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/state/models.dart';
import '../../core/widgets/driver_widgets.dart';
import '../../core/widgets/hanna_card.dart';
import '../../core/widgets/remote_page.dart';
import '../../core/theme/hanna_tokens.dart';
import '../../core/motion/hanna_motion.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.state});
  final DriverState state;
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String filter = 'all';
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return RemotePage(
      state: widget.state,
      title: s.design('fleet', 'm_title'),
      load: () async {
        await widget.state.loadInbox();
        return {};
      },
      content: (context, _) {
        final items = widget.state.inbox
            .where(
              (i) =>
                  filter == 'all' ||
                  filter == 'unread' && (i['unread_count'] as num) > 0 ||
                  filter == 'urgent' && i['is_urgent'] == true,
            )
            .toList();
        return [
          Wrap(
            spacing: 8,
            children: [
              for (final f in ['all', 'unread', 'urgent'])
                ChoiceChip(
                  label: Text(
                    '${s.t(f)} ${widget.state.inbox.where((i) => f == 'all' || f == 'unread' && (i['unread_count'] as num) > 0 || f == 'urgent' && i['is_urgent'] == true).length}',
                  ),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                ),
            ],
          ),
          if (items.isEmpty) Text(s.t('empty')),
          for (final item in items)
            HannaCard(
              onTap: () async {
                await Navigator.of(context).push(
                  HannaMotion.route(
                    MessageThreadScreen(
                      state: widget.state,
                      parentId: '${item['parent']['id']}',
                      childId: '${item['child']['id']}',
                    ),
                  ),
                );
                if (mounted) setState(() {});
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label(item['parent']['name'], s.language),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${label(item['child']['name'], s.language)} · ${label(item['child']['stop_name'], s.language)}',
                  ),
                  Text(label(item['last_message'], s.language)),
                  Text(
                    displayTimestamp(context, item['last_at']),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      if ((item['unread_count'] as num) > 0)
                        Chip(
                          label: Text(
                            '${item['unread_count']} ${s.t('unread')}',
                          ),
                        ),
                      if (item['is_urgent'] == true)
                        Chip(label: Text(s.t('urgent'))),
                    ],
                  ),
                ],
              ),
            ),
        ];
      },
    );
  }
}

class MessageThreadScreen extends StatefulWidget {
  const MessageThreadScreen({
    super.key,
    required this.state,
    required this.parentId,
    required this.childId,
  });
  final DriverState state;
  final String parentId, childId;
  @override
  State<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends State<MessageThreadScreen>
    with WidgetsBindingObserver {
  final composer = TextEditingController();
  Timer? timer;
  Json? thread;
  String? error;
  bool loading = false, foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
    timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (foreground && (ModalRoute.of(context)?.isCurrent ?? false)) refresh();
    });
  }

  Future<void> refresh() async {
    if (loading || !widget.state.authenticated) return;
    loading = true;
    try {
      final result = await widget.state.loadThread(
        widget.parentId,
        widget.childId,
      );
      if (mounted) {
        setState(() {
          thread = result;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = widget.state.failure(e));
    } finally {
      loading = false;
    }
  }

  Future<void> send() async {
    if (composer.text.trim().isEmpty) return;
    if (await widget.state.sendMessage(
      widget.parentId,
      widget.childId,
      composer.text,
    )) {
      composer.clear();
      await refresh();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    if (foreground && (ModalRoute.of(context)?.isCurrent ?? false)) {
      refresh();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    composer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final s = AppStrings.of(context), t = HannaTokens.of(context);
      return DriverPage(
        state: widget.state,
        title: thread == null
            ? s.t('messages')
            : label(thread!['parent']['name'], s.language),
        children: [
          if (thread == null && error == null) const LinearProgressIndicator(),
          if (error != null) ...[
            Text(s.t(error!)),
            DriverButton(s.t('retry'), onPressed: refresh),
          ],
          if (thread != null) Text(label(thread!['child']['name'], s.language)),
          for (final m in thread?['messages'] ?? <Json>[])
            Align(
              alignment: m['direction'] == 'driver_to_parent'
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 290),
                child: HannaCard(
                  backgroundColor: m['direction'] == 'driver_to_parent'
                      ? t.accent
                      : t.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label(m['message'], s.language),
                        style: TextStyle(
                          color: m['direction'] == 'driver_to_parent'
                              ? t.onAccent
                              : t.text,
                        ),
                      ),
                      Text(
                        displayTimestamp(context, m['created_at']),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final reply in s.list('fleet', 'q'))
                ActionChip(
                  label: Text('$reply'),
                  onPressed: () => setState(() => composer.text = '$reply'),
                ),
            ],
          ),
          DriverField(label: s.design('fleet', 'c_ph'), controller: composer),
          DriverButton(
            s.t('send'),
            key: const Key('send-message'),
            onPressed: widget.state.busy ? null : send,
          ),
        ],
      );
    },
  );
}
