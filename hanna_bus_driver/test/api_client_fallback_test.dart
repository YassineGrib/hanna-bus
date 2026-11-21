import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanna_bus_driver/core/network/driver_api_client.dart';
import 'package:hanna_bus_driver/core/network/driver_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'labelled demo implements every phase 2 module without transport calls',
    () async {
      var networkCalls = 0;
      final repo = DriverRepository(
        api: DriverApiClient(
          client: MockClient((_) async {
            networkCalls++;
            throw http.ClientException('refused');
          }),
        ),
      );
      addTearDown(repo.close);
      await repo.login('ahmed.benali@mail.dz', 'Password123!');
      for (final path in [
        '/driver/messages',
        '/driver/messages/parent-1?child_id=child-1',
        '/driver/history?period=week',
        '/driver/history?period=month',
        '/driver/history?period=all',
        '/driver/stats',
        '/driver/students/child-1',
        '/driver/profile',
        '/driver/settings',
        '/driver/contacts',
        '/driver/telemetry/today',
        '/driver/buses/bus-04',
      ]) {
        expect(await repo.request('GET', path), isNotNull, reason: path);
      }
      await repo.request('POST', '/driver/messages/parent-1', {
        'child_id': 'child-1',
        'message': 'On my way',
      });
      await repo.request('PUT', '/driver/profile', {
        'name': 'Updated',
        'phone': '0550123456',
        'locale': 'ar',
      });
      await repo.request('PUT', '/driver/settings', {
        'theme_palette': 'ocean-blue',
        'brightness_mode': 'dark',
      });
      expect(
        (await repo.request('GET', '/driver/settings'))['theme_palette'],
        'ocean-blue',
      );
      expect(
        (await repo.request('GET', '/driver/profile'))['user']['name'],
        'Updated',
      );
      expect(networkCalls, 1);
      expect(repo.isDemo, true);
    },
  );
  test('unavailable round 2 endpoint in live session stays an error', () async {
    final repo = DriverRepository(
      api: DriverApiClient(
        client: MockClient(
          (r) async => r.url.path.endsWith('/login')
              ? http.Response('{"token":"live","user":{"role":"driver"}}', 200)
              : http.Response('{"message":"not deployed"}', 404),
        ),
      ),
    );
    addTearDown(repo.close);
    await repo.login('ahmed.benali@mail.dz', 'Password123!');
    for (final path in [
      '/driver/settings',
      '/driver/students/child-1',
      '/driver/contacts',
    ]) {
      await expectLater(
        repo.request('GET', path),
        throwsA(isA<ApiFailure>().having((e) => e.status, 'status', 404)),
      );
    }
    expect(repo.isDemo, false);
  });
  test('a live session never falls back during a failed trip write', () async {
    var loggedIn = false;
    final repo = DriverRepository(
      api: DriverApiClient(
        client: MockClient((r) async {
          if (!loggedIn) {
            loggedIn = true;
            return http.Response(
              '{"token":"live","user":{"role":"driver"}}',
              200,
            );
          }
          throw http.ClientException('Disconnected');
        }),
      ),
    );
    addTearDown(repo.close);
    await repo.login('ahmed.benali@mail.dz', 'Password123!');
    await expectLater(
      repo.request('POST', '/driver/trips/live/boarding', {
        'student_code': 'HB-2026-9911',
        'type': 'boarded',
        'method': 'qr',
      }),
      throwsA(isA<ApiUnreachable>()),
    );
    expect(repo.isDemo, false);
  });
  test('unreachable server permits only seeded demo credentials', () async {
    final api = DriverApiClient(
      client: MockClient((_) async => throw http.ClientException('refused')),
    );
    final repo = DriverRepository(api: api);
    addTearDown(repo.close);
    await expectLater(
      repo.login('parent@mail.dz', 'Password123!'),
      throwsA(isA<ApiFailure>()),
    );
    expect(repo.isDemo, false);
    await repo.login('ahmed.benali@mail.dz', 'Password123!');
    expect(repo.isDemo, true);
    expect((await repo.request('GET', '/driver/buses') as List).length, 4);
    final trips = await repo.request('GET', '/driver/trips/today') as List;
    expect(trips.first['status'], 'scheduled');
    await expectLater(
      repo.request('POST', '/driver/trips/demo-morning/start'),
      throwsA(isA<ApiFailure>()),
    );
  });
  for (final status in [401, 403, 409, 422, 500]) {
    test('HTTP $status never activates demo fallback', () async {
      final repo = DriverRepository(
        api: DriverApiClient(
          client: MockClient(
            (_) async =>
                http.Response(jsonEncode({'message': 'failed'}), status),
          ),
        ),
      );
      addTearDown(repo.close);
      await expectLater(
        repo.login('ahmed.benali@mail.dz', 'Password123!'),
        throwsA(isA<ApiFailure>().having((e) => e.status, 'status', status)),
      );
      expect(repo.isDemo, false);
    });
  }
  test('driver role, bearer header, Arabic and array response', () async {
    final requests = <http.Request>[];
    final repo = DriverRepository(
      api: DriverApiClient(
        client: MockClient((r) async {
          requests.add(r);
          return http.Response(
            jsonEncode(
              r.url.path.endsWith('login')
                  ? {
                      'token': 'secret',
                      'user': {'role': 'driver'},
                    }
                  : [],
            ),
            200,
          );
        }),
      ),
    );
    addTearDown(repo.close);
    repo.api.language = 'ar';
    await repo.login('driver', 'pw');
    expect(await repo.request('GET', '/driver/trips/today'), isEmpty);
    expect(requests.first.url.path, '/api/v1/driver/auth/login');
    expect(requests.last.headers['Authorization'], 'Bearer secret');
    expect(requests.last.headers['Accept-Language'], 'ar');
  });
  test('parent role from login is rejected', () async {
    final repo = DriverRepository(
      api: DriverApiClient(
        client: MockClient(
          (r) async =>
              http.Response('{"token":"parent","user":{"role":"parent"}}', 200),
        ),
      ),
    );
    addTearDown(repo.close);
    await expectLater(
      repo.login('parent', 'pw'),
      throwsA(isA<ApiFailure>().having((e) => e.status, 'status', 403)),
    );
    expect(repo.api.token, isNull);
  });
}
