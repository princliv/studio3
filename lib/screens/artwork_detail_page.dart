import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/home_feed_tokens.dart';

/// Placeholder detail view after tapping a feed image.
class ArtworkDetailPage extends StatelessWidget {
  const ArtworkDetailPage({
    super.key,
    required this.imageUrl,
    this.artistName,
    this.medium,
  });

  final String imageUrl;
  final String? artistName;
  final String? medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      appBar: AppBar(
        backgroundColor: HomeFeedTokens.background,
        foregroundColor: HomeFeedTokens.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, size: 48),
                  ),
                ),
              ),
            ),
            if (artistName != null || medium != null) ...[
              const SizedBox(height: 16),
              if (artistName != null)
                Text(
                  artistName!,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: HomeFeedTokens.textPrimary,
                  ),
                ),
              if (medium != null)
                Text(
                  medium!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: HomeFeedTokens.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
            ],
            const SizedBox(height: 32),
            Text(
              'Coming soon',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: HomeFeedTokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
