import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

/// Registers/unregisters this device's push token with the backend.
///
/// Degrades silently when Firebase isn't configured (no google-services.json
/// / GoogleService-Info.plist yet) — push is optional, the in-app
/// notification list works via polling regardless.
class DeviceService {
  DeviceService._();
  static final DeviceService instance = DeviceService._();

  static const _tokenKey = 'push_token';

  final _api = ApiClient.instance;
  bool _listening = false;

  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  Future<void> registerCurrentDevice() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _api.post(
        '/api/user/me/devices',
        body: {'platform': _platform, 'pushToken': token},
        auth: true,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      _listenForTokenRefresh();
    } catch (_) {
      // Push registration is best-effort — never block the caller.
    }
  }

  Future<void> unregisterCurrentDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null) return;
      await _api.delete('/api/user/me/devices', body: {'pushToken': token});
      await prefs.remove(_tokenKey);
    } catch (_) {
      // Best-effort — logout should proceed regardless.
    }
  }

  void _listenForTokenRefresh() {
    if (_listening) return;
    _listening = true;
    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      registerCurrentDevice();
    });
  }
}
