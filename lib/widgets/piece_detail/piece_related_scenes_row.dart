import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/home_feed_dummy.dart';
import '../../models/feed_item.dart';
import '../../theme/home_feed_tokens.dart';
import '../home_feed/home_feed_widgets.dart';

class PieceRelatedScenesRow extends StatelessWidget {
  const PieceRelatedScenesRow({
    super.key,
    required this.scenes,
  });

  final List<RelatedScene> scenes;

  @override
  Widget build(BuildContext context) {
    if (scenes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: Text(
            'Related Scenes · ${scenes.length}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: HomeFeedTokens.textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 227,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 19),
            itemCount: scenes.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final scene = scenes[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 128,
                  height: 227,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FeedPicsumImage(
                        url: picsumUrl(scene.imageSeed, 128, 227),
                      ),
                      if (scene.duration != null)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Text(
                            scene.duration!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
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
