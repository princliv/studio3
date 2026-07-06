import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/home_feed_dummy.dart';
import '../../models/feed_item.dart';
import '../../theme/home_feed_tokens.dart';

typedef OnFeedItemTap = void Function(FeedItem item, {int imageIndex});

class Studio3DotLogo extends StatelessWidget {
  const Studio3DotLogo({super.key, this.size = 27});

  final double size;

  @override
  Widget build(BuildContext context) {
    final dot = size * 0.22;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: size * 0.38,
            top: 0,
            child: _Dot(diameter: dot),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: _Dot(diameter: dot),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _Dot(diameter: dot),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        color: HomeFeedTokens.textPrimary,
        shape: BoxShape.circle,
      ),
    );
  }
}

class FeedHomeHeader extends StatelessWidget {
  const FeedHomeHeader({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.onAddTap,
    this.onMoonTap,
  });

  final FeedAvailabilityFilter filter;
  final ValueChanged<FeedAvailabilityFilter> onFilterChanged;
  final VoidCallback onAddTap;
  final VoidCallback? onMoonTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
      child: Row(
        children: [
          const Studio3DotLogo(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FilterTab(
                  label: 'All',
                  active: filter == FeedAvailabilityFilter.all,
                  onTap: () => onFilterChanged(FeedAvailabilityFilter.all),
                ),
                const SizedBox(width: 24),
                _FilterTab(
                  label: 'Available',
                  active: filter == FeedAvailabilityFilter.available,
                  onTap: () =>
                      onFilterChanged(FeedAvailabilityFilter.available),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onAddTap,
            icon: const Icon(Icons.add, size: 22),
            color: HomeFeedTokens.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            onPressed: onMoonTap,
            icon: const Icon(Icons.dark_mode_outlined, size: 20),
            color: HomeFeedTokens.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: active
              ? HomeFeedTokens.textPrimary
              : HomeFeedTokens.textSecondary,
          decoration: active ? TextDecoration.underline : null,
          decorationColor: HomeFeedTokens.textPrimary,
          decorationThickness: 1,
        ),
      ),
    );
  }
}

class FeedDotIndicators extends StatelessWidget {
  const FeedDotIndicators({
    super.key,
    required this.count,
    required this.page,
  });

  final int count;
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
  const FeedArtistOverlay({super.key, required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = picsumAvatarUrl(item.artist.avatarSeed);
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
                if (item.isProcess)
                  Text(
                    'Process',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: HomeFeedTokens.textInverse.withValues(alpha: 0.6),
                    ),
                  ),
                Text(
                  item.artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: HomeFeedTokens.textInverse,
                  ),
                ),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: HomeFeedTokens.textInverse.withValues(alpha: 0.6),
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
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

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
              const Color(0xFF231F1B).withValues(alpha: 0.8),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedItemCard extends StatefulWidget {
  const FeedItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final FeedItem item;
  final OnFeedItemTap onTap;

  @override
  State<FeedItemCard> createState() => _FeedItemCardState();
}

class _FeedItemCardState extends State<FeedItemCard> {
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
    return p.round().clamp(0, widget.item.imageCount - 1);
  }

  void _onCardTap() {
    widget.onTap(widget.item, imageIndex: _resolvedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final n = item.imageCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeFeedTokens.sideMargin),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onCardTap,
          borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
            child: AspectRatio(
              aspectRatio: item.aspectRatioValue,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: n,
                    itemBuilder: (context, index) {
                      return FeedPicsumImage(
                        url: feedItemImageUrl(item, imageIndex: index),
                      );
                    },
                  ),
                  const _CardBottomScrim(),
                  FeedArtistOverlay(item: item),
                  if (n > 1)
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
      ),
    );
  }
}
