import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/hanna_api_client.dart';
import '../theme/hanna_tokens.dart';
import 'demo_seed.dart';
import 'models.dart';

class AppStateController extends ChangeNotifier {
  AppStateController({HannaApiClient? apiClient})
      : api = apiClient ?? HannaApiClient();

  final HannaApiClient api;

  static const _kPaletteKey = 'hanna_palette';
  static const _kBrightnessKey = 'hanna_brightness';
  static const _kLocaleKey = 'hanna_locale';
  static const _kOnboardingKey = 'hanna_onboarding_complete';
  static const _kQrChildIdKey = 'hanna_cached_qr_child_id';
  static const _kQrChildNameKey = 'hanna_cached_qr_child_name';
  static const _kQrCodeKey = 'hanna_cached_qr_code';
  static const _kQrSchoolKey = 'hanna_cached_qr_school';
  static const _kQrBusKey = 'hanna_cached_qr_bus';
  static const _kQrStopKey = 'hanna_cached_qr_stop';
  static const _kQrPayloadKey = 'hanna_cached_qr_payload';

  HannaPalette _palette = HannaPalette.mustard;
  Brightness _brightness = Brightness.light;
  Locale _locale = const Locale('en');
  bool _onboardingComplete = false;
  bool _isAuthenticated = false;
  bool _isOfflineDemoMode = false;
  bool _isBusy = false;
  String? _lastError;

  ParentUser? _user;
  List<ChildProfile> _children = [];
  String? _selectedChildId;
  ActiveTripData? _activeTrip;
  List<TripHistorySummary> _tripHistory = [];
  AttendanceAnalyticsData? _analytics;
  List<SafetyNotificationItem> _notifications = [];
  List<SchoolBulletinItem> _bulletins = [];
  List<EmergencyContactItem> _emergencyContacts = DemoSeed.emergencyContacts;
  TransitAlertSettings _alertSettings = const TransitAlertSettings();
  CachedQrPassSnapshot? _cachedQrPass;

  HannaPalette get palette => _palette;
  Brightness get brightness => _brightness;
  Locale get locale => _locale;
  bool get onboardingComplete => _onboardingComplete;
  bool get isAuthenticated => _isAuthenticated;
  bool get isOfflineDemoMode => _isOfflineDemoMode;
  bool get isBusy => _isBusy;
  String? get lastError => _lastError;

  ParentUser get currentUser =>
      _user ??
      DemoSeed.demoUser.copyWith(
        palette: _palette,
        brightness: _brightness,
        locale: _locale,
      );

  List<ChildProfile> get children => List.unmodifiable(_children);

  ChildProfile? get selectedChild {
    if (_children.isEmpty) return null;
    if (_selectedChildId != null) {
      for (final c in _children) {
        if (c.id == _selectedChildId) return c;
      }
    }
    return _children.first;
  }

  ActiveTripData? get activeTrip => _activeTrip;
  List<TripHistorySummary> get tripHistory => List.unmodifiable(_tripHistory);
  AttendanceAnalyticsData? get analytics => _analytics;
  List<SafetyNotificationItem> get notifications => List.unmodifiable(_notifications);
  List<SchoolBulletinItem> get bulletins => List.unmodifiable(_bulletins);
  List<EmergencyContactItem> get emergencyContacts =>
      List.unmodifiable(_emergencyContacts);
  TransitAlertSettings get alertSettings => _alertSettings;
  CachedQrPassSnapshot? get cachedQrPass => _cachedQrPass;

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _palette = HannaPalette.fromApi(prefs.getString(_kPaletteKey));
    final bStr = prefs.getString(_kBrightnessKey);
    _brightness = bStr == 'dark' ? Brightness.dark : Brightness.light;
    final lStr = prefs.getString(_kLocaleKey) ?? 'en';
    _locale = Locale(['en', 'ar', 'fr'].contains(lStr) ? lStr : 'en');
    api.localeCode = _locale.languageCode;
    _onboardingComplete = prefs.getBool(_kOnboardingKey) ?? false;

