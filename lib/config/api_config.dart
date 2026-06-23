import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Backend base URL — keep in sync with `.env` `NEXT_PUBLIC_API_URL`.
abstract final class ApiConfig {
  static const int port = 9000;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$port';
    if (Platform.isAndroid) return 'http://10.0.2.2:$port';
    return 'http://localhost:$port';
  }
}
