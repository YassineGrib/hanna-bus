import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../state/models.dart';

class ApiUnreachableException implements Exception {
  ApiUnreachableException(this.message);
  final String message;
  @override
  String toString() => 'ApiUnreachableException: $message';
}

class ApiValidationException implements Exception {
  ApiValidationException(this.message, [this.errors = const {}]);
  final String message;
  final Map<String, List<String>> errors;
  @override
  String toString() => 'ApiValidationException: $message';
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class AuthSessionResponse {
  AuthSessionResponse({required this.token, required this.user});
  final String token;
  final ParentUser user;
}

class HannaApiClient {
  HannaApiClient({
    String? baseUrl,
    http.Client? httpClient,
    this.token,
    this.localeCode = 'en',
  }) : baseUrl =
           (baseUrl ??
                   const String.fromEnvironment(
                     'HANNA_API_URL',
                     defaultValue: 'http://127.0.0.1:8000/api/v1',
                   ))
               .replaceAll(RegExp(r'/$'), ''),
       _client = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  String? token;
  String localeCode;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': localeCode,
    if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    late http.Response response;
    try {
      final encoded = body != null ? jsonEncode(body) : null;
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: _headers)
              .timeout(const Duration(seconds: 4));
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: _headers, body: encoded)
              .timeout(const Duration(seconds: 4));
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: _headers, body: encoded)
              .timeout(const Duration(seconds: 4));
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: _headers, body: encoded)
              .timeout(const Duration(seconds: 4));
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method: $method');
      }
    } on TimeoutException catch (e) {
      throw ApiUnreachableException('Request timed out: $e');
    } on Exception catch (e) {
      throw ApiUnreachableException('Backend unavailable: $e');
    }

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode == 422) {
      final rawErrors = decoded is Map ? decoded['errors'] : null;
      final parsedErrors = <String, List<String>>{};
      if (rawErrors is Map) {
        rawErrors.forEach((k, v) {
          if (v is List) {
            parsedErrors[k.toString()] = v.map((e) => e.toString()).toList();
          }
        });
      }
      final msg = decoded is Map ? decoded['message'] : null;
      throw ApiValidationException(
        (msg ?? 'Validation failed').toString(),
        parsedErrors,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = decoded is Map ? decoded['message'] : null;
      throw ApiException(
        response.statusCode,
        (msg ?? 'HTTP ${response.statusCode}').toString(),
      );
    }

    return decoded;
  }

  Future<AuthSessionResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await _request(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    token = res['token']?.toString();
    return AuthSessionResponse(
      token: token ?? '',
      user: ParentUser.fromJson(Map<String, dynamic>.from(res['user'] as Map)),
    );
  }

  Future<AuthSessionResponse> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String locale,
  }) async {
    final res = await _request(
      'POST',
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'locale': locale,
      },
    );
    token = res['token']?.toString();
    return AuthSessionResponse(
      token: token ?? '',
      user: ParentUser.fromJson(Map<String, dynamic>.from(res['user'] as Map)),
    );
  }

  Future<String> forgotPassword(String email) async {
    final res = await _request(
      'POST',
      '/auth/forgot-password',
      body: {'email': email},
    );
    return (res['demo_otp'] ?? '482910').toString();
  }

  Future<String> verifyOtp({
    required String email,
    required String code,
  }) async {
    final res = await _request(
      'POST',
      '/auth/verify-otp',
      body: {'email': email, 'code': code},
    );
    return (res['reset_token'] ?? '').toString();
  }

  Future<AuthSessionResponse> resetPassword({
    required String email,
    required String resetToken,
    required String password,
  }) async {
    final res = await _request(
      'POST',
      '/auth/reset-password',
      body: {
        'email': email,
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': password,
      },
    );
    token = res['token']?.toString();
    return AuthSessionResponse(
      token: token ?? '',
      user: ParentUser.fromJson(Map<String, dynamic>.from(res['user'] as Map)),
    );
  }

  Future<void> logout() async {
    try {
      await _request('POST', '/auth/logout');
    } finally {
      token = null;
    }
  }

  Future<ParentUser> getProfile() async {
    final res = await _request('GET', '/parent/profile');
    return ParentUser.fromJson(res);
  }

  Future<ParentUser> updateProfile(Map<String, dynamic> fields) async {
    final res = await _request('PUT', '/parent/profile', body: fields);
    return ParentUser.fromJson(res);
  }

  Future<void> updatePreferences({
    String? themePalette,
    String? brightnessMode,
    String? locale,
  }) async {
    await _request(
      'PUT',
      '/parent/settings/preferences',
      body: {
        'theme_palette': ?themePalette,
        'brightness_mode': ?brightnessMode,
        'locale': ?locale,
      },
    );
  }

  Future<TransitAlertSettings> getAlerts() async {
    final res = await _request('GET', '/parent/settings/alerts');
    return TransitAlertSettings.fromJson(res);
  }

  Future<TransitAlertSettings> updateAlerts(
    TransitAlertSettings settings,
  ) async {
    final res = await _request(
      'PUT',
      '/parent/settings/alerts',
      body: settings.toJson(),
    );
    return TransitAlertSettings.fromJson(res);
  }

  Future<List<EmergencyContactItem>> getEmergencyContacts() async {
    final res = await _request('GET', '/parent/emergency-contacts');
    return (res['data'] as List? ?? [])
        .whereType<Map>()
        .map((e) => EmergencyContactItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<ChildProfile>> getChildren() async {
    final res = await _request('GET', '/parent/children');
    return (res['data'] as List? ?? [])
        .whereType<Map>()
        .map((e) => ChildProfile.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ChildProfile> createChild(Map<String, dynamic> payload) async {
    final res = await _request('POST', '/parent/children', body: payload);
    return ChildProfile.fromJson(res);
  }

  Future<ChildProfile> updateChild(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await _request('PUT', '/parent/children/$id', body: payload);
    return ChildProfile.fromJson(res);
  }

  Future<void> deleteChild(String id) async {
    await _request('DELETE', '/parent/children/$id');
  }

  Future<ChildProfile> linkChild({
    required String studentCode,
    String? fullName,
    String? schoolName,
    String? grade,
    String? busNumber,
    String? stopName,
  }) async {
    final res = await _request(
      'POST',
      '/parent/children/link',
      body: {
        'student_code': studentCode,
        if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
        if (schoolName != null && schoolName.isNotEmpty)
          'school_name': schoolName,
        if (grade != null && grade.isNotEmpty) 'grade': grade,
        if (busNumber != null && busNumber.isNotEmpty) 'bus_number': busNumber,
        if (stopName != null && stopName.isNotEmpty) 'stop_name': stopName,
      },
    );
    return ChildProfile.fromJson(res);
  }

  Future<void> reportAbsence({required String childId, String? reason}) async {
    await _request(
      'POST',
      '/parent/attendance/absences',
      body: {
        'child_id': childId,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
  }

  Future<void> cancelAbsenceToday(String childId) async {
    await _request('DELETE', '/parent/attendance/absences/$childId/today');
  }

  Future<AttendanceAnalyticsData> getAnalytics(String childId) async {
    final res = await _request(
      'GET',
      '/parent/attendance/analytics?child_id=$childId',
    );
    return AttendanceAnalyticsData.fromJson(res);
  }

  Future<ActiveTripData?> getActiveTrip({String? childId}) async {
    final query = childId != null ? '?child_id=$childId' : '';
    try {
      final res = await _request('GET', '/parent/tracking/active-trip$query');
      if (res is Map) {
        return ActiveTripData.fromJson(Map<String, dynamic>.from(res));
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<TripHistorySummary>> getTripHistory({
    String? childId,
    String period = 'all',
  }) async {
    final params = <String>[
      if (childId != null && childId.isNotEmpty) 'child_id=$childId',
      if (period.isNotEmpty) 'period=$period',
    ];
    final suffix = params.isNotEmpty ? '?${params.join('&')}' : '';
    final res = await _request('GET', '/parent/tracking/history$suffix');
    return (res['trips'] as List? ?? [])
        .whereType<Map>()
        .map((e) => TripHistorySummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<TripHistorySummary> getTripDetail(String id) async {
    final res = await _request('GET', '/parent/tracking/trips/$id');
    return TripHistorySummary.fromJson(res);
  }

  Future<List<SafetyNotificationItem>> getNotifications() async {
    final res = await _request('GET', '/parent/notifications');
    return (res['data'] as List? ?? [])
        .whereType<Map>()
        .map(
          (e) => SafetyNotificationItem.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<void> markNotificationRead(int id) async {
    await _request('PUT', '/parent/notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _request('PUT', '/parent/notifications/read-all');
  }

  Future<List<SchoolBulletinItem>> getBulletins() async {
    final res = await _request('GET', '/parent/bulletins');
    return (res['data'] as List? ?? [])
        .whereType<Map>()
        .map((e) => SchoolBulletinItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<DriverMessageItem>> getSupportMessages() async {
    final res = await _request('GET', '/parent/support/messages');
    List<dynamic> list;
    if (res is List) {
      list = res;
    } else if (res is Map && res['data'] is List) {
      list = res['data'] as List;
    } else if (res is Map && res['messages'] is List) {
      list = res['messages'] as List;
    } else {
      list = [];
    }
    return list
        .whereType<Map>()
        .map((e) => DriverMessageItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> markSupportMessageRead(String id) async {
    await _request('PUT', '/parent/support/messages/$id/read');
  }

  Future<void> sendSupportMessage({
    required String recipientType,
    String? childId,
    required String message,
  }) async {
    await _request(
      'POST',
      '/parent/support/messages',
      body: {
        'recipient_type': recipientType,
        'child_id': ?childId,
        'message': message,
      },
    );
  }

  Future<void> deleteAccount(String confirmation) async {
    await _request(
      'DELETE',
      '/parent/account',
      body: {'confirmation': confirmation},
    );
    token = null;
  }
}
