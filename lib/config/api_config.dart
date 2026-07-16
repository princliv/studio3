import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Backend base URL — keep in sync with `.env` `NEXT_PUBLIC_API_URL`.
///
/// Emulators/simulators resolve automatically below. For a **physical
/// device**, phone and PC must be on the same Wi-Fi network, and you must
/// pass your PC's LAN IP explicitly (it can't be inferred), e.g.:
///   flutter run --dart-define=API_HOST=10.202.105.236
abstract final class ApiConfig {
  static const int port = 9000;

  /// Set via `--dart-define=API_HOST=<lan-ip>` for a physical device; empty
  /// otherwise, in which case the platform default below applies.
  static const String _hostOverride = String.fromEnvironment('API_HOST');

  static String get baseUrl {
    if (_hostOverride.isNotEmpty) return 'http://$_hostOverride:$port';
    if (kIsWeb) return 'http://localhost:$port';
    // The Android emulator (AVD) has its own virtual network — 127.0.0.1
    // inside it is the emulator's own loopback, not the host machine's.
    // 10.0.2.2 is the emulator's alias for the host's localhost.
    if (Platform.isAndroid) return 'http://10.0.2.2:$port';
    // iOS Simulator shares the host machine's network stack directly.
    return 'http://localhost:$port';
  }
}
