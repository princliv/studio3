import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/home_feed_tokens.dart';
import '../../../widgets/follow_button.dart';
import '../profile_constants.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.handle,
    required this.followingCount,
    required this.followersCount,
    required this.bio,
    this.piecesCount,
    this.scenesCount,
    this.savesCount,
    this.availableCount,
    this.collectedCount,
    this.rating,
    this.sellerMode = false,
    this.isOwnProfile = true,
    this.followState = FollowState.none,
    this.followBusy = false,
    this.onFollow,
    this.onMessage,
    this.onTapFollowing,
    this.onTapFollowers,
  });

  final String name;
  final String handle;
  final int followingCount;
  final int followersCount;
  final String bio;
  final int? piecesCount;
  final int? scenesCount;
  final int? savesCount;
  final int? availableCount;
  final int? collectedCount;
  final double? rating;
  final bool sellerMode;
  final bool isOwnProfile;
  final FollowState followState;
  final bool followBusy;
  final VoidCallback? onFollow;
  final VoidCallback? onMessage;
  final VoidCallback? onTapFollowing;
  final VoidCallback? onTapFollowers;

  String _formatCount(int? value) {
    if (value == null) return '—';
    if (value >= 1000) {
      final k = value / 1000;
      final text = k.truncateToDouble() == k
          ? k.toStringAsFixed(0)
          : k.toStringAsFixed(1);
      return '${text}k';
    }
    return '$value';
  }

  String _formatRating(double? value) {
    if (value == null) return '—';
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }

  List<({String value, String label})> get _contentStats => [
    (value: _formatCount(piecesCount), label: 'pieces'),
    (value: _formatCount(scenesCount), label: 'scenes'),
    (value: _formatCount(savesCount), label: 'saves'),
  ];

  List<({String value, String label})> get _sellerStats => [
    (value: _formatCount(availableCount), label: 'available'),
    (value: _formatCount(collectedCount), label: 'collected'),
    (value: _formatRating(rating), label: 'rating'),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kProfilePageBackground,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              kProfileIdentityPad,
              8,
              kProfileIdentityPad,
              0,
            ),
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kProfileGeist(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  handle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kProfileGeist(fontSize: 13, color: kProfileTextMuted),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onTapFollowers ?? onTapFollowing,
                  behavior: HitTestBehavior.opaque,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: onTapFollowers,
                            child: Text(
                              '$followersCount followers',
                              style: kProfileGeist(
                                fontSize: 12,
                                color: kProfileTextMuted,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ' · ',
                          style: kProfileGeist(
                            fontSize: 12,
                            color: kProfileTextMuted,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: onTapFollowing,
                            child: Text(
                              '$followingCount following',
                              style: kProfileGeist(
                                fontSize: 12,
                                color: kProfileTextMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          if (bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kProfileIdentityPad,
                8,
                kProfileIdentityPad,
                0,
              ),
              child: Text(
                bio,
                textAlign: TextAlign.center,
                style: kProfileGeist(fontSize: 13),
              ),
            )
          else
            const SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.fromLTRB(
              sellerMode ? kProfileHorizontalPad : kProfileIdentityPad,
              16,
              sellerMode ? kProfileHorizontalPad : kProfileIdentityPad,
              0,
            ),
            child: sellerMode
                ? _SellerStatsPager(
                    contentStats: _contentStats,
                    sellerStats: _sellerStats,
                  )
                : _StatsRow(stats: _contentStats),
          ),
          if (!isOwnProfile)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kProfileHorizontalPad,
                16,
                kProfileHorizontalPad,
                0,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final buttonWidth = ((constraints.maxWidth - 8) / 2).clamp(
                    0.0,
                    kProfileButtonMaxWidth,
                  );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: buttonWidth,
                        child: _ProfileActionButton(
                          label: 'Message',
                          filled: false,
                          onPressed: onMessage,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: buttonWidth,
                        child: _ProfileActionButton(
                          label: followState == FollowState.none
                              ? 'Follow'
                              : followState == FollowState.pending
                              ? 'Requested'
                              : 'Following',
                          filled: followState == FollowState.none,
                          busy: followBusy,
                          onPressed: followBusy ? null : onFollow,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final List<({String value, String label})> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0)
            const ColoredBox(
              color: kProfileStatDivider,
              child: SizedBox(width: 1, height: 16),
            ),
          Expanded(
            child: _StatBlock(value: stats[i].value, label: stats[i].label),
          ),
        ],
      ],
    );
  }
}

/// Figma 2652:2753 — six seller stats in two pages of three.
class _SellerStatsPager extends StatefulWidget {
  const _SellerStatsPager({
    required this.contentStats,
    required this.sellerStats,
  });

  final List<({String value, String label})> contentStats;
  final List<({String value, String label})> sellerStats;

  @override
  State<_SellerStatsPager> createState() => _SellerStatsPagerState();
}

class _SellerStatsPagerState extends State<_SellerStatsPager> {
  /// 0 = pieces/scenes/saves, 1 = available/collected/rating (Figma default).
  int _page = 1;

  static const _chevronAsset = 'assets/profile/icon_stat_chevron.svg';

  void _togglePage() {
    setState(() => _page = 1 - _page);
  }

  @override
  Widget build(BuildContext context) {
    final onSellerPage = _page == 1;
    final stats = onSellerPage ? widget.sellerStats : widget.contentStats;
    final leftColor = onSellerPage
        ? HomeFeedTokens.textPrimary
        : kProfileTextMuted;
    final rightColor = onSellerPage
        ? kProfileTextMuted
        : HomeFeedTokens.textPrimary;

    return Row(
      children: [
        _StatChevron(
          color: leftColor,
          turns: 0.25,
          semanticLabel: 'Previous stats',
          onTap: _togglePage,
          asset: _chevronAsset,
        ),
        const SizedBox(width: 8),
        Expanded(child: _StatsRow(stats: stats)),
        const SizedBox(width: 8),
        _StatChevron(
          color: rightColor,
          turns: -0.25,
          semanticLabel: 'Next stats',
          onTap: _togglePage,
          asset: _chevronAsset,
        ),
      ],
    );
  }
}

class _StatChevron extends StatelessWidget {
  const _StatChevron({
    required this.color,
    required this.turns,
    required this.semanticLabel,
    required this.onTap,
    required this.asset,
  });

  final Color color;
  final double turns;
  final String semanticLabel;
  final VoidCallback onTap;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: RotatedBox(
            quarterTurns: (turns * 4).round(),
            child: SvgPicture.asset(
              asset,
              width: 13,
              height: 6,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kProfileGeist(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kProfileGeist(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.filled,
    this.onPressed,
    this.busy = false,
  });

  final String label;
  final bool filled;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kProfileButtonHeight,
      child: Material(
        color: filled ? HomeFeedTokens.neutral800 : Colors.transparent,
        borderRadius: BorderRadius.circular(kProfileButtonRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(kProfileButtonRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kProfileButtonRadius),
              border: filled
                  ? null
                  : Border.all(color: HomeFeedTokens.textSecondary, width: 0.3),
            ),
            child: Center(
              child: busy
                  ? SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: filled
                            ? HomeFeedTokens.textInverse
                            : HomeFeedTokens.textPrimary,
                      ),
                    )
                  : Text(
                      label,
                      style: kProfileGeist(
                        fontSize: 12,
                        color: filled
                            ? HomeFeedTokens.textInverse
                            : HomeFeedTokens.textPrimary,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
