import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Backend base URL — read from `.env`'s `NEXT_PUBLIC_API_URL` at runtime.
///
/// Switch between the local dev server and the deployed backend by editing
/// `.env` (see the comments there) and hot-restarting — no rebuild needed.
abstract final class ApiConfig {
  static const int port = 9000;

  static const String _deployedBaseUrl =
      'https://studio3-backend.onrender.com';

  /// Set via `--dart-define=API_HOST=<host>` to override `.env` entirely
  /// (e.g. for CI runs); empty otherwise.
  static const String _hostOverride = String.fromEnvironment('API_HOST');

  static String get baseUrl {
    if (_hostOverride.isNotEmpty) return 'http://$_hostOverride:$port';
    final fromEnv = dotenv.env['NEXT_PUBLIC_API_URL'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return _deployedBaseUrl;
  }
}
