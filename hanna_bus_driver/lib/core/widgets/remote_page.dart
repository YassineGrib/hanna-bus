import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../network/driver_api_client.dart';
import 'driver_widgets.dart';
import 'hanna_card.dart';
import 'hanna_icon.dart';

String displayTimestamp(BuildContext context, dynamic value) {
  final text = label(value, AppStrings.of(context).language);
  final parsed = DateTime.tryParse(text)?.toLocal();
  if (parsed == null) return text;
  final l = MaterialLocalizations.of(context);
  final time = l.formatTimeOfDay(TimeOfDay.fromDateTime(parsed));
  return DateUtils.isSameDay(parsed, DateTime.now())
      ? time
      : '${l.formatShortDate(parsed)} · $time';
}

/// Read screens own their loading and retry state, independently of trip writes.
class RemotePage extends StatefulWidget {
  const RemotePage({
    super.key,
    required this.state,
    required this.title,
    required this.load,
    required this.content,
  });
  final DriverState state;
  final String title;
  final Future<Json> Function() load;
  final List<Widget> Function(BuildContext, Json) content;
  @override
  State<RemotePage> createState() => _RemotePageState();
}

class _RemotePageState extends State<RemotePage> {
  Json? data;
  String? error;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.load();
      if (mounted) setState(() => data = result);
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is ApiFailure && e.status == 404
              ? 'dataUnavailable'
              : widget.state.failure(e),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) => DriverPage(
      state: widget.state,
      title: widget.title,
      trailing: IconButton(
        tooltip: AppStrings.of(context).t('retry'),
        onPressed: loading ? null : reload,
        icon: const HannaIcon('arrows-clockwise'),
      ),
      children: [
        if (loading) const LinearProgressIndicator(),
        if (error != null) ...[
          Text(AppStrings.of(context).t(error!)),
          DriverButton(AppStrings.of(context).t('retry'), onPressed: reload),
        ] else if (data != null)
          ...widget.content(context, data!),
      ],
    ),
  );
}

class DataRowCard extends StatelessWidget {
  const DataRowCard(this.title, this.value, {super.key});
  final String title, value;
  @override
  Widget build(BuildContext context) => HannaCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? AppStrings.of(context).t('notProvided') : value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    ),
  );
}
