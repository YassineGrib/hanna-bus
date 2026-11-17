import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hanna_bus_parent/core/network/hanna_api_client.dart';

void main() {
  group('HannaApiClient', () {
    test('login parses Sanctum token and ParentUser from Laravel response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/auth/login'));
        expect(request.method, equals('POST'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], equals('k.mansouri@mail.dz'));
        return http.Response(
          jsonEncode({
            'token': 'sanctum-token-123',
            'user': {
              'id': 1,
              'name': 'Karim Mansouri',
              'email': 'k.mansouri@mail.dz',
              'phone': '+213 551 22 33 44',
              'primary_bus_stop': 'Hydra North - Stop 04',
              'theme_palette': 'mustard',
              'brightness_mode': 'light',
              'locale': 'en',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = HannaApiClient(
        baseUrl: 'http://127.0.0.1:8000/api/v1',
        httpClient: mockClient,
      );

      final result = await api.login(
        email: 'k.mansouri@mail.dz',
        password: 'Password123!',
      );

      expect(result.token, equals('sanctum-token-123'));
      expect(result.user.name, equals('Karim Mansouri'));
      expect(result.user.locale.languageCode, equals('en'));
    });

    test('throws ApiUnreachableException when server cannot be reached', () async {
      final mockClient = MockClient((_) async {
        throw http.ClientException('Connection refused');
      });

      final api = HannaApiClient(
        baseUrl: 'http://127.0.0.1:8000/api/v1',
        httpClient: mockClient,
      );

      expect(
        () => api.login(email: 'k.mansouri@mail.dz', password: 'Password123!'),
        throwsA(isA<ApiUnreachableException>()),
      );
    });

    test('throws ApiValidationException with field errors on HTTP 422', () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'message': 'The selected student code is invalid.',
            'errors': {
              'student_code': ['Student code was not found.'],
            },
          }),
          422,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = HannaApiClient(
        baseUrl: 'http://127.0.0.1:8000/api/v1',
        httpClient: mockClient,
        token: 'tok',
      );

      expect(
        () => api.linkChild(studentCode: 'INVALID'),
        throwsA(isA<ApiValidationException>()),
      );
    });
  });
}
