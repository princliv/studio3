import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';

class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  static const _tokenKey = 'access_token';
  static const _userKey = 'auth_user';
  static const _rememberedUsernameKey = 'remembered_username';

  SharedPreferences? _prefs;
  String? accessToken;
  AuthUser? user;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    accessToken = _prefs!.getString(_tokenKey);
    final userJson = _prefs!.getString(_userKey);
    if (userJson != null) {
      user = AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
  }

  bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  String? get rememberedUsername => _prefs?.getString(_rememberedUsernameKey);

  Future<void> saveSession({
    required String token,
    required AuthUser authUser,
  }) async {
    accessToken = token;
    user = authUser;
    await _prefs?.setString(_tokenKey, token);
    await _prefs?.setString(_userKey, jsonEncode(authUser.toJson()));
  }

  Future<void> saveRememberedUsername(String username) async {
    await _prefs?.setString(_rememberedUsernameKey, username);
  }

  Future<void> clearRememberedUsername() async {
    await _prefs?.remove(_rememberedUsernameKey);
  }

  Future<void> clear() async {
    accessToken = null;
    user = null;
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_userKey);
  }
}
