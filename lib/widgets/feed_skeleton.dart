import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/explore_tokens.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/image_aspect_ratio_resolver.dart';

/// Wraps a skeleton's placeholder blocks in an animated shimmer sweep —
/// shared by every skeleton below so first-load placeholders read as
/// "loading" rather than a static gray blob.
Widget _shimmer(Widget child, {required Color baseColor}) {
  return Shimmer.fromColors(
    baseColor: baseColor,
    highlightColor: baseColor.withValues(alpha: baseColor.a * 0.4),
    period: const Duration(milliseconds: 1400),
    child: child,
  );
}

/// Two-column placeholder grid for feed first paint.
class FeedGridSkeleton extends StatelessWidget {
  const FeedGridSkeleton({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.padding,
    this.aspectRatio = 0.75,
    this.color,
  });

  final int crossAxisCount;
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final double aspectRatio;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? HomeFeedTokens.textPrimary.withValues(alpha: 0.08);

    return _shimmer(
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: HomeFeedTokens.sideMargin),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: aspectRatio,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
            ),
          );
        },
      ),
      baseColor: fill,
    );
  }
}

/// Single-column placeholder list matching the real "For You" feed card —
/// dynamic-aspect image plus a bottom-left avatar/name overlay — instead of
/// the fixed-aspect two-column [FeedGridSkeleton] shape the feed doesn't
/// actually use.
class FeedListSkeleton extends StatelessWidget {
  const FeedListSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final fill = HomeFeedTokens.textPrimary.withValues(alpha: 0.08);
    final overlayFill = Colors.white.withValues(alpha: 0.5);

    Widget line(double width, double height) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: overlayFill,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    Widget card() {
      return AspectRatio(
        aspectRatio: ImageAspectRatioResolver.portrait3x4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: HomeFeedTokens.avatarSize,
                    height: HomeFeedTokens.avatarSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: overlayFill,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        line(80, 10),
                        const SizedBox(height: 6),
                        line(56, 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _shimmer(
      Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: HomeFeedTokens.sideMargin),
        child: Column(
          children: [
            for (var i = 0; i < itemCount; i++) ...[
              card(),
              if (i != itemCount - 1)
                const SizedBox(height: HomeFeedTokens.rowGap),
            ],
          ],
        ),
      ),
      baseColor: fill,
    );
  }
}

/// Explore-style masonry placeholders (two columns, mixed heights).
class ExploreFeedSkeleton extends StatelessWidget {
  const ExploreFeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final fill = ExploreTokens.textPrimary.withValues(alpha: 0.08);

    Widget tile(double aspect) {
      return AspectRatio(
        aspectRatio: aspect,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(ExploreTokens.tileRadius),
          ),
        ),
      );
    }

    return _shimmer(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: ExploreTokens.sideMargin),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      tile(3 / 4),
                      const SizedBox(height: ExploreTokens.gutter),
                      tile(1),
                    ],
                  ),
                ),
                const SizedBox(width: ExploreTokens.gutter),
                Expanded(
                  child: Column(
                    children: [
                      tile(1),
                      const SizedBox(height: ExploreTokens.gutter),
                      tile(3 / 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ExploreTokens.blockGap),
            tile(16 / 9),
          ],
        ),
      ),
      baseColor: fill,
    );
  }
}

/// Profile tab grid placeholders.
class ProfileGridSkeleton extends StatelessWidget {
  const ProfileGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final fill = HomeFeedTokens.textPrimary.withValues(alpha: 0.08);

    Widget tile(double height) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return _shimmer(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                tile(180),
                const SizedBox(height: 8),
                tile(120),
                const SizedBox(height: 8),
                tile(200),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                tile(140),
                const SizedBox(height: 8),
                tile(220),
                const SizedBox(height: 8),
                tile(130),
              ],
            ),
          ),
        ],
      ),
      baseColor: fill,
    );
  }
}

/// Full-bleed placeholder for Reels' first paint, before the first video is
/// ready — shown in place of a bare spinner over black.
class ReelSkeleton extends StatelessWidget {
  const ReelSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const fill = Color(0x14FFFFFF);
    return _shimmer(
      const DecoratedBox(decoration: BoxDecoration(color: fill)),
      baseColor: fill,
    );
  }
}
