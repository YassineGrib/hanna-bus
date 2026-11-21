import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/services/call_source.dart';
import '../../core/state/app_state.dart';
import '../../core/state/models.dart';
import '../../core/network/driver_api_client.dart';
import '../../core/theme/hanna_tokens.dart';
import '../../core/widgets/driver_widgets.dart';
import '../../core/widgets/hanna_card.dart';
import '../../core/widgets/hanna_icon.dart';
import '../../core/widgets/hanna_hero_card.dart';
import '../../core/widgets/remote_page.dart';
import '../history/history_screens.dart';
import '../home/home_shell.dart';
import '../messages/messages_screen.dart';
import '../settings/settings_screens.dart';
import '../sos/sos_screen.dart';
import '../students/dossier_screen.dart';
import '../trip/trip_screens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.state});
  final DriverState state;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context), t = HannaTokens.of(context);
    return RemotePage(
      state: state,
      title: s.design('profile', 'page_title'),
      load: () async {
        state.profile = await state.getData('/driver/profile');
        return state.profile;
      },
      content: (context, _) {
        final data = state.profile;
        return [
          HannaHeroCard(
            child: Column(
              children: [
                const CircleAvatar(radius: 28, child: HannaIcon('user')),
                const SizedBox(height: 12),
                Text(
                  label(data['user']?['name'], s.language),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: t.onHero),
                ),
                Text(
                  '${data['rating'] ?? 0} · ${data['trips_count'] ?? 0} ${s.t('trips')}',
                  style: TextStyle(color: t.onHeroMuted),
                ),
                Text(
                  '${data['license_number'] ?? ''}',
                  style: TextStyle(color: t.onHero),
                ),
              ],
            ),
          ),
          DataRowCard(s.t('phone'), '${data['user']?['phone'] ?? ''}'),
          DriverButton(
            s.design('profile', 'btn_edit_prof'),
            onPressed: () =>
                openDriverScreen(context, EditProfileScreen(state: state)),
          ),
          for (final item in <(String, Widget)>[
            if (state.currentBus != null)
              (
                s.design('profile', 'v_title'),
                PassportScreen(state: state, busId: state.currentBus!.id),
              ),
            (s.t('inspect'), InspectionScreen(state: state)),
            (s.design('profile', 'tel_title'), TelemetryScreen(state: state)),
            (s.design('profile', 'disp_title'), ContactsScreen(state: state)),
            (s.t('messages'), MessagesScreen(state: state)),
            (s.t('history'), HistoryScreen(state: state)),
            (s.t('stats'), StatsScreen(state: state)),
            (s.t('settings'), SettingsScreen(state: state)),
          ])
            HannaCard(
              onTap: () => openDriverScreen(context, item.$2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.$1,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const HannaIcon('caret-right'),
                ],
              ),
            ),
        ];
      },
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.state});
  final DriverState state;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final name = TextEditingController(
    text: label(
      widget.state.profile['user']?['name'],
      widget.state.locale.languageCode,
    ),
  );
  late final phone = TextEditingController(
    text: '${widget.state.profile['user']?['phone'] ?? ''}',
  );
  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final s = AppStrings.of(context);
      return DriverPage(
        state: widget.state,
        title: s.design('profile', 'btn_edit_prof'),
        children: [
          DriverField(label: s.t('name'), controller: name, icon: 'user'),
          DriverField(
            label: s.t('phone'),
            controller: phone,
            keyboard: TextInputType.phone,
            latin: true,
          ),
          DriverButton(
            s.t('save'),
            key: const Key('save-profile'),
            onPressed: widget.state.busy
                ? null
                : () async {
                    if (name.text.trim().isEmpty) {
                      await widget.state.run(() async {
                        throw const ApiFailure(422);
                      });
                      return;
                    }
                    if (await widget.state.updateProfile({
                          'name': name.text.trim(),
                          'phone': phone.text.trim(),
                        }) &&
                        context.mounted &&
                        Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
          ),
        ],
      );
    },
  );
}

class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key, required this.state, required this.busId});
  final DriverState state;
  final String busId;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return RemotePage(
      state: state,
      title: s.design('profile', 'v_title'),
      load: () => state.passport(busId),
      content: (context, data) => [
        SectionTitle('${s.t('bus')} ${data['number']}'),
        Text(label(data['line_name'], s.language)),
        Text(s.t(data['status'] ?? 'available')),
        for (final key in [
          'vehicle_model',
          'plate_number',
          'capacity',
          'insurance_expires_on',
          'technical_control_expires_on',
          'last_service_on',
        ])
          DataRowCard(s.t(key), label(data[key], s.language)),
        DataRowCard(
          s.t('last_inspection'),
          data['last_inspection'] == null
              ? ''
              : '${data['last_inspection']['date']} · ${s.t(data['last_inspection']['passed'] == true ? 'passed' : 'failed')}',
        ),
        DriverButton(
          s.t('inspect'),
          onPressed: () =>
              openDriverScreen(context, InspectionScreen(state: state)),
        ),
      ],
    );
  }
}

class TelemetryScreen extends StatelessWidget {
  const TelemetryScreen({super.key, required this.state});
  final DriverState state;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return RemotePage(
      state: state,
      title: s.design('profile', 'tel_title'),
      load: state.telemetry,
      content: (context, data) => [
        SectionTitle(s.t('today')),
        MetricGrid(
          values: {
            for (final key in [
              'max_speed_kmh',
              'avg_speed_kmh',
              'speeding_events',
              'distance_km',
              'driving_minutes',
              'trips',
            ])
              key: data[key] ?? 0,
          },
        ),
      ],
    );
  }
}

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key, required this.state, this.calls});
  final DriverState state;
  final CallSource? calls;
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return RemotePage(
      state: state,
      title: s.design('profile', 'disp_title'),
      load: () async {
        await state.loadContacts();
        return state.contacts;
      },
      content: (context, data) => [
        for (final key in ['coordinator', 'school']) ...[
          DataRowCard(s.t(key), label(data[key]?['name'], s.language)),
          DriverButton(
            '${s.t('call')} · ${data[key]?['phone'] ?? s.t('notProvided')}',
            key: Key('call-$key'),
            onPressed: () =>
                dialContact(context, '${data[key]?['phone'] ?? ''}', calls),
          ),
        ],
        for (final contact in data['emergency'] ?? <Json>[])
          DriverButton(
            '${label(contact['label'], s.language)} · ${contact['phone']}',
            secondary: true,
            onPressed: () => dialContact(context, '${contact['phone']}', calls),
          ),
        DriverButton(
          s.design('fleet', 's_title'),
          danger: true,
          onPressed: () =>
              openDriverScreen(context, SosScreen(state: state, calls: calls)),
        ),
      ],
    );
  }
}
