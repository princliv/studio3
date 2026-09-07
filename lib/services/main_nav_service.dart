import 'package:flutter/foundation.dart';

/// Bridges profile (and other overlays) back to `MainShell`'s Home tab.
class MainNavService {
  MainNavService._();
  static final instance = MainNavService._();

  VoidCallback? _goHome;

  void register({required VoidCallback goHome}) {
    _goHome = goHome;
  }

  void unregister() {
    _goHome = null;
  }

  /// Returns true if a mounted `MainShell` switched to Home.
  bool goHome() {
    final handler = _goHome;
    if (handler == null) return false;
    handler();
    return true;
  }
}
