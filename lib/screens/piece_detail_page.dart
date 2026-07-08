import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/feed_preview_item.dart';
import '../theme/home_feed_tokens.dart';
import '../widgets/home_feed/home_feed_widgets.dart';
import '../widgets/piece_detail/detail_scroll_handoff.dart';
import '../widgets/piece_detail/piece_action_bar.dart';
import '../widgets/piece_detail/piece_artist_row.dart';
import '../widgets/piece_detail/piece_related_scenes_row.dart';
import '../widgets/piece_detail/piece_series_row.dart';

class PieceDetailPage extends StatefulWidget {
  const PieceDetailPage({
    super.key,
    required this.item,
    this.initialImageIndex = 0,
    this.tappedIndex = 0,
    this.filter = FeedAvailabilityFilter.all,
    this.onWillAdvance,
  });

  final FeedPreviewItem item;
  final int initialImageIndex;
  final int tappedIndex;
  final FeedAvailabilityFilter filter;
  final void Function(int nextIndex)? onWillAdvance;

  @override
  State<PieceDetailPage> createState() => _PieceDetailPageState();
}

class _PieceDetailPageState extends State<PieceDetailPage> {
  bool _liked = false;
  bool _saved = false;
  bool _following = false;

  FeedPreviewItem get item => widget.item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeFeedTokens.detailBackground,
      body: DetailScrollHandoff(
        tappedIndex: widget.tappedIndex,
        filter: widget.filter,
        onWillAdvance: widget.onWillAdvance,
        bottomInset: MediaQuery.paddingOf(context).bottom,
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: item.aspectRatioValue,
                  child: FeedPicsumImage(
                    url: feedPreviewImageUrl(
                      item,
                      imageIndex: widget.initialImageIndex,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  left: 8,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: HomeFeedTokens.textPrimary,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          HomeFeedTokens.detailBackground.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PieceActionBar(
                  liked: _liked,
                  saved: _saved,
                  onLike: () => setState(() => _liked = !_liked),
                  onComment: () {},
                  onShare: () {},
                  onSave: () => setState(() => _saved = !_saved),
                ),
                const Divider(height: 1, color: Color(0xFFE8E5DF)),
                PieceArtistRow(
                  item: item,
                  following: _following,
                  onFollowToggle: () =>
                      setState(() => _following = !_following),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: HomeFeedTokens.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.medium} · ${item.year}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: HomeFeedTokens.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.dimensions,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: HomeFeedTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'View Materials →',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: HomeFeedTokens.sky600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Text(
                    item.story,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: HomeFeedTokens.textPrimary,
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE8E5DF)),
                const SizedBox(height: 16),
                PieceSeriesRow(
                  seriesName: item.seriesName,
                  thumbSeeds: item.seriesThumbs,
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: Color(0xFFE8E5DF)),
                const SizedBox(height: 16),
                PieceRelatedScenesRow(scenes: item.relatedScenes),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
