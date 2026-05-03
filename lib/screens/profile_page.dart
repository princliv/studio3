import 'package:flutter/material.dart';

import '../data/home_feed_dummy.dart';
import '../theme/home_feed_tokens.dart';
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
  /// pieces | series | scenes | collect
  String _tab = 'pieces';

  static const _heroSeed = 901;
  static const _avatarSeed = 902;

  static const _name = 'Sarah Olson';
  static const _handle = '@sarahsunnyart';
  static const _followingFollowers = '100 following · 89 followers';
  static const _bioLine1 = 'Oil on canvas · Dallas, TX';
  static const _bioLine2 =
      'Figurative oil painter exploring memory, identity, and the in-between.';

  /// Left column: (seed, height).
  static const _leftMasonry = <({int seed, double h})>[
    (seed: 301, h: 292),
    (seed: 302, h: 168),
    (seed: 303, h: 174),
    (seed: 304, h: 318),
  ];

  /// Right column: (seed, height).
  static const _rightMasonry = <({int seed, double h})>[
    (seed: 311, h: 182),
    (seed: 312, h: 132),
    (seed: 313, h: 302),
    (seed: 314, h: 156),
    (seed: 315, h: 278),
  ];

  /// Includes entries with 1 piece (hidden on Series tab).
  static final List<ProfileSeriesData> _allSeries = [
    ProfileSeriesData(name: 'Solo Study', pieceCount: 1, imageSeeds: const [501]),
    ProfileSeriesData(
      name: 'Two Piece Series',
      pieceCount: 2,
      imageSeeds: const [602, 603],
    ),
    ProfileSeriesData(
      name: 'Three Piece Series',
      pieceCount: 3,
      imageSeeds: const [611, 612, 613],
    ),
    ProfileSeriesData(
      name: 'Four Piece Series',
      pieceCount: 4,
      imageSeeds: const [621, 622, 623, 624],
    ),
    ProfileSeriesData(
      name: 'Riverwalk Dream',
      pieceCount: 3,
      imageSeeds: const [511, 512, 513],
    ),
    ProfileSeriesData(
      name: 'Sunset Stories',
      pieceCount: 2,
      imageSeeds: const [521, 522],
    ),
    ProfileSeriesData(
      name: 'Strolls in the Park',
      pieceCount: 6,
      imageSeeds: const [531, 532, 533, 534, 535, 536],
    ),
    ProfileSeriesData(
      name: 'Morning Light',
      pieceCount: 2,
      imageSeeds: const [541, 542],
    ),
    ProfileSeriesData(
      name: 'Urban Echoes',
      pieceCount: 4,
      imageSeeds: const [551, 552, 553, 554],
    ),
    ProfileSeriesData(
      name: 'Coastal Forms',
      pieceCount: 5,
      imageSeeds: const [561, 562, 563, 564, 565],
    ),
    ProfileSeriesData(
      name: 'Studio Notes',
      pieceCount: 1,
      imageSeeds: const [571],
    ),
    ProfileSeriesData(
      name: 'Paper Boats',
      pieceCount: 3,
      imageSeeds: const [581, 582, 583],
    ),
  ];

  static final List<ProfileSeriesData> _seriesEligible =
      _allSeries.where((s) => s.pieceCount > 1).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final heroH = (width * 0.68).clamp(260.0, 340.0);
    final bottomPad = MediaQuery.paddingOf(context).bottom + 100;

    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHero(heroSeed: _heroSeed, height: heroH, width: width),
            ),
            SliverToBoxAdapter(
              child: ProfileHeader(
                name: _name,
                handle: _handle,
                followingFollowers: _followingFollowers,
                bioLine1: _bioLine1,
                bioLine2: _bioLine2,
                avatarSeed: _avatarSeed,
              ),
            ),
            SliverToBoxAdapter(
              child: ProfileTabs(
                currentTab: _tab,
                onTabChanged: (tab) => setState(() => _tab = tab),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(kProfileHorizontalPad, 0, kProfileHorizontalPad, bottomPad),
              sliver: SliverToBoxAdapter(
                child: ProfileTabContent(
                  currentTab: _tab,
                  leftMasonry: _leftMasonry,
                  rightMasonry: _rightMasonry,
                  seriesItems: _seriesEligible,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.heroSeed,
    required this.height,
    required this.width,
  });

  final int heroSeed;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.network(
        picsumUrl(heroSeed, 800, (height * 2).round()),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ColoredBox(
            color: Colors.grey.shade300,
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: HomeFeedTokens.textPrimary.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        },
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
