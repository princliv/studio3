import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/feed_preview_item.dart';
import '../theme/collect_detail_tokens.dart';
import '../widgets/home_feed/home_feed_widgets.dart';
import '../widgets/piece_detail/available_collect_bar.dart';
import '../widgets/piece_detail/collect_artist_row.dart';
import '../widgets/piece_detail/collect_piece_sheet.dart';
import '../widgets/piece_detail/detail_scroll_handoff.dart';
import '../widgets/piece_detail/piece_related_scenes_row.dart';
import '../widgets/piece_detail/piece_series_row.dart';

/// Collect / buy detail for available pieces (Figma 2302-1554).
class AvailablePieceDetailPage extends StatefulWidget {
  const AvailablePieceDetailPage({
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
  State<AvailablePieceDetailPage> createState() =>
      _AvailablePieceDetailPageState();
}

class _AvailablePieceDetailPageState extends State<AvailablePieceDetailPage> {
  bool _following = false;

  FeedPreviewItem get item => widget.item;

  void _onCollect() {
    CollectPieceSheet.show(context, item: item);
  }

  Widget _heroImage() {
    final url = item.heroImageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image_outlined, size: 48),
        ),
      );
    }
    return FeedPicsumImage(
      url: feedPreviewImageUrl(item, imageIndex: widget.initialImageIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collectBarHeight = AvailableCollectBar.totalHeight(context);
    final price = formatCollectPrice(item.priceCents);

    return Scaffold(
      backgroundColor: CollectDetailTokens.background,
      body: Stack(
        children: [
          DetailScrollHandoff(
            tappedIndex: widget.tappedIndex,
            filter: widget.filter,
            onWillAdvance: widget.onWillAdvance,
            collectBarHeight: collectBarHeight,
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: CollectDetailTokens.heroAspectRatio,
                      child: _heroImage(),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 8,
                      left: 8,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: CollectDetailTokens.textPrimary,
                        style: IconButton.styleFrom(
                          backgroundColor: CollectDetailTokens.background
                              .withValues(alpha: 0.7),
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
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: CollectDetailTokens.divider,
                    ),
                    CollectArtistRow(
                      item: item,
                      following: _following,
                      onFollowToggle: () =>
                          setState(() => _following = !_following),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        CollectDetailTokens.horizontalPadding,
                        CollectDetailTokens.sectionGap,
                        CollectDetailTokens.horizontalPadding,
                        8,
                      ),
                      child: Text(
                        item.title,
                        style: GoogleFonts.inter(
                          fontSize: CollectDetailTokens.titleSize,
                          fontWeight: FontWeight.w400,
                          height: CollectDetailTokens.titleLineHeight /
                              CollectDetailTokens.titleSize,
                          color: CollectDetailTokens.textPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CollectDetailTokens.horizontalPadding,
                      ),
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
                                    fontSize: CollectDetailTokens.metaSize,
                                    fontWeight: FontWeight.w400,
                                    height: CollectDetailTokens.metaLineHeight /
                                        CollectDetailTokens.metaSize,
                                    color: CollectDetailTokens.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.dimensions,
                                  style: GoogleFonts.inter(
                                    fontSize: CollectDetailTokens.metaSize,
                                    fontWeight: FontWeight.w400,
                                    height: CollectDetailTokens.metaLineHeight /
                                        CollectDetailTokens.metaSize,
                                    color: CollectDetailTokens.textSecondary,
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
                                fontSize: CollectDetailTokens.linkSize,
                                fontWeight: FontWeight.w400,
                                height: 15.6 / CollectDetailTokens.linkSize,
                                color: CollectDetailTokens.link,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        CollectDetailTokens.horizontalPadding,
                        CollectDetailTokens.sectionGap,
                        CollectDetailTokens.horizontalPadding,
                        CollectDetailTokens.sectionGap,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: CollectDetailTokens.storyCardFill,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            item.story,
                            style: GoogleFonts.inter(
                              fontSize: CollectDetailTokens.storySize,
                              fontWeight: FontWeight.w400,
                              height: CollectDetailTokens.storyLineHeight /
                                  CollectDetailTokens.storySize,
                              color: CollectDetailTokens.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: CollectDetailTokens.divider,
                    ),
                    const SizedBox(height: CollectDetailTokens.sectionGap),
                    PieceSeriesRow(
                      seriesName: item.seriesName,
                      thumbSeeds: item.seriesThumbs,
                    ),
                    const SizedBox(height: 24),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: CollectDetailTokens.divider,
                    ),
                    const SizedBox(height: CollectDetailTokens.sectionGap),
                    PieceRelatedScenesRow(scenes: item.relatedScenes),
                  ],
                ),
              ),
            ],
          ),
          AvailableCollectBar(
            priceDisplay: price,
            onCollect: _onCollect,
          ),
        ],
      ),
    );
  }
}
