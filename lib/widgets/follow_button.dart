import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/home_feed_tokens.dart';

/// Follow relationship from the viewer to a profile/artist — a private
/// account yields [pending] instead of jumping straight to [following].
enum FollowState { none, pending, following }

/// Shared Follow/Following/Requested pill button used on the artist profile
/// page and on piece/scene detail pages.
class FollowButton extends StatelessWidget {
  const FollowButton({
    super.key,
    required this.state,
    this.onPressed,
    this.dense = false,
  });

  final FollowState state;
  final VoidCallback? onPressed;

  /// Compact sizing for tight horizontal rows (e.g. piece/scene artist rows),
  /// as opposed to the larger standalone pill on the profile header.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final outlined = state != FollowState.none;
    final label = switch (state) {
      FollowState.none => 'Follow',
      FollowState.pending => 'Requested',
      FollowState.following => 'Following',
    };
    return Material(
      color: outlined ? Colors.transparent : HomeFeedTokens.textPrimary,
      borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
        child: DecoratedBox(
          decoration: outlined
              ? BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(HomeFeedTokens.cardRadius),
                  border: Border.all(
                    color: HomeFeedTokens.textPrimary.withValues(
                      alpha: state == FollowState.pending ? 0.2 : 0.35,
                    ),
                  ),
                )
              : const BoxDecoration(),
          child: Padding(
            padding: dense
                ? const EdgeInsets.symmetric(vertical: 4, horizontal: 14)
                : const EdgeInsets.symmetric(vertical: 6, horizontal: 28),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: dense ? 12 : 15,
                  fontWeight: dense ? FontWeight.w500 : FontWeight.w600,
                  color: outlined
                      ? HomeFeedTokens.textPrimary.withValues(
                          alpha: state == FollowState.pending ? 0.7 : 1,
                        )
                      : HomeFeedTokens.textInverse,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
