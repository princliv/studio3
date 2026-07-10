import 'package:flutter/material.dart';

import '../data/home_feed_dummy.dart';
import '../models/piece_summary.dart';
import '../models/post_summary.dart';
import '../models/user_profile.dart';
import '../services/auth_session.dart';
import '../services/piece_service.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/studio_loading.dart';
import 'profile/models/profile_series_data.dart';
import 'profile/profile_constants.dart';
import 'profile/widgets/profile_header.dart';
import 'profile/widgets/profile_tab_content.dart';
import 'profile/widgets/profile_tabs.dart';

/// Artist profile — Studio 3 Discover mobile (Figma-aligned).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _tab = 'pieces';
  UserProfile? _profile;
  List<PieceSummary> _pieces = [];
  List<PostSummary> _scenes = [];
  List<PieceSummary> _listedPieces = [];
  bool _tabContentLoading = false;
  bool _profileLoading = true;
  bool? _lastKnownSeller;
  bool _piecesLoaded = false;
  bool _scenesLoaded = false;
  bool _listedPiecesLoaded = false;
  String _collectSegment = 'available';

  static const _heroSeed = 901;
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

  static final List<ProfileSeriesData> _seriesEligible = [
    ProfileSeriesData(name: 'Two Piece Series', pieceCount: 2, imageSeeds: const [602, 603]),
    ProfileSeriesData(name: 'Three Piece Series', pieceCount: 3, imageSeeds: const [611, 612, 613]),
    ProfileSeriesData(name: 'Riverwalk Dream', pieceCount: 3, imageSeeds: const [511, 512, 513]),
  ];

  @override
  void initState() {
    super.initState();
    _lastKnownSeller = AuthSession.instance.sellerEnabled;
    AuthSession.instance.addListener(_onSessionChanged);
    _loadProfileShell();
  }

  @override
  void dispose() {
    AuthSession.instance.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
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

  Future<void> _loadProfileShell({bool silent = false}) async {
    if (!silent) setState(() => _profileLoading = true);
    try {
      final profile = await UserService.instance.getMe();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _lastKnownSeller = profile.sellerEnabled;
        _profileLoading = false;
        if (!profile.sellerEnabled && _tab == 'collect') _tab = 'pieces';
      });
      if (!silent) _loadActiveTab();
    } catch (_) {
      if (mounted) setState(() => _profileLoading = false);
    }
  }

  Future<void> _loadProfile() async {
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
    if (tab == 'series') return;

    setState(() => _tabContentLoading = true);

    try {
      if (tab == 'pieces') {
        final pieces = await PieceService.instance.getUserPieces(profile.username);
        if (!mounted) return;
        setState(() {
          _pieces = pieces;
          _piecesLoaded = true;
          _tabContentLoading = false;
        });
      } else if (tab == 'scenes') {
        final scenes = await PostService.instance.getUserPosts(profile.username);
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final heroH = (width * 0.68).clamp(260.0, 340.0);
    final bottomPad = MediaQuery.paddingOf(context).bottom + 100;
    final profile = _profile;
    final sessionUser = AuthSession.instance.user;
    final sellerEnabled =
        profile?.sellerEnabled ?? AuthSession.instance.sellerEnabled;

    final name = profile?.name ?? sessionUser?.name ?? _name;
    final handle = profile?.handle ??
        (sessionUser != null ? '@${sessionUser.username}' : _handle);
    final coverUrl = profile?.coverPhotoUrl;
    final avatarUrl = profile?.profilePhotoUrl;

    return StudioLoadingGate(
      loading: _profileLoading || _tabContentLoading,
      child: Scaffold(
        backgroundColor: HomeFeedTokens.background,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              _piecesLoaded = false;
              _scenesLoaded = false;
              _listedPiecesLoaded = false;
              await _loadProfile();
            },
            child: CustomScrollView(
              slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    _ProfileHero(
                      imageUrl: coverUrl,
                      heroSeed: _heroSeed,
                      height: heroH,
                      width: width,
                    ),
                    Positioned(
                      top: 8,
                      right: 12,
                      child: _ProfileSettingsButton(
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/profile-settings');
                          if (mounted) {
                            _piecesLoaded = false;
                            _scenesLoaded = false;
                            _listedPiecesLoaded = false;
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
                  isOwnProfile: true,
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
                    seriesItems: _seriesEligible,
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
      ),
    ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    this.imageUrl,
    required this.heroSeed,
    required this.height,
    required this.width,
  });

  final String? imageUrl;
  final int heroSeed;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.isNotEmpty == true
        ? imageUrl!
        : picsumUrl(heroSeed, 800, (height * 2).round());

    return SizedBox(
      width: width,
      height: height,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: Colors.grey.shade400,
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: Colors.grey.shade600,
          ),
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
