import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/home_feed_dummy.dart';
import '../../models/feed_preview_item.dart';
import '../../theme/collect_detail_tokens.dart';
import '../../utils/profile_navigation.dart';

/// Artist row for collect detail (Figma 2302-1554).
class CollectArtistRow extends StatelessWidget {
  const CollectArtistRow({
    super.key,
    required this.item,
    required this.following,
    required this.onFollowToggle,
  });

  final FeedPreviewItem item;
  final bool following;
  final VoidCallback onFollowToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CollectDetailTokens.horizontalPadding,
        12,
        CollectDetailTokens.horizontalPadding,
        0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => openUserProfile(context, item.handle),
            behavior: HitTestBehavior.opaque,
            child: ClipOval(
              child: Image.network(
                picsumAvatarUrl(item.artist.avatarSeed),
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 28,
                  height: 28,
                  color: CollectDetailTokens.textSecondary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.artist.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 14.52 / 12,
                    color: CollectDetailTokens.textPrimary,
                  ),
                ),
                Text(
                  item.handle,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 13 / 10,
                    color: CollectDetailTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onFollowToggle,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(96, 28),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              side: const BorderSide(color: CollectDetailTokens.followBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              foregroundColor: CollectDetailTokens.followBorder,
            ),
            child: Text(
              following ? 'Following' : 'Follow',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 15.6 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
