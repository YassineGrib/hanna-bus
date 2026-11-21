import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/driver_widgets.dart';
import '../../core/widgets/hanna_card.dart';
import '../../core/widgets/hanna_icon.dart';
import '../../core/widgets/remote_page.dart';
import '../home/home_shell.dart';

enum SettingsSection {
  hub,
  navigation,
  scanner,
  security,
  localization,
  handbook,
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.state,
    this.section = SettingsSection.hub,
  });
  final DriverState state;
  final SettingsSection section;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final draft = <String, dynamic>{};
  static const titles = {
    SettingsSection.hub: 'page_title',
    SettingsSection.navigation: 'nav_sett_title',
    SettingsSection.scanner: 'scan_sett_title',
    SettingsSection.security: 'sec_sett_title',
    SettingsSection.localization: 'lang_title',
    SettingsSection.handbook: 'sop_title',
  };
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context), state = widget.state;
    String d(String key) => s.design('settings', key);
    return RemotePage(
      state: state,
      title: d(titles[widget.section]!),
      load: () async {
        await state.loadSettings();
        return state.settings;
      },
      content: (context, _) {
        final values = {...state.settings, ...draft};
        Widget toggle(String key) => Material(
          color: Colors.transparent,
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(s.t(key)),
            value: values[key] == true,
            onChanged: state.busy
                ? null
                : (v) => setState(() => draft[key] = v),
          ),
        );
        Widget choices(
          String key,
          List<String> options, {
          List<String>? labels,
        }) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(s.t(key)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (var i = 0; i < options.length; i++)
                  HannaChoiceChip(
                    label: Text(labels?[i] ?? s.t(options[i])),
                    selected: values[key] == options[i],
                    onSelected: state.busy
                        ? null
                        : (_) => setState(() => draft[key] = options[i]),
                  ),
              ],
            ),
          ],
        );
        Widget slider(String key, int min, int max, int divisions) => Column(
          children: [
            DataRowCard(s.t(key), '${values[key]}'),
            Slider(
              value: (values[key] as num).toDouble().clamp(
                min.toDouble(),
                max.toDouble(),
              ),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: divisions,
              label: '${values[key]}',
              onChanged: state.busy
                  ? null
                  : (v) => setState(() => draft[key] = v.round()),
            ),
          ],
        );
        return [
          if (widget.section == SettingsSection.hub) ...[
            for (final item in <(String, SettingsSection)>[
              ('o1_t', SettingsSection.navigation),
              ('o2_t', SettingsSection.scanner),
              ('p1_t', SettingsSection.localization),
              ('p2_t', SettingsSection.localization),
              ('s1_t', SettingsSection.security),
              ('s2_t', SettingsSection.handbook),
            ])
              HannaCard(
                onTap: () => openDriverScreen(
                  context,
                  SettingsScreen(state: state, section: item.$2),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(d(item.$1))),
                    const HannaIcon('caret-right'),
                  ],
                ),
              ),
            DriverButton(
              s.t('signOut'),
              danger: true,
              onPressed: state.busy
                  ? null
                  : () async {
                      if (await state.logout() && context.mounted) {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                    },
            ),
          ],
          if (widget.section == SettingsSection.navigation) ...[
            Text(d('nav_sett_sub')),
            SectionTitle(d('sec_map_disp')),
            choices('glare_mode', ['auto', 'day', 'night']),
            toggle('voice_guidance'),
            SectionTitle(d('sec_speed')),
            toggle('speed_chime'),
            slider('radar_radius_m', 100, 1000, 9),
            Text(s.t('navigationPreference')),
          ],
          if (widget.section == SettingsSection.scanner) ...[
            SectionTitle(d('sec_scan_mode')),
            choices('scan_mode', ['camera', 'bluetooth']),
            Text(s.t('hardwareHint')),
            SectionTitle(d('sec_feedback')),
            toggle('scan_chime'),
            Text(s.t('haptic')),
            DriverButton(
              s.t('testChime'),
              secondary: true,
              onPressed: () => SystemSound.play(SystemSoundType.click),
            ),
          ],
          if (widget.section == SettingsSection.security) ...[
            Text(d('sec_sett_sub')),
            SectionTitle(d('sec_auth')),
            toggle('biometric_unlock'),
            toggle('quick_pin_enabled'),
            SectionTitle(d('sec_auto_lock')),
            slider('privacy_lock_minutes', 1, 30, 29),
            Text(s.t('preferenceOnly')),
          ],
          if (widget.section == SettingsSection.localization) ...[
            SectionTitle(d('sec_lang')),
            Wrap(
              spacing: 8,
              children: [
                for (final language in ['en', 'ar'])
                  HannaChoiceChip(
                    key: Key('language-$language'),
                    label: Text(d('l_$language')),
                    selected: state.locale.languageCode == language,
                    onSelected: state.busy
                        ? null
                        : (_) => state.updateProfile({'locale': language}),
                  ),
              ],
            ),
            choices(
              'theme_palette',
              ['mustard', 'teal-gray', 'ocean-blue'],
              labels: [s.t('mustard'), s.t('tealGray'), s.t('ocean')],
            ),
            choices('brightness_mode', ['light', 'dark', 'auto']),
          ],
          if (widget.section == SettingsSection.handbook) ...[
            SectionTitle(d('sec_sops')),
            for (var i = 1; i <= 3; i++)
              HannaCard(
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(d('sop${i}_t')),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        i == 1
                            ? s.t('handbookAbsence')
                            : i == 3
                            ? s.t('handbookBreakdown')
                            : d('sop2_s'),
                      ),
                    ),
                  ],
                ),
              ),
            SectionTitle(s.t('diagnostics')),
            DataRowCard(
              s.t('diagnostics'),
              '${s.t(state.lastPosition == null ? 'gpsUnknown' : 'gpsAvailable')}\n${s.t(state.repository.isDemo ? 'demo' : 'connectionLive')}',
            ),
          ],
          if (widget.section != SettingsSection.hub &&
              widget.section != SettingsSection.handbook)
            DriverButton(
              s.t('save'),
              key: const Key('save-settings'),
              onPressed: state.busy
                  ? null
                  : () async {
                      final changes = Map<String, dynamic>.from(draft);
                      if (await state.saveSettings(changes) && mounted) {
                        setState(() => draft.clear());
                      }
                    },
            ),
        ];
      },
    );
  }
}