    final qrName = prefs.getString(_kQrChildNameKey);
    if (qrName != null && qrName.isNotEmpty) {
      _cachedQrPass = CachedQrPassSnapshot(
        childId: prefs.getString(_kQrChildIdKey) ?? 'c-youssef',
        childName: qrName,
        studentCode: prefs.getString(_kQrCodeKey) ?? 'HB-304',
        schoolName: prefs.getString(_kQrSchoolKey) ?? 'El-Feth International School',
        busNumber: prefs.getString(_kQrBusKey) ?? '04',
        stopName: prefs.getString(_kQrStopKey) ?? 'Hydra North - Stop 04',
        qrPayload: prefs.getString(_kQrPayloadKey) ?? 'HANNA-BUS|HB-304|BUS04',
      );
    }
    notifyListeners();
  }

  Future<void> markOnboardingComplete() async {
    _onboardingComplete = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingKey, true);
    notifyListeners();
  }

  Future<void> setPalette(HannaPalette next) async {
    _palette = next;
    _user = _user?.copyWith(palette: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPaletteKey, next.apiValue);
    notifyListeners();
    if (_isAuthenticated && !_isOfflineDemoMode) {
      try {
        await api.updatePreferences(themePalette: next.apiValue);
      } catch (_) {}
    }
  }

  Future<void> setBrightness(Brightness next) async {
    _brightness = next;
    _user = _user?.copyWith(brightness: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBrightnessKey, next == Brightness.dark ? 'dark' : 'light');
    notifyListeners();
    if (_isAuthenticated && !_isOfflineDemoMode) {
      try {
        await api.updatePreferences(
          brightnessMode: next == Brightness.dark ? 'dark' : 'light',
        );
      } catch (_) {}
    }
  }

  Future<void> setLocale(Locale next) async {
    _locale = next;
    api.localeCode = next.languageCode;
    _user = _user?.copyWith(locale: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, next.languageCode);
    if (_isOfflineDemoMode) {
      _loadDemoWorkspaceCollections();
    } else if (_isAuthenticated) {
      try {
        await api.updatePreferences(locale: next.languageCode);
        await refreshDashboardData();
      } catch (_) {
        _loadDemoWorkspaceCollections();
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isBusy = true;
    _lastError = null;
    notifyListeners();

    try {
      final session = await api.login(email: email.trim(), password: password);
      _user = session.user;
      _isAuthenticated = true;
      _isOfflineDemoMode = false;
      await _syncUserPreferencesFromServer(session.user);
      await refreshDashboardData();
      _isBusy = false;
      notifyListeners();
      return true;
    } on ApiUnreachableException {
      await _activateDemoSession(email: email.trim());
      _isBusy = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _lastError = e.message;
      _isBusy = false;
      notifyListeners();
      return false;
    } on ApiValidationException catch (e) {
      _lastError = e.message;
      _isBusy = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isBusy = true;
    _lastError = null;
    notifyListeners();

    try {
      final session = await api.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
        phone: phone.trim(),
        locale: _locale.languageCode,
      );
      _user = session.user;
      _isAuthenticated = true;
      _isOfflineDemoMode = false;
      _children = [];
      await refreshDashboardData();
      _isBusy = false;
      notifyListeners();
      return true;
    } on ApiUnreachableException {
      await _activateDemoSession(
        email: email.trim(),
        customName: name.trim(),
        customPhone: phone.trim(),
      );
      _isBusy = false;
      notifyListeners();
      return true;
    } on ApiValidationException catch (e) {
      _lastError = e.message;
      _isBusy = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _lastError = e.message;
      _isBusy = false;
      notifyListeners();
      return false;
    }
  }

  Future<String> requestPasswordResetOtp(String email) async {
    try {
      return await api.forgotPassword(email.trim());
    } on ApiUnreachableException {
      return '482910';
    }
  }

  Future<String?> verifyPasswordOtp(String email, String code) async {
    try {
      return await api.verifyOtp(email: email.trim(), code: code.trim());
    } on ApiUnreachableException {
      return code.trim() == '482910' ? 'offline-reset-token' : null;
    } catch (e) {
      _lastError = e.toString();
      return null;
    }
  }

  Future<bool> completePasswordReset({
    required String email,
    required String resetToken,
    required String password,
  }) async {
    try {
      final session = await api.resetPassword(
        email: email.trim(),
        resetToken: resetToken,
        password: password,
      );
      _user = session.user;
      _isAuthenticated = true;
      _isOfflineDemoMode = false;
      await refreshDashboardData();
      notifyListeners();
      return true;
    } on ApiUnreachableException {
      await _activateDemoSession(email: email.trim());
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _activateDemoSession({
    String? email,
    String? customName,
    String? customPhone,
  }) async {
    _isOfflineDemoMode = true;
    _isAuthenticated = true;
    _user = DemoSeed.demoUser.copyWith(
      email: (email != null && email.isNotEmpty) ? email : DemoSeed.demoUser.email,
      name: (customName != null && customName.isNotEmpty) ? customName : DemoSeed.demoUser.name,
      phone: (customPhone != null && customPhone.isNotEmpty) ? customPhone : DemoSeed.demoUser.phone,
      palette: _palette,
      brightness: _brightness,
      locale: _locale,
    );
    _children = List<ChildProfile>.from(DemoSeed.children);
    _selectedChildId = _children.isNotEmpty ? _children.first.id : null;
    _loadDemoWorkspaceCollections();
    await _cacheQrSnapshotForSelectedChild();
  }

  void _loadDemoWorkspaceCollections() {
    _activeTrip = DemoSeed.activeTrip(_locale);
    _tripHistory = DemoSeed.tripHistory(_locale);
    final active = selectedChild;
    if (active != null) {
      _analytics = DemoSeed.analytics(active.id, active.fullName);
    }
    _notifications = DemoSeed.notifications(_locale);
    _bulletins = DemoSeed.bulletins(_locale);
    _emergencyContacts = DemoSeed.emergencyContacts;
  }

  Future<void> _syncUserPreferencesFromServer(ParentUser u) async {
    _palette = u.palette;
    _brightness = u.brightness;
    _locale = u.locale;
    api.localeCode = u.locale.languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPaletteKey, _palette.apiValue);
    await prefs.setString(_kBrightnessKey, _brightness == Brightness.dark ? 'dark' : 'light');
    await prefs.setString(_kLocaleKey, _locale.languageCode);
  }

  Future<void> refreshDashboardData() async {
    if (_isOfflineDemoMode) {
      _loadDemoWorkspaceCollections();
      notifyListeners();
      return;
    }
    try {
      final kids = await api.getChildren();
      _children = kids;
      if (_children.isNotEmpty) {
        if (_selectedChildId == null || !_children.any((c) => c.id == _selectedChildId)) {
          _selectedChildId = _children.first.id;
        }
      } else {
        _selectedChildId = null;
      }
      final childId = selectedChild?.id;
      final results = await Future.wait([
        api.getActiveTrip(childId: childId),
        api.getTripHistory(childId: childId),
        api.getNotifications(),
        api.getBulletins(),
        api.getAlerts(),
        api.getEmergencyContacts(),
        if (childId != null) api.getAnalytics(childId),
      ]);
      _activeTrip = results[0] as ActiveTripData;
      _tripHistory = results[1] as List<TripHistorySummary>;
      _notifications = results[2] as List<SafetyNotificationItem>;
      _bulletins = results[3] as List<SchoolBulletinItem>;
      _alertSettings = results[4] as TransitAlertSettings;
      _emergencyContacts = results[5] as List<EmergencyContactItem>;
      if (childId != null && results.length > 6) {
        _analytics = results[6] as AttendanceAnalyticsData;
      }
      await _cacheQrSnapshotForSelectedChild();
      notifyListeners();
    } on ApiUnreachableException {
      _isOfflineDemoMode = true;
      if (_children.isEmpty) {
        _children = List<ChildProfile>.from(DemoSeed.children);
        _selectedChildId = _children.first.id;
      }
      _loadDemoWorkspaceCollections();
      await _cacheQrSnapshotForSelectedChild();
      notifyListeners();
    } catch (_) {
      // Keep current cached data if partial call fails.
    }
  }

  Future<void> _cacheQrSnapshotForSelectedChild() async {
    final c = selectedChild;
    if (c == null) return;
    final payload = 'HANNA-BUS|${c.studentCode}|BUS-${c.busNumber}|${c.fullName}';
    _cachedQrPass = CachedQrPassSnapshot(
      childId: c.id,
      childName: c.fullName,
      studentCode: c.studentCode,
      schoolName: c.schoolName,
      busNumber: c.busNumber,
      stopName: c.stopName,
      qrPayload: payload,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kQrChildIdKey, c.id);
    await prefs.setString(_kQrChildNameKey, c.fullName);
    await prefs.setString(_kQrCodeKey, c.studentCode);
    await prefs.setString(_kQrSchoolKey, c.schoolName);
    await prefs.setString(_kQrBusKey, c.busNumber);
    await prefs.setString(_kQrStopKey, c.stopName);
    await prefs.setString(_kQrPayloadKey, payload);
  }

  Future<void> selectChild(String childId) async {
    _selectedChildId = childId;
    final active = selectedChild;
    if (active != null) {
      _analytics = DemoSeed.analytics(active.id, active.fullName);
    }
    await _cacheQrSnapshotForSelectedChild();
    notifyListeners();
    if (!_isOfflineDemoMode && _isAuthenticated) {
      try {
        _activeTrip = await api.getActiveTrip(childId: childId);
        _analytics = await api.getAnalytics(childId);
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<ChildProfile?> linkChildByCode({
    required String studentCode,
    String? fullName,
    String? schoolName,
    String? grade,
    String? busNumber,
    String? stopName,
  }) async {
    final code = studentCode.trim().toUpperCase();
    if (code.isEmpty) return null;

    if (!_isOfflineDemoMode) {
      try {
        final linked = await api.linkChild(
          studentCode: code,
          fullName: fullName,
          schoolName: schoolName,
          grade: grade,
          busNumber: busNumber,
          stopName: stopName,
        );
        _children = [..._children.where((e) => e.id != linked.id), linked];
        _selectedChildId = linked.id;
        notifyListeners();
        return linked;
      } on ApiUnreachableException {
        _isOfflineDemoMode = true;
      }
    }

    final ChildProfile fallback = code == 'HB-2026-9911'
        ? DemoSeed.linkableLina
        : DemoSeed.linkableLina.copyWith(
            studentCode: code,
            fullName: (fullName != null && fullName.isNotEmpty) ? fullName : 'Student $code',
            schoolName: (schoolName != null && schoolName.isNotEmpty)
                ? schoolName
                : 'El-Feth International School',
            grade: (grade != null && grade.isNotEmpty) ? grade : 'Grade 3',
            busNumber: (busNumber != null && busNumber.isNotEmpty) ? busNumber : '04',
            stopName: (stopName != null && stopName.isNotEmpty)
                ? stopName
                : 'Hydra North - Stop 04',
          );
    _children = [..._children.where((e) => e.studentCode != code), fallback];
    _selectedChildId = fallback.id;
    await _cacheQrSnapshotForSelectedChild();
    notifyListeners();
    return fallback;
  }

  Future<ChildProfile> saveChild({
    String? existingId,
    required String fullName,
    required String studentCode,
    required String schoolName,
    required String grade,
    required String busNumber,
    required String stopName,
    required String allergies,
    required String dismissalRule,
  }) async {
    if (existingId != null && !_isOfflineDemoMode) {
      try {
        final updated = await api.updateChild(existingId, {
          'full_name': fullName,
          'school_name': schoolName,
          'grade': grade,
          'bus_number': busNumber,
          'stop_name': stopName,
          'allergies': allergies,
          'dismissal_rule': dismissalRule,
        });
        _children = _children.map((c) => c.id == existingId ? updated : c).toList();
        notifyListeners();
        return updated;
      } on ApiUnreachableException {
        _isOfflineDemoMode = true;
      }
    } else if (existingId == null && !_isOfflineDemoMode) {
      try {
        final created = await api.createChild({
          'full_name': fullName,
          'student_code': studentCode,
          'school_name': schoolName,
          'grade': grade,
          'bus_number': busNumber,
          'stop_name': stopName,
          'allergies': allergies,
          'dismissal_rule': dismissalRule,
        });
        _children = [..._children, created];
        _selectedChildId = created.id;
        notifyListeners();
        return created;
      } on ApiUnreachableException {
        _isOfflineDemoMode = true;
      }
    }

    if (existingId != null) {
      late ChildProfile edited;
      _children = _children.map((c) {
        if (c.id != existingId) return c;
        edited = c.copyWith(
          fullName: fullName,
          studentCode: studentCode,
          schoolName: schoolName,
          grade: grade,
          busNumber: busNumber,
          stopName: stopName,
          allergies: allergies,
          dismissalRule: dismissalRule,
        );
        return edited;
      }).toList();
      notifyListeners();
      return edited;
    }

    final created = DemoSeed.linkableLina.copyWith(
      studentCode: studentCode,
      fullName: fullName,
      schoolName: schoolName,
      grade: grade,
      busNumber: busNumber,
      stopName: stopName,
      allergies: allergies,
      dismissalRule: dismissalRule,
    );
    _children = [..._children, created];
    _selectedChildId = created.id;
    notifyListeners();
    return created;
  }

  Future<void> removeChild(String childId) async {
    if (!_isOfflineDemoMode) {
      try {
        await api.deleteChild(childId);
      } catch (_) {}
    }
    _children = _children.where((c) => c.id != childId).toList();
    if (_selectedChildId == childId) {
      _selectedChildId = _children.isNotEmpty ? _children.first.id : null;
    }
    notifyListeners();
  }

  Future<void> reportAbsence(String childId, {String? reason}) async {
    if (!_isOfflineDemoMode) {
      try {
        await api.reportAbsence(childId: childId, reason: reason);
      } on ApiUnreachableException {
        _isOfflineDemoMode = true;
      }
    }
    _children = _children
        .map((c) => c.id == childId ? c.copyWith(transitStatus: 'absent') : c)
        .toList();
    notifyListeners();
  }

  Future<void> resumeRideToday(String childId) async {
    if (!_isOfflineDemoMode) {
      try {
        await api.cancelAbsenceToday(childId);
      } on ApiUnreachableException {
        _isOfflineDemoMode = true;
      }
    }
    _children = _children
        .map((c) => c.id == childId ? c.copyWith(transitStatus: 'at_home') : c)
        .toList();
    notifyListeners();
  }

  Future<TripHistorySummary> loadTripReplay(String tripId) async {
    if (!_isOfflineDemoMode) {
      try {
        return await api.getTripDetail(tripId);
      } catch (_) {}
    }
    return _tripHistory.firstWhere(
      (t) => t.id == tripId,
      orElse: () => DemoSeed.tripHistory(_locale).first,
    );
  }

  Future<void> markNotificationRead(int id) async {
    _notifications = _notifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    notifyListeners();
    if (!_isOfflineDemoMode) {
      try {
        await api.markNotificationRead(id);
      } catch (_) {}
    }
  }

  Future<void> markAllNotificationsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    if (!_isOfflineDemoMode) {
      try {
        await api.markAllNotificationsRead();
      } catch (_) {}
    }
  }

  Future<bool> sendSupportMessage({
    required String recipientType,
    String? childId,
    required String message,
  }) async {
    if (!_isOfflineDemoMode) {
      try {
        await api.sendSupportMessage(
          recipientType: recipientType,
          childId: childId,
          message: message,
        );
        return true;
      } on ApiUnreachableException {
        _isOfflineDemoMode = true;
        return true;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String backupPhone,
    required String primaryBusStop,
  }) async {
    if (!_isOfflineDemoMode) {
      try {
        _user = await api.updateProfile({
          'name': name,
          'email': email,
          'phone': phone,
          'backup_phone': backupPhone,
          'primary_bus_stop': primaryBusStop,
        });
        notifyListeners();
        return;
      } on ApiUnreachableException {
        _isOfflineDemoMode = true;
      }
    }
    _user = currentUser.copyWith(
      name: name,
      email: email,
      phone: phone,
      backupPhone: backupPhone,
      primaryBusStop: primaryBusStop,
    );
    notifyListeners();
  }

  Future<void> updateAlertSettings(TransitAlertSettings next) async {
    _alertSettings = next;
    notifyListeners();
    if (!_isOfflineDemoMode) {
      try {
        _alertSettings = await api.updateAlerts(next);
        notifyListeners();
      } on ApiUnreachableException {
        _isOfflineDemoMode = true;
      } catch (_) {}
    }
  }

  Future<void> logout() async {
    if (!_isOfflineDemoMode) {
      try {
        await api.logout();
      } catch (_) {}
    }
    _isAuthenticated = false;
    _isOfflineDemoMode = false;
    _user = null;
    notifyListeners();
  }

  Future<bool> deleteAccount(String confirmation) async {
    final normalized = confirmation.trim();
    if (!['DELETE', 'حذف', 'SUPPRIMER'].contains(normalized)) {
      return false;
    }
    if (!_isOfflineDemoMode) {
      try {
        await api.deleteAccount(normalized);
      } on ApiUnreachableException {
        _isOfflineDemoMode = true;
      } catch (_) {
        return false;
      }
    }
    _isAuthenticated = false;
    _isOfflineDemoMode = false;
    _user = null;
    _children = [];
    notifyListeners();
    return true;
  }
}

class AppStateScope extends InheritedNotifier<AppStateController> {
  const AppStateScope({
    super.key,
    required AppStateController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppStateController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in widget tree');
    return scope!.notifier!;
  }
}
