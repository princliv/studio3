import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/home_feed_tokens.dart';
import '../../../widgets/follow_button.dart';
import '../../../widgets/profile_avatar.dart';
import '../profile_constants.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.handle,
    required this.followingCount,
    required this.followersCount,
    required this.bioLine1,
    required this.bioLine2,
    this.avatarUrl,
    this.piecesCount,
    this.collectedCount,
    this.savesCount,
    this.salesCount,
    this.sellerMode = false,
    this.isOwnProfile = true,
    this.followState = FollowState.none,
    this.onFollow,
    this.onMessage,
    this.onAvatarTap,
    this.onTapFollowing,
    this.onTapFollowers,
  });

  final String name;
  final String handle;
  final int followingCount;
  final int followersCount;
  final String bioLine1;
  final String bioLine2;
  final String? avatarUrl;
  final int? piecesCount;
  final int? collectedCount;
  final int? savesCount;
  final int? salesCount;
  final bool sellerMode;
  final bool isOwnProfile;
  final FollowState followState;
  final VoidCallback? onFollow;
  final VoidCallback? onMessage;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onTapFollowing;
  final VoidCallback? onTapFollowers;

  static const _avatarSize = 86.0;

  String _formatCount(int? value) {
    if (value == null) return '—';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return '$value';
  }

  List<({String value, String label})> get _stats {
    if (sellerMode) {
      return [
        (value: _formatCount(piecesCount), label: 'pieces'),
        (value: _formatCount(collectedCount), label: 'collected'),
        (value: _formatCount(savesCount), label: 'saves'),
        (value: _formatCount(salesCount), label: 'sales'),
      ];
    }
    return [
      (value: _formatCount(piecesCount), label: 'pieces'),
      (value: _formatCount(collectedCount), label: 'collected'),
      (value: _formatCount(savesCount), label: 'saves'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;

    return ColoredBox(
      color: HomeFeedTokens.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          kProfileHorizontalPad,
          14,
          kProfileHorizontalPad,
          10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onAvatarTap,
                  behavior: onAvatarTap != null
                      ? HitTestBehavior.opaque
                      : HitTestBehavior.deferToChild,
                  child: ProfileAvatar(
                    url: avatarUrl,
                    size: _avatarSize,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < stats.length; i++) ...[
                          if (i > 0) const SizedBox(width: 18),
                          _StatBlock(
                            value: stats[i].value,
                            label: stats[i].label,
                            compact: sellerMode,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: HomeFeedTokens.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              handle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: kProfileTextMuted,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FollowStatText(
                  count: followingCount,
                  label: 'following',
                  onTap: onTapFollowing,
                ),
                Text(
                  '  ·  ',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: kProfileTextMuted,
                  ),
                ),
                _FollowStatText(
                  count: followersCount,
                  label: 'followers',
                  onTap: onTapFollowers,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (bioLine1.isNotEmpty)
              Text(
                bioLine1,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: HomeFeedTokens.textPrimary,
                  height: 1.35,
                ),
              ),
            if (bioLine2.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                bioLine2,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: HomeFeedTokens.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
            if (!isOwnProfile) ...[
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FollowButton(
                      state: followState,
                      onPressed: onFollow,
                    ),
                    const SizedBox(width: 10),
                    _MessageButton(onPressed: onMessage),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.value,
    required this.label,
    this.compact = false,
  });

  final String value;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: compact ? 15 : 17,
            fontWeight: FontWeight.w700,
            color: HomeFeedTokens.textPrimary,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w400,
            color: kProfileTextMuted,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _FollowStatText extends StatelessWidget {
  const _FollowStatText({
    required this.count,
    required this.label,
    this.onTap,
  });

  final int count;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: onTap != null ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
      child: Text(
        '$count $label',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: kProfileTextMuted,
          height: 1.35,
        ),
      ),
    );
  }
}

class _MessageButton extends StatelessWidget {
  const _MessageButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
            border: Border.all(
              color: HomeFeedTokens.textPrimary.withValues(alpha: 0.35),
              width: 1,
            ),
            color: HomeFeedTokens.background,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 28),
            child: Text(
              'Message',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: HomeFeedTokens.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
