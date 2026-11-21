import 'dart:convert';

import 'package:flutter/material.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_parent/core/network/hanna_api_client.dart';
import 'package:hanna_bus_parent/core/state/app_state.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _user(String locale) => {
  'id': 1,
  'name': 'Karim Mansouri',
  'email': 'k.mansouri@mail.dz',
  'phone': '+213 551 22 33 44',
  'primary_bus_stop': 'Hydra North - Stop 04',
  'theme_palette': 'mustard',
  'brightness_mode': 'light',
  'locale': locale,
};

/// Answers login with the given stored profile locale, records preference updates, and
/// returns 404 for every dashboard call (the dashboard content is irrelevant here).
MockClient _server(String storedLocale, List<String> preferenceUpdates) {
  return MockClient((request) async {
    final path = request.url.path;
    if (path.endsWith('/auth/login')) {
      return http.Response(
        jsonEncode({'token': 't', 'user': _user(storedLocale)}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (path.endsWith('/parent/settings/preferences') && request.method == 'PUT') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['locale'] != null) preferenceUpdates.add('${body['locale']}');
      return http.Response(
        jsonEncode(_user('${body['locale'] ?? storedLocale}')),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response(
      jsonEncode({'message': 'not found'}),
      404,
      headers: {'content-type': 'application/json'},
    );
  });
}

AppStateController _controller(MockClient server) => AppStateController(
  apiClient: HannaApiClient(
    baseUrl: 'http://127.0.0.1:8000/api/v1',
    httpClient: server,
  ),
);

void main() {
  test('a language chosen before signing in survives the login and is sent to the server', () async {
    SharedPreferences.setMockInitialValues({});
    final updates = <String>[];
    final state = _controller(_server('en', updates));
    await state.init();
    await state.setLocale(const Locale('ar'));

    final ok = await state.login('k.mansouri@mail.dz', 'Password123!');

    expect(ok, isTrue);
    expect(state.locale.languageCode, 'ar');
    expect(updates, contains('ar'));
  });

  test('a fresh install adopts the language stored on the account', () async {
    SharedPreferences.setMockInitialValues({});
    final updates = <String>[];
    final state = _controller(_server('fr', updates));
    await state.init();

    final ok = await state.login('k.mansouri@mail.dz', 'Password123!');

    expect(ok, isTrue);
    expect(state.locale.languageCode, 'fr');
    expect(updates, isEmpty);
  });
}
