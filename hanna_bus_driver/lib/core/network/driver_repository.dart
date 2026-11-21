import '../state/demo_seed.dart';
import '../state/models.dart';
import 'driver_api_client.dart';

class DriverRepository {
  DriverRepository({DriverApiClient? api}) : api = api ?? DriverApiClient();
  final DriverApiClient api;
  DemoSeed? _demo;
  bool serverUnreachable = false;
  bool get isDemo => _demo != null;
  Future<void> login(String email, String password) async {
    _demo = null;
    serverUnreachable = false;
    api.token = null;
    try {
      final result = await api.request('POST', '/driver/auth/login', {
        'email': email.trim(),
        'password': password,
      });
      if (result['user']['role'] != 'driver') throw const ApiFailure(403);
      api.token = result['token'];
    } on ApiUnreachable {
      serverUnreachable = true;
      if (email.trim().toLowerCase() != 'ahmed.benali@mail.dz' ||
          password != 'Password123!') {
        throw const ApiFailure(401);
      }
      _demo = DemoSeed();
      api.token = null;
    }
  }

  Future<dynamic> request(String method, String path, [Json? body]) async {
    if (_demo != null) {
      try {
        return _demo!.request(method, path, body);
      } on DemoFailure catch (e) {
        throw ApiFailure(e.status);
      }
    }
    return api.request(method, path, body);
  }

  Future<void> logout() async {
    await request('POST', '/auth/logout');
    api.token = null;
    _demo = null;
  }

  void close() => api.close();
}
