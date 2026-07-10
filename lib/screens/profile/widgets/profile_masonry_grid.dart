import 'package:flutter/material.dart';

import '../../../models/feed_item.dart';
import '../../../models/piece_summary.dart';
import '../../../models/post_summary.dart';
import '../../../theme/home_feed_tokens.dart';
import '../../../utils/explore_detail_route.dart';
import '../profile_constants.dart';

class ProfileContentGrid extends StatelessWidget {
  const ProfileContentGrid._({
    required this.items,
    this.onPostTap,
  });

  final List<
      ({
        String? url,
        double height,
        bool forSale,
        String? price,
        bool isVideo,
        PostSummary? post,
      })> items;
  final void Function(PostSummary post)? onPostTap;

  factory ProfileContentGrid.fromPieces(List<PieceSummary> pieces) {
    final heights = [292.0, 168.0, 174.0, 318.0, 182.0, 132.0, 302.0, 156.0];
    final mapped = <
        ({
          String? url,
          double height,
          bool forSale,
          String? price,
          bool isVideo,
          PostSummary? post,
        })>[];
    for (var i = 0; i < pieces.length; i++) {
      final p = pieces[i];
      mapped.add((
        url: p.mediaUrl,
        height: heights[i % heights.length],
        forSale: p.isForSale,
        price: p.priceDisplay,
        isVideo: false,
        post: null,
      ));
    }
    return ProfileContentGrid._(items: mapped);
  }

  factory ProfileContentGrid.fromPosts(
    List<PostSummary> posts, {
    void Function(PostSummary post)? onPostTap,
  }) {
    final heights = [292.0, 168.0, 174.0, 318.0, 182.0, 132.0, 302.0, 156.0];
    final mapped = <
        ({
          String? url,
          double height,
          bool forSale,
          String? price,
          bool isVideo,
          PostSummary? post,
        })>[];
    for (var i = 0; i < posts.length; i++) {
      final p = posts[i];
      final mediaType = p.mediaType?.toLowerCase();
      final isVideo =
          mediaType == 'video' || mediaType == 'reel' || mediaType == 'reels';
      mapped.add((
        url: p.mediaUrl,
        height: heights[i % heights.length],
        forSale: false,
        price: null,
        isVideo: isVideo,
        post: p,
      ));
    }
    return ProfileContentGrid._(items: mapped, onPostTap: onPostTap);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final left = <
        ({
          String? url,
          double height,
          bool forSale,
          String? price,
          bool isVideo,
          PostSummary? post,
        })>[];
    final right = <
        ({
          String? url,
          double height,
          bool forSale,
          String? price,
          bool isVideo,
          PostSummary? post,
        })>[];
    for (var i = 0; i < items.length; i++) {
      if (i.isEven) {
        left.add(items[i]);
      } else {
        right.add(items[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _MasonryColumn(items: left, onPostTap: onPostTap)),
        const SizedBox(width: kProfileGutter),
        Expanded(child: _MasonryColumn(items: right, onPostTap: onPostTap)),
      ],
    );
  }
}

class _MasonryColumn extends StatelessWidget {
  const _MasonryColumn({
    required this.items,
    this.onPostTap,
  });

  final List<
      ({
        String? url,
        double height,
        bool forSale,
        String? price,
        bool isVideo,
        PostSummary? post,
      })> items;
  final void Function(PostSummary post)? onPostTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: kProfileGutter),
          _MasonryTile(
            url: items[i].url,
            height: items[i].height,
            forSale: items[i].forSale,
            price: items[i].price,
            isVideo: items[i].isVideo,
            onTap: items[i].post == null
                ? null
                : () => onPostTap?.call(items[i].post!),
          ),
        ],
      ],
    );
  }
}

class _MasonryTile extends StatelessWidget {
  const _MasonryTile({
    required this.url,
    required this.height,
    this.forSale = false,
    this.price,
    this.isVideo = false,
    this.onTap,
  });

  final String? url;
  final double height;
  final bool forSale;
  final String? price;
  final bool isVideo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url != null && url!.isNotEmpty && !isVideo)
                Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => ColoredBox(
                    color: Colors.grey.shade300,
                    child: Icon(Icons.broken_image_outlined,
                        color: Colors.grey.shade500),
                  ),
                )
              else
                ColoredBox(
                  color: isVideo ? Colors.black : Colors.grey.shade300,
                ),
              if (isVideo)
                Container(
                  color: Colors.black.withValues(alpha: 0.22),
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              if (forSale && price != null)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      price!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Legacy seed-based grid kept for compatibility.
class ProfileMasonryGrid extends StatelessWidget {
  const ProfileMasonryGrid({
    super.key,
    required this.leftItems,
    required this.rightItems,
  });

  final List<({int seed, double h})> leftItems;
  final List<({int seed, double h})> rightItems;

  @override
  Widget build(BuildContext context) {
    return ProfileContentGrid._(
      items: [
        ...leftItems.map(
          (e) => (
            url: null as String?,
            height: e.h,
            forSale: false,
            price: null as String?,
            isVideo: false,
            post: null as PostSummary?,
          ),
        ),
        ...rightItems.map(
          (e) => (
            url: null as String?,
            height: e.h,
            forSale: false,
            price: null as String?,
            isVideo: false,
            post: null as PostSummary?,
          ),
        ),
      ],
    );
  }
}

void openProfileScene(
  BuildContext context,
  List<PostSummary> scenes,
  PostSummary post,
) {
  final item = FeedItem.post(post);
  openExploreDetail(context, item);
}
