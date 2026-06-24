import '../models/piece_summary.dart';
import '../models/user_profile.dart';
import 'api_client.dart';
import 'auth_session.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final _api = ApiClient.instance;
  final _session = AuthSession.instance;

  Future<UserProfile> getMe() async {
    final json = await _api.get('/api/user/me', auth: true);
    final data = _api.extractData(json) as Map<String, dynamic>;
    final profile = UserProfile.fromJson(data);
    await _syncSessionFromProfile(profile, data);
    return profile;
  }

  Future<UserProfile> getPublicProfile(String username) async {
    final json = await _api.get('/api/user/$username');
    final data = _api.extractData(json) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateMe({
    String? name,
    String? bio,
    String? location,
    String? profilePhotoUrl,
    String? coverPhotoUrl,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (bio != null) body['bio'] = bio;
    if (location != null) body['location'] = location;
    if (profilePhotoUrl != null) body['profilePhotoUrl'] = profilePhotoUrl;
    if (coverPhotoUrl != null) body['coverPhotoUrl'] = coverPhotoUrl;
    final json = await _api.patch('/api/user/me', body: body);
    final data = _api.extractData(json) as Map<String, dynamic>;
    final profile = UserProfile.fromJson(data);
    await _syncSessionFromProfile(profile, data);
    return profile;
  }

  Future<UserProfile> changeUsername(String username) async {
    final json = await _api.patch(
      '/api/user/me/username',
      body: {'username': username},
    );
    final data = _api.extractData(json) as Map<String, dynamic>;
    final profile = UserProfile.fromJson(data);
    await _syncSessionFromProfile(profile, data);
    return profile;
  }

  Future<void> setRole(String role) async {
    await _api.patch('/api/user/me/role', body: {'role': role});
    final user = _session.user;
    if (user != null) {
      await _session.updateUser(user.copyWith(role: role));
    }
  }

  Future<void> setOnboardingPreferences({
    required List<String> mediums,
    required List<String> styles,
    required List<String> themes,
  }) async {
    await _api.post(
      '/api/user/me/onboarding/preferences',
      body: {'mediums': mediums, 'styles': styles, 'themes': themes},
      auth: true,
    );
  }

  Future<void> setOnboardingPhotos({
    String? profilePhotoUrl,
    String? coverPhotoUrl,
    bool skip = false,
  }) async {
    if (skip) {
      await _api.post(
        '/api/user/me/onboarding/photos',
        body: {'skip': true},
        auth: true,
      );
      return;
    }
    final body = <String, dynamic>{};
    if (profilePhotoUrl != null) body['profilePhotoUrl'] = profilePhotoUrl;
    if (coverPhotoUrl != null) body['coverPhotoUrl'] = coverPhotoUrl;
    await _api.post('/api/user/me/onboarding/photos', body: body, auth: true);
  }

  Future<void> completeOnboarding() async {
    await _api.post('/api/user/me/onboarding/complete', auth: true);
    final user = _session.user;
    if (user != null) {
      await _session.updateUser(user.copyWith(onboardingComplete: true));
    }
  }

  Future<SellerStatus> getSellerStatus() async {
    final json = await _api.get('/api/user/me/seller', auth: true);
    final data = _api.extractData(json) as Map<String, dynamic>;
    final status = SellerStatus.fromJson(data);
    await _session.setSellerEnabled(status.enabled);
    return status;
  }

  Future<SellerStatus> enableSeller({
    required String location,
    bool useProfileLocation = false,
  }) async {
    final json = await _api.post(
      '/api/user/me/seller/enable',
      body: {'location': location, 'useProfileLocation': useProfileLocation},
      auth: true,
    );
    final data = _api.extractData(json) as Map<String, dynamic>;
    final status = SellerStatus.fromJson(data);
    await _session.setSellerEnabled(true);
    return status;
  }

  Future<void> disableSeller() async {
    await _api.post('/api/user/me/seller/disable', auth: true);
    await _session.setSellerEnabled(false);
  }

  Future<List<PieceSummary>> getSavedPieces() async {
    try {
      final json = await _api.get('/api/user/me/saved/pieces', auth: true);
      return _api
          .extractList(json)
          .map(PieceSummary.fromJson)
          .toList();
    } catch (_) {
      final profile = await getMe();
      return profile.savedPieces;
    }
  }

  Future<void> logoutAllDevices() async {
    await _api.post('/api/auth/logout-all', auth: true);
  }

  Future<void> _syncSessionFromProfile(
    UserProfile profile,
    Map<String, dynamic> data,
  ) async {
    final user = _session.user;
    if (user == null) return;
    await _session.updateUser(user.copyWith(
      username: profile.username,
      name: profile.name,
      email: profile.email ?? user.email,
      onboardingComplete: profile.onboardingComplete,
      role: profile.role,
      sellerEnabled: profile.sellerEnabled,
    ));
    await _session.setSellerEnabled(profile.sellerEnabled);
  }
}
