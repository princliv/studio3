import 'package:flutter/material.dart';

import '../theme/explore_tokens.dart';
import '../theme/home_feed_tokens.dart';

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

    return GridView.builder(
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

    return Padding(
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

    return Row(
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
    );
  }
}
