import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/home_feed_tokens.dart';

/// Shown in place of the pieces/scenes/series tabs when viewing a private
/// profile the caller can't yet see (not the owner, not an accepted follower).
class ProfileLockedPlaceholder extends StatelessWidget {
  const ProfileLockedPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.lock_outline_rounded,
              size: 40, color: HomeFeedTokens.textPrimary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'This account is private',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: HomeFeedTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Follow this account to see their pieces, scenes, and series.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: HomeFeedTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
