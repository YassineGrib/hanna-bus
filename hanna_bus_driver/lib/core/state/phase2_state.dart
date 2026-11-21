part of 'app_state.dart';

const defaultDriverSettings = <String, dynamic>{
  'voice_guidance': true,
  'speed_chime': true,
  'glare_mode': 'auto',
  'radar_radius_m': 500,
  'scan_mode': 'camera',
  'scan_chime': true,
  'biometric_unlock': false,
  'quick_pin_enabled': false,
  'privacy_lock_minutes': 5,
  'theme_palette': 'mustard',
  'brightness_mode': 'light',
};

extension Phase2State on DriverState {
  void _applySettings() {
    palette = HannaPalette.fromApi(settings['theme_palette'] as String?);
    brightnessMode = settings['brightness_mode'] as String? ?? 'light';
    brightness = brightnessMode == 'auto'
        ? WidgetsBinding.instance.platformDispatcher.platformBrightness
        : brightnessMode == 'dark'
        ? Brightness.dark
        : Brightness.light;
  }

  Future<void> _persistSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_settings', jsonEncode(settings));
    await prefs.setString('driver_palette', palette.apiValue);
    await prefs.setBool('driver_dark', brightness == Brightness.dark);
  }

  Future<void> loadPhase2() async {
    // New endpoints can be deployed after the daily trip API. Never simulate a
    // live response or prevent the existing trip flow when one is unavailable.
    for (final load in [loadSettings, loadInbox, loadContacts]) {
      try {
        await load();
      } on ApiFailure {
        /* Screen provides retry. */
      } on ApiUnreachable {
        /* Screen provides retry. */
      }
    }
  }

  Future<Json> getData(String path) async =>
      Map<String, dynamic>.from(await repository.request('GET', path));
  Future<void> loadInbox() async {
    final result = await repository.request('GET', '/driver/messages') as List;
    inbox = result.map((e) => Map<String, dynamic>.from(e)).toList();
    _notify();
  }

  Future<void> loadContacts() async {
    contacts = await getData('/driver/contacts');
    _notify();
  }

  Future<void> loadSettings() async {
    settings = {...defaultDriverSettings, ...await getData('/driver/settings')};
    _applySettings();
    await _persistSettings();
    _notify();
  }

  Future<bool> saveSettings(Json changes) => run(() async {
    final response = await repository.request(
      'PUT',
      '/driver/settings',
      changes,
    );
    settings = {
      ...settings,
      ...changes,
      ...Map<String, dynamic>.from(response),
    };
    _applySettings();
    await _persistSettings();
    notice = 'saved';
  });
  Future<bool> updateProfile(Json changes) => run(() async {
    final response = await repository.request(
      'PUT',
      '/driver/profile',
      changes,
    );
    profile = Map<String, dynamic>.from(response);
    if (changes['locale'] != null) {
      locale = Locale(changes['locale']);
      repository.api.language = locale.languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driver_language', locale.languageCode);
    }
    notice = 'saved';
  });
  Future<Json> loadThread(String parent, String child) async {
    final result = await getData(
      '/driver/messages/${Uri.encodeComponent(parent)}?child_id=${Uri.encodeQueryComponent(child)}',
    );
    inbox = [
      for (final item in inbox)
        if ('${item['parent']['id']}' == parent &&
            '${item['child']['id']}' == child)
          {...item, 'unread_count': 0}
        else
          item,
    ];
    _notify();
    return result;
  }

  Future<bool> sendMessage(String parent, String child, String message) =>
      run(() async {
        if (message.trim().isEmpty) throw const ApiFailure(422);
        await repository.request(
          'POST',
          '/driver/messages/${Uri.encodeComponent(parent)}',
          {'child_id': child, 'message': message.trim()},
        );
        try {
          await loadInbox();
        } on ApiFailure {
          // The send was confirmed. An inbox read failure must not invite a
          // duplicate send; the thread still refreshes and offers retry.
        } on ApiUnreachable {
          /* Keep the confirmed send successful. */
        }
      });
  Future<Json> dossier(String child) =>
      getData('/driver/students/${Uri.encodeComponent(child)}');
  Future<Json> history(String period) =>
      getData('/driver/history?period=$period');
  Future<Json> stats() => getData('/driver/stats');
  Future<Json> passport(String bus) =>
      getData('/driver/buses/${Uri.encodeComponent(bus)}');
  Future<Json> telemetry() => getData('/driver/telemetry/today');

  // Recovery always uses the auth API, never the simulator or a guessed OTP.
  Future<Json> recovery(String action, Json body) async =>
      Map<String, dynamic>.from(
        await repository.api.request('POST', '/auth/$action', body),
      );
}
