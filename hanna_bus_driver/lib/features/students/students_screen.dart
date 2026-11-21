import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/state/models.dart';
import '../../core/widgets/driver_widgets.dart';
import '../../core/widgets/hanna_card.dart';
import '../../core/widgets/hanna_icon.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({
    super.key,
    required this.state,
    this.absentOnly = false,
  });
  final DriverState state;
  final bool absentOnly;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => DriverPage(
      state: state,
      title: AppStrings.of(context).design('children', 'page_title'),
      children: [StudentsContent(state: state, absentOnly: absentOnly)],
    ),
  );
}

class StudentsContent extends StatefulWidget {
  const StudentsContent({
    super.key,
    required this.state,
    this.absentOnly = false,
  });
  final DriverState state;
  final bool absentOnly;
  @override
  State<StudentsContent> createState() => _StudentsContentState();
}

class _StudentsContentState extends State<StudentsContent> {
  String query = '', filter = 'all';
  bool grouped = false;
  @override
  void initState() {
    super.initState();
    if (widget.absentOnly) filter = 'absent';
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final state = widget.state;
    final students = state.students
        .where(
          (p) =>
              (filter == 'all' ||
                  filter == 'absent' && p.absent ||
                  filter == 'on_bus' && p.status == 'on_bus' ||
                  filter == 'waiting' && !p.absent && p.status == 'waiting') &&
              '${label(p.name, s.language)} ${label(p.stop, s.language)} ${p.code}'
                  .toLowerCase()
                  .contains(query.toLowerCase()),
        )
        .toList();
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DriverField(
            label: s.design('children', 'search_ph'),
            icon: 'magnifying-glass',
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final f in ['all', 'on_bus', 'waiting', 'absent'])
                ChoiceChip(
                  label: Text(s.t(f)),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(s.design('children', 'by_stops_title')),
            value: grouped,
            onChanged: (v) => setState(() => grouped = v),
          ),
          if (grouped)
            for (final stop in state.trip?.stations ?? <Station>[]) ...[
              SectionTitle('${stop.time} · ${label(stop.name, s.language)}'),
              const SizedBox(height: 10),
              for (final student in students.where(
                (p) => stop.students.any((c) => c.id == p.id),
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StudentCard(student: student),
                ),
            ]
          else
            for (final student in students)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: StudentCard(student: student),
              ),
          if (students.isEmpty) Text(s.t('noStudents')),
        ],
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  const StudentCard({super.key, required this.student});
  final Student student;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return HannaCard(
      child: Row(
        children: [
          const HannaIcon('user'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label(student.name, s.language),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(label(student.stop, s.language)),
                Text(student.code, textDirection: TextDirection.ltr),
                Text(
                  s.t(student.absent ? 'absent' : student.status),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
