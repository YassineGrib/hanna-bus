import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../state/models.dart';

class ApiFailure implements Exception {
  const ApiFailure(this.status, [this.message = '']);
  final int status;
  final String message;
}

class ApiUnreachable implements Exception {}

/// Transport only. Server errors never turn into a simulated successful write.
class DriverApiClient {
  DriverApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl =
          (baseUrl ??
                  const String.fromEnvironment(
                    'HANNA_API_URL',
                    defaultValue: 'http://127.0.0.1:8000/api/v1',
                  ))
              .replaceAll(RegExp(r'/$'), '');
  final http.Client _client;
  final String baseUrl;
  String? token;
  String language = 'en';

  Future<dynamic> request(String method, String path, [Json? body]) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'));
    request.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Accept-Language': language,
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (body != null) request.body = jsonEncode(body);
    late http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request),
      ).timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw ApiUnreachable();
    } on http.ClientException {
      throw ApiUnreachable();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = '';
      try {
        message = '${(jsonDecode(response.body) as Map)['message'] ?? ''}';
      } on FormatException {
        /* Localized status fallback in UI. */
      }
      throw ApiFailure(response.statusCode, message);
    }
    if (response.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(response.body);
    return decoded is Map && decoded.containsKey('data')
        ? decoded['data']
        : decoded;
  }

  void close() => _client.close();
}
