import 'package:flutter/material.dart';

import '../models/piece_summary.dart';
import '../models/post_summary.dart';
import '../models/user_profile.dart';
import '../services/auth_session.dart';
import '../services/piece_service.dart';
import '../services/post_service.dart';
import '../services/series_service.dart';
import '../services/social_service.dart';
import '../services/user_service.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/profile_avatar_preview_sheet.dart';
import '../widgets/profile_cover_image.dart';
import 'profile/models/profile_series_data.dart';
import 'profile/profile_constants.dart';
import 'profile/widgets/profile_header.dart';
import 'profile/widgets/profile_tab_content.dart';
import 'profile/widgets/profile_tabs.dart';
import 'profile/widgets/profile_viewer_mode_capsule.dart';

/// Artist profile — own tab or pushed public profile by [username].
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.username, this.viewerMode = false});

  /// When null, loads the signed-in user's profile (bottom-nav tab).
  final String? username;

  /// When true, loads public profile data and hides owner-only actions.
  final bool viewerMode;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _tab = 'pieces';
  UserProfile? _profile;
  List<PieceSummary> _pieces = [];
  List<PostSummary> _scenes = [];
  List<PieceSummary> _listedPieces = [];
  List<ProfileSeriesData> _series = [];
  bool _tabContentLoading = false;
  bool? _lastKnownSeller;
  bool _piecesLoaded = false;
  bool _scenesLoaded = false;
  bool _listedPiecesLoaded = false;
  bool _seriesLoaded = false;
  String _collectSegment = 'available';

  static const _avatarSeed = 902;
  static const _name = 'Sarah Olson';
  static const _handle = '@sarahsunnyart';
  static const _followingFollowers = '100 following · 89 followers';
  static const _bioLine1 = 'Oil on canvas · Dallas, TX';
  static const _bioLine2 =
      'Figurative oil painter exploring memory, identity, and the in-between.';

  static const _leftMasonry = <({int seed, double h})>[
    (seed: 301, h: 292),
    (seed: 302, h: 168),
    (seed: 303, h: 174),
    (seed: 304, h: 318),
  ];

  static const _rightMasonry = <({int seed, double h})>[
    (seed: 311, h: 182),
    (seed: 312, h: 132),
    (seed: 313, h: 302),
    (seed: 314, h: 156),
    (seed: 315, h: 278),
  ];

  bool get _isTabContext => widget.username == null;

  bool get _isOwnProfile {
    if (_isTabContext) return true;
    final sessionUser = AuthSession.instance.user?.username;
    return sessionUser != null && sessionUser == widget.username;
  }

  bool get _isPushedRoute => widget.username != null;

  @override
  void initState() {
    super.initState();
    _lastKnownSeller = AuthSession.instance.sellerEnabled;
    if (_isTabContext) {
      AuthSession.instance.addListener(_onSessionChanged);
    }
    _loadProfileShell();
  }

  @override
  void dispose() {
    if (_isTabContext) {
      AuthSession.instance.removeListener(_onSessionChanged);
    }
    super.dispose();
  }

  void _onSessionChanged() {
    if (!_isTabContext) return;
    final seller = AuthSession.instance.sellerEnabled;
    if (seller == _lastKnownSeller) return;
    _lastKnownSeller = seller;
    if (!mounted) return;
    setState(() {
      if (seller) {
        _tab = 'collect';
        _listedPiecesLoaded = false;
      } else if (_tab == 'collect') {
        _tab = 'pieces';
        _listedPieces = [];
        _listedPiecesLoaded = false;
      }
    });
    _loadProfileShell(silent: true);
    _loadActiveTab(force: true);
  }

  void _resetTabCache() {
    _piecesLoaded = false;
    _scenesLoaded = false;
    _listedPiecesLoaded = false;
    _seriesLoaded = false;
  }

  Future<void> _loadProfileShell({bool silent = false}) async {
    try {
      final UserProfile profile;
      if (_isTabContext || (_isOwnProfile && !widget.viewerMode)) {
        profile = await UserService.instance.getMe();
      } else {
        profile = await UserService.instance.getPublicProfile(widget.username!);
      }
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _lastKnownSeller = profile.sellerEnabled;
        if (!profile.sellerEnabled && _tab == 'collect') _tab = 'pieces';
      });
      if (!silent) _loadActiveTab();
    } catch (_) {
      // Keep session-backed shell visible when profile cannot be loaded.
    }
  }

  Future<void> _loadProfile() async {
    _resetTabCache();
    await _loadProfileShell();
    await _loadActiveTab(force: true);
  }

  Future<void> _loadActiveTab({bool force = false}) async {
    final profile = _profile;
    if (profile == null) return;

    final tab = _tab;
    if (tab == 'pieces' && (_piecesLoaded && !force)) return;
    if (tab == 'scenes' && (_scenesLoaded && !force)) return;
    if (tab == 'collect' && (_listedPiecesLoaded && !force)) return;
    if (tab == 'series' && (_seriesLoaded && !force)) return;

    setState(() => _tabContentLoading = true);

    try {
      if (tab == 'pieces') {
        final pieces =
            await PieceService.instance.getUserPieces(profile.username);
        if (!mounted) return;
        setState(() {
          _pieces = pieces;
          _piecesLoaded = true;
          _tabContentLoading = false;
        });
      } else if (tab == 'scenes') {
        final scenes =
            await PostService.instance.getUserPosts(profile.username);
        if (!mounted) return;
        setState(() {
          _scenes = scenes;
          _scenesLoaded = true;
          _tabContentLoading = false;
        });
      } else if (tab == 'collect' && profile.sellerEnabled) {
        final listedPieces = await _loadListedPieces(profile);
        if (!mounted) return;
        setState(() {
          _listedPieces = listedPieces;
          _listedPiecesLoaded = true;
          _tabContentLoading = false;
        });
      } else if (tab == 'series') {
        final series =
            await SeriesService.instance.getUserSeries(profile.username);
        if (!mounted) return;
        setState(() {
          _series = series.map(ProfileSeriesData.fromSeries).toList();
          _seriesLoaded = true;
          _tabContentLoading = false;
        });
      } else {
        if (mounted) setState(() => _tabContentLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _tabContentLoading = false);
    }
  }

  Future<List<PieceSummary>> _loadListedPieces(UserProfile profile) async {
    return PieceService.instance.getUserPiecesForSale(profile.username);
  }

  void _onTabChanged(String tab) {
    setState(() {
      _tab = tab;
      if (tab == 'collect') _collectSegment = 'available';
    });
    _loadActiveTab();
  }

  void _onCollectSegmentChanged(String segment) {
    setState(() => _collectSegment = segment);
  }

  Future<void> _toggleFollow() async {
    final profile = _profile;
    if (profile == null) return;
    final nextFollowing = !profile.isFollowing;
    setState(() {
      _profile = UserProfile(
        username: profile.username,
        name: profile.name,
        email: profile.email,
        bio: profile.bio,
        location: profile.location,
        profilePhotoUrl: profile.profilePhotoUrl,
        coverPhotoUrl: profile.coverPhotoUrl,
        role: profile.role,
        onboardingComplete: profile.onboardingComplete,
        sellerEnabled: profile.sellerEnabled,
        canChangeUsername: profile.canChangeUsername,
        followingCount: profile.followingCount,
        followersCount:
            profile.followersCount + (nextFollowing ? 1 : -1),
        piecesCount: profile.piecesCount,
        collectedCount: profile.collectedCount,
        savesCount: profile.savesCount,
        isFollowing: nextFollowing,
        tastePreferences: profile.tastePreferences,
        savedPieces: profile.savedPieces,
      );
    });
    try {
      if (nextFollowing) {
        await SocialService.instance.follow(profile.username);
      } else {
        await SocialService.instance.unfollow(profile.username);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _profile = profile);
    }
  }

  void _onAvatarTap(String? avatarUrl) {
    showProfileAvatarPreview(
      context,
      avatarUrl: avatarUrl,
      seed: _avatarSeed,
      allowChange: _isOwnProfile && !widget.viewerMode,
      onChanged: () async {
        _resetTabCache();
        await _loadProfileShell(silent: true);
      },
    );
  }

  void _onMessageTap() {
    if (widget.viewerMode) {
      _showViewerModePreviewSnackBar();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Messaging coming soon')),
    );
  }

  void _onFollowTap() {
    if (widget.viewerMode) {
      _showViewerModePreviewSnackBar();
      return;
    }
    _toggleFollow();
  }

  void _showViewerModePreviewSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This is a preview of your public profile'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final heroH = (width * 0.68).clamp(260.0, 340.0);
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottomPad = (_isPushedRoute ? safeBottom + 24 : safeBottom + 100) +
        (widget.viewerMode ? 56 : 0);
    final profile = _profile;
    final sessionUser = AuthSession.instance.user;
    final sellerEnabled =
        profile?.sellerEnabled ?? AuthSession.instance.sellerEnabled;
    final isOwnProfile = _isOwnProfile;
    final showPublicActions = widget.viewerMode || !isOwnProfile;

    final name = profile?.name ?? sessionUser?.name ?? _name;
    final handle = profile?.handle ??
        (sessionUser != null ? '@${sessionUser.username}' : _handle);
    final coverUrl = profile?.coverPhotoUrl;
    final avatarUrl = profile?.profilePhotoUrl;

    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadProfile,
              child: CustomScrollView(
                slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    ProfileCoverImage(
                      url: coverUrl,
                      height: heroH,
                      width: width,
                    ),
                    if (_isPushedRoute)
                      Positioned(
                        top: 8,
                        left: 12,
                        child: _ProfileBackButton(
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    if (isOwnProfile && _isTabContext)
                      Positioned(
                        top: 8,
                        right: 12,
                        child: _ProfileSettingsButton(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              '/profile-settings',
                            );
                            if (mounted) {
                              _resetTabCache();
                              await _loadProfileShell(silent: true);
                              await _loadActiveTab(force: true);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: ProfileHeader(
                  name: name,
                  handle: handle,
                  followingFollowers:
                      profile?.followingFollowers ?? _followingFollowers,
                  bioLine1: profile?.location?.isNotEmpty == true
                      ? profile!.location!
                      : _bioLine1,
                  bioLine2: profile?.bio?.isNotEmpty == true
                      ? profile!.bio!
                      : _bioLine2,
                  avatarUrl: avatarUrl,
                  avatarSeed: _avatarSeed,
                  piecesCount: profile?.piecesCount ?? _pieces.length,
                  collectedCount: profile?.collectedCount,
                  savesCount: profile?.savesCount,
                  salesCount: profile?.collectedCount,
                  sellerMode: sellerEnabled,
                  isOwnProfile: !showPublicActions,
                  isFollowing: profile?.isFollowing ?? false,
                  onFollow: showPublicActions ? _onFollowTap : null,
                  onMessage: showPublicActions ? _onMessageTap : null,
                  onAvatarTap: () => _onAvatarTap(avatarUrl),
                ),
              ),
              SliverToBoxAdapter(
                child: ProfileTabs(
                  currentTab: _tab,
                  showCollect: sellerEnabled,
                  onTabChanged: _onTabChanged,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  kProfileHorizontalPad,
                  0,
                  kProfileHorizontalPad,
                  bottomPad,
                ),
                sliver: SliverToBoxAdapter(
                  child: ProfileTabContent(
                    currentTab: _tab,
                    seriesItems: _series,
                    pieces: _pieces,
                    scenes: _scenes,
                    listedPieces: _listedPieces,
                    collectSegment: _collectSegment,
                    onCollectSegmentChanged: _onCollectSegmentChanged,
                    sellerMode: sellerEnabled,
                    loading: _tabContentLoading,
                    leftMasonry: _leftMasonry,
                    rightMasonry: _rightMasonry,
                  ),
                ),
              ),
                ],
              ),
            ),
            if (widget.viewerMode)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, safeBottom + 16),
                  child: const ProfileViewerModeCapsule(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSettingsButton extends StatelessWidget {
  const _ProfileSettingsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.menu_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ProfileBackButton extends StatelessWidget {
  const _ProfileBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
