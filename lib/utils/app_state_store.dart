import 'package:shared_preferences/shared_preferences.dart';

/// Minimal "where was the user" snapshot, restored synchronously before
/// the first frame so there's no flash of the default (Home) tab after
/// the app is killed and reopened. Only the selected bottom-nav tab index
/// is persisted — the tabs themselves are `IndexedStack` widgets that stay
/// alive in memory for the app's lifetime, so index is the only thing
/// actually lost across a process kill.
class AppStateStore {
  AppStateStore._();
  static final AppStateStore instance = AppStateStore._();

  static const _navIndexKey = 'app_state.nav_index';

  SharedPreferences? _prefs;
  int _lastNavIndex = 0;

  int get lastNavIndex => _lastNavIndex;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _lastNavIndex = _prefs!.getInt(_navIndexKey) ?? 0;
  }

  Future<void> saveNavIndex(int index) async {
    _lastNavIndex = index;
    await _prefs?.setInt(_navIndexKey, index);
  }
}
