import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/home_feed_dummy.dart';
import '../../theme/home_feed_tokens.dart';
import '../home_feed/home_feed_widgets.dart';

class PieceSeriesRow extends StatelessWidget {
  const PieceSeriesRow({
    super.key,
    required this.seriesName,
    required this.thumbSeeds,
  });

  final String seriesName;
  final List<int> thumbSeeds;

  @override
  Widget build(BuildContext context) {
    if (seriesName.isEmpty || thumbSeeds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: Text(
            '$seriesName · ${thumbSeeds.length}',
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
            itemCount: thumbSeeds.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
                child: SizedBox(
                  width: 118,
                  height: 118,
                  child: FeedPicsumImage(
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
