import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/home_feed_dummy.dart';
import '../../data/nav_assets.dart';
import '../../models/feed_preview_item.dart';
import '../../theme/home_feed_tokens.dart';
import '../../utils/profile_navigation.dart';
import '../studio_logo.dart';

typedef OnFeedPreviewTap = void Function(FeedPreviewItem item, {int imageIndex});

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

  static const _headerHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _headerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                StudioLogoPaths.iconBlack,
                width: 29,
                height: 27,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FeedFilterTab(
                label: 'All',
                active: filter == FeedAvailabilityFilter.all,
                onTap: () => onFilterChanged(FeedAvailabilityFilter.all),
              ),
              const SizedBox(width: 24),
              FeedFilterTab(
                label: 'Available',
                active: filter == FeedAvailabilityFilter.available,
                onTap: () =>
                    onFilterChanged(FeedAvailabilityFilter.available),
              ),
            ],
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onAddTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      NavAssets.plusIcon,
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onMoonTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset(
                          NavAssets.moonIcon,
                          width: 19,
                          height: 19,
                        ),
                        Positioned(
                          right: -1,
                          top: -1,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: HomeFeedTokens.textPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
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

class FeedFilterTab extends StatelessWidget {
  const FeedFilterTab({
    super.key,
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

class FeedCardArtistStrip extends StatelessWidget {
  const FeedCardArtistStrip({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.medium,
    this.authorUsername,
  });

  final String avatarUrl;
  final String name;
  final String? medium;
  final String? authorUsername;

  void _onAvatarTap(BuildContext context) {
    openUserProfile(context, authorUsername);
  }

  @override
  Widget build(BuildContext context) {
    final canNavigate =
        authorUsername != null && authorUsername!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: canNavigate ? () => _onAvatarTap(context) : null,
          behavior:
              canNavigate ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
          child: ClipOval(
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
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: HomeFeedTokens.textInverse,
                ),
              ),
              if (medium != null && medium!.isNotEmpty)
                Text(
                  medium!,
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
    );
  }
}

class FeedArtistOverlay extends StatelessWidget {
  const FeedArtistOverlay({super.key, required this.item});

  final FeedPreviewItem item;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      right: 48,
      bottom: 8,
      child: FeedCardArtistStrip(
        avatarUrl: picsumAvatarUrl(item.artist.avatarSeed),
        name: item.artist.name,
        medium: item.medium,
        authorUsername: item.handle,
      ),
    );
  }
}

/// Bottom scrim + artist strip for API grid cards.
class FeedApiCardOverlay extends StatelessWidget {
  const FeedApiCardOverlay({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.medium,
    this.authorUsername,
  });

  final String avatarUrl;
  final String name;
  final String? medium;
  final String? authorUsername;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const FeedCardBottomScrim(),
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: FeedCardArtistStrip(
            avatarUrl: avatarUrl,
            name: name,
            medium: medium,
            authorUsername: authorUsername,
          ),
        ),
      ],
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

class FeedCardBottomScrim extends StatelessWidget {
  const FeedCardBottomScrim({super.key});

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

  final FeedPreviewItem item;
  final OnFeedPreviewTap onTap;

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
                        url: feedPreviewImageUrl(item, imageIndex: index),
                      );
                    },
                  ),
                  const FeedCardBottomScrim(),
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
