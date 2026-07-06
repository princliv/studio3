import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/home_feed_dummy.dart';
import '../../models/feed_preview_item.dart';
import '../../theme/home_feed_tokens.dart';

class PieceArtistRow extends StatelessWidget {
  const PieceArtistRow({
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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              picsumAvatarUrl(item.artist.avatarSeed),
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 28,
                height: 28,
                color: HomeFeedTokens.textSecondary.withValues(alpha: 0.3),
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
                    color: HomeFeedTokens.textPrimary,
                  ),
                ),
                Text(
                  item.handle,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: HomeFeedTokens.textSecondary,
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
              side: const BorderSide(color: HomeFeedTokens.neutral800),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              foregroundColor: HomeFeedTokens.neutral800,
            ),
            child: Text(
              following ? 'Following' : 'Follow',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
