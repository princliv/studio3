import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/home_feed_dummy.dart';
import '../../models/feed_row.dart';
import '../../theme/home_feed_tokens.dart';

typedef OnFeedImageTap = void Function(String imageUrl, FeedCardData data);

class FeedDotIndicators extends StatelessWidget {
  const FeedDotIndicators({
    super.key,
    required this.count,
    required this.page,
  });

  final int count;
  /// Fractional carousel page (synced with [PageController.page]) for smooth dot fade while swiping.
  final double page;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final d = (page - i).abs().clamp(0.0, 1.0);
        final opacity = 0.5 + 0.5 * (1.0 - d);
        return Padding(
          padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
          child: Container(
            width: HomeFeedTokens.dotSize,
            height: HomeFeedTokens.dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: opacity.clamp(0.5, 1.0)),
            ),
          ),
        );
      }),
    );
  }
}

class FeedArtistOverlay extends StatelessWidget {
  const FeedArtistOverlay({super.key, required this.data});

  final FeedCardData data;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = picsumAvatarUrl(data.artist.avatarSeed);
    return Positioned(
      left: 8,
      right: 48,
      bottom: 8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipOval(
            child: Image.network(
              avatarUrl,
              width: HomeFeedTokens.avatarSize,
              height: HomeFeedTokens.avatarSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: HomeFeedTokens.avatarSize,
                height: HomeFeedTokens.avatarSize,
                color: Colors.white24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: HomeFeedTokens.artistTextWidth,
                  child: Text(
                    data.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: HomeFeedTokens.textInverse,
                    ),
                  ),
                ),
                SizedBox(
                  width: HomeFeedTokens.artistTextWidth,
                  child: Text(
                    data.medium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: HomeFeedTokens.textInverse.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeedPicsumImage extends StatelessWidget {
  const FeedPicsumImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey.shade400,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade600),
      ),
    );
  }
}

/// Bottom gradient for legibility over artwork.
class _CardBottomScrim extends StatelessWidget {
  const _CardBottomScrim();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 88,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.55),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedImageCarouselCard extends StatefulWidget {
  const _FeedImageCarouselCard({
    required this.height,
    required this.layoutKind,
    required this.showOverlay,
    required this.showDots,
    required this.data,
    required this.onOpenDetail,
  });

  final double height;
  final FeedLayoutKind layoutKind;
  final bool showOverlay;
  final bool showDots;
  final FeedCardData data;
  final void Function(String imageUrl) onOpenDetail;

  @override
  State<_FeedImageCarouselCard> createState() => _FeedImageCarouselCardState();
}

class _FeedImageCarouselCardState extends State<_FeedImageCarouselCard> {
  late final PageController _pageController;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageTick);
  }

  void _onPageTick() {
    final p = _pageController.page;
    if (p != null && mounted) {
      setState(() => _page = p);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageTick);
    _pageController.dispose();
    super.dispose();
  }

  int get _resolvedIndex {
    if (!_pageController.hasClients) return 0;
    final p = _pageController.page;
    if (p == null) return 0;
    return p.round().clamp(0, widget.data.imageCount - 1);
  }

  void _onCardTap() {
    final i = _resolvedIndex;
    widget.onOpenDetail(
      feedCardImageUrl(widget.data, widget.layoutKind, imageIndex: i),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final kind = widget.layoutKind;
    final n = data.imageCount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onCardTap,
        borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: n,
                  itemBuilder: (context, index) {
                    return FeedPicsumImage(
                      url: feedCardImageUrl(data, kind, imageIndex: index),
                    );
                  },
                ),
                if (widget.showOverlay) const _CardBottomScrim(),
                if (widget.showOverlay) FeedArtistOverlay(data: data),
                if (widget.showDots && n > 1)
                  Positioned(
                    right: HomeFeedTokens.dotInset,
                    bottom: HomeFeedTokens.dotInset,
                    child: FeedDotIndicators(count: n, page: _page),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeedRowView extends StatelessWidget {
  const FeedRowView({
    super.key,
    required this.model,
    required this.onImageTap,
  });

  final FeedRowModel model;
  final OnFeedImageTap onImageTap;

  @override
  Widget build(BuildContext context) {
    final kind = model.kind;
    switch (kind) {
      case FeedLayoutKind.a:
      case FeedLayoutKind.d:
        final c = model.cards.single;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: HomeFeedTokens.sideMargin),
          child: _FeedImageCarouselCard(
            height: HomeFeedTokens.tallCardHeight,
            layoutKind: kind,
            showOverlay: true,
            showDots: true,
            data: c,
            onOpenDetail: (url) => onImageTap(url, c),
          ),
        );
      case FeedLayoutKind.e:
        final c = model.cards.single;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: HomeFeedTokens.sideMargin),
          child: _FeedImageCarouselCard(
            height: HomeFeedTokens.shortCardHeight,
            layoutKind: kind,
            showOverlay: true,
            showDots: true,
            data: c,
            onOpenDetail: (url) => onImageTap(url, c),
          ),
        );
      case FeedLayoutKind.b:
        final a = model.cards[0];
        final b = model.cards[1];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: HomeFeedTokens.sideMargin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FeedImageCarouselCard(
                  height: HomeFeedTokens.rowBHeight,
                  layoutKind: kind,
                  showOverlay: true,
                  showDots: true,
                  data: a,
                  onOpenDetail: (url) => onImageTap(url, a),
                ),
              ),
              const SizedBox(width: HomeFeedTokens.gapB),
              Expanded(
                child: _FeedImageCarouselCard(
                  height: HomeFeedTokens.rowBHeight,
                  layoutKind: kind,
                  showOverlay: true,
                  showDots: true,
                  data: b,
                  onOpenDetail: (url) => onImageTap(url, b),
                ),
              ),
            ],
          ),
        );
      case FeedLayoutKind.c:
        final x = model.cards[0];
        final y = model.cards[1];
        final z = model.cards[2];
        Widget smallTile(FeedCardData d) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onImageTap(feedCardImageUrl(d, kind), d),
              borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
                child: FeedPicsumImage(url: feedCardImageUrl(d, kind)),
              ),
            ),
          );
        }

        // Same 10px side inset as other rows; three squares fill the row width (no center float).
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: HomeFeedTokens.sideMargin),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final g = HomeFeedTokens.gapC;
              final tile = (constraints.maxWidth - 2 * g) / 3;
              Widget cell(FeedCardData d) {
                return SizedBox(
                  width: tile,
                  height: tile,
                  child: smallTile(d),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cell(x),
                  SizedBox(width: g),
                  cell(y),
                  SizedBox(width: g),
                  cell(z),
                ],
              );
            },
          ),
        );
    }
  }
}
