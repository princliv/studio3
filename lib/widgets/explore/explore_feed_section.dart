import 'package:flutter/material.dart';

import '../../models/explore_feed_block.dart';
import '../../theme/explore_tokens.dart';
import '../../utils/explore_detail_route.dart';
import 'explore_feed_image.dart';

class ExploreFeedTileView extends StatefulWidget {
  const ExploreFeedTileView({
    super.key,
    required this.tile,
    this.borderRadius,
    this.showShadow = true,
  });

  final ExploreFeedTile tile;
  final BorderRadius? borderRadius;
  final bool showShadow;

  @override
  State<ExploreFeedTileView> createState() => _ExploreFeedTileViewState();
}

class _ExploreFeedTileViewState extends State<ExploreFeedTileView> {
  double _scale = 1;

  void _setScale(double value) {
    if (_scale == value) return;
    setState(() => _scale = value);
  }

  BorderRadius get _radius =>
      widget.borderRadius ?? BorderRadius.circular(ExploreTokens.tileRadius);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setScale(0.97),
      onTapUp: (_) {
        _setScale(1);
        openExploreDetail(context, widget.tile.item);
      },
      onTapCancel: () => _setScale(1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: _radius,
            boxShadow: widget.showShadow ? ExploreTokens.cardShadow : null,
          ),
          child: ClipRRect(
            borderRadius: _radius,
            child: AspectRatio(
              aspectRatio: widget.tile.ratio.aspectValue,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExploreFeedImage(
                    url: widget.tile.item.isVideo
                        ? (widget.tile.item.thumbnailUrl ??
                              widget.tile.item.mediaUrl)
                        : widget.tile.item.mediaUrl,
                  ),
                  if (widget.tile.item.isVideo)
                    Container(
                      color: Colors.black.withValues(alpha: 0.18),
                      alignment: Alignment.center,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExploreFeedBlockView extends StatelessWidget {
  const ExploreFeedBlockView({super.key, required this.block});

  final ExploreFeedBlock block;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ExploreTokens.blockGap),
      child: switch (block) {
        ExploreQuadBlock(
          :final topLeft,
          :final bottomLeft,
          :final topRight,
          :final bottomRight,
        ) =>
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExploreFeedTileView(tile: topLeft),
                    const SizedBox(height: ExploreTokens.gutter),
                    ExploreFeedTileView(tile: bottomLeft),
                  ],
                ),
              ),
              const SizedBox(width: ExploreTokens.gutter),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExploreFeedTileView(tile: topRight),
                    const SizedBox(height: ExploreTokens.gutter),
                    ExploreFeedTileView(tile: bottomRight),
                  ],
                ),
              ),
            ],
          ),
        ExploreTwoUpBlock(:final left, :final right) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ExploreFeedTileView(tile: left)),
            const SizedBox(width: ExploreTokens.gutter),
            Expanded(child: ExploreFeedTileView(tile: right)),
          ],
        ),
        ExploreFullWidthBlock(:final tile) => ExploreFeedTileView(tile: tile),
      },
    );
  }
}

class ExploreFeedSection extends StatelessWidget {
  const ExploreFeedSection({
    super.key,
    required this.blocks,
    this.emptyMessage = 'Nothing to explore yet.',
  });

  final List<ExploreFeedBlock> blocks;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ExploreTokens.sideMargin,
          vertical: 48,
        ),
        child: Center(
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: ExploreTokens.textSecondary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ExploreTokens.sideMargin),
      child: Column(
        children: [
          for (final block in blocks) ExploreFeedBlockView(block: block),
        ],
      ),
    );
  }
}
