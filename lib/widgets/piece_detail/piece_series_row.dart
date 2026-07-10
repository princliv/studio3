import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/home_feed_dummy.dart';
import '../../theme/home_feed_tokens.dart';
import '../home_feed/home_feed_widgets.dart';

class PieceSeriesRow extends StatelessWidget {
  const PieceSeriesRow({
    super.key,
    required this.seriesName,
    this.thumbSeeds = const [],
    this.thumbUrls = const [],
  });

  final String seriesName;
  final List<int> thumbSeeds;
  final List<String> thumbUrls;

  @override
  Widget build(BuildContext context) {
    final urls = thumbUrls.where((url) => url.isNotEmpty).toList();
    final count = urls.isNotEmpty ? urls.length : thumbSeeds.length;
    if (seriesName.isEmpty || count == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: Text(
            '$seriesName · $count',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: HomeFeedTokens.textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 19),
            itemCount: count,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final url = urls.isNotEmpty ? urls[index] : null;
              return ClipRRect(
                borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
                child: SizedBox(
                  width: 118,
                  height: 118,
                  child: url != null
                      ? Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              FeedPicsumImage(
                            url: picsumUrl(thumbSeeds[index], 118, 118),
                          ),
                        )
                      : FeedPicsumImage(
                          url: picsumUrl(thumbSeeds[index], 118, 118),
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
