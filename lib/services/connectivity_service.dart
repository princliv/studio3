import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tracks network-interface presence (not full API reachability) so
/// screens can gate background refresh and show an offline state, and so
/// mounted screens can be notified to refetch when connectivity returns.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  StreamSubscription<List<ConnectivityResult>>? _sub;
  final List<Future<void> Function()> _reconnectHooks = [];

  Future<void> init() async {
    final initial = await Connectivity().checkConnectivity();
    _isOnline = _computeOnline(initial);
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = _computeOnline(results);
      if (_isOnline != wasOnline) {
        notifyListeners();
        if (_isOnline) _onReconnected();
      }
    });
  }

  bool _computeOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  /// Registers a callback invoked once whenever connectivity transitions
  /// offline -> online. Callers should remove their hook in `dispose()`.
  void addReconnectHook(Future<void> Function() hook) =>
      _reconnectHooks.add(hook);

  void removeReconnectHook(Future<void> Function() hook) =>
      _reconnectHooks.remove(hook);

  void _onReconnected() {
    for (final hook in List<Future<void> Function()>.of(_reconnectHooks)) {
      unawaited(hook());
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
