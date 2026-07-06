import 'package:flutter/material.dart';

import '../../../models/piece_summary.dart';
import '../../../models/post_summary.dart';
import '../../../theme/home_feed_tokens.dart';
import '../profile_constants.dart';

class ProfileContentGrid extends StatelessWidget {
  const ProfileContentGrid._({required this.items});

  final List<({String? url, double height, bool forSale, String? price})> items;

  factory ProfileContentGrid.fromPieces(List<PieceSummary> pieces) {
    final heights = [292.0, 168.0, 174.0, 318.0, 182.0, 132.0, 302.0, 156.0];
    final mapped = <({String? url, double height, bool forSale, String? price})>[];
    for (var i = 0; i < pieces.length; i++) {
      final p = pieces[i];
      mapped.add((
        url: p.mediaUrl,
        height: heights[i % heights.length],
        forSale: p.isForSale,
        price: p.priceDisplay,
      ));
    }
    return ProfileContentGrid._(items: mapped);
  }

  factory ProfileContentGrid.fromPosts(List<PostSummary> posts) {
    final heights = [292.0, 168.0, 174.0, 318.0, 182.0, 132.0, 302.0, 156.0];
    final mapped = <({String? url, double height, bool forSale, String? price})>[];
    for (var i = 0; i < posts.length; i++) {
      final p = posts[i];
      mapped.add((
        url: p.mediaUrl,
        height: heights[i % heights.length],
        forSale: false,
        price: null,
      ));
    }
    return ProfileContentGrid._(items: mapped);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final left = <({String? url, double height, bool forSale, String? price})>[];
    final right = <({String? url, double height, bool forSale, String? price})>[];
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
        Expanded(child: _MasonryColumn(items: left)),
        const SizedBox(width: kProfileGutter),
        Expanded(child: _MasonryColumn(items: right)),
      ],
    );
  }
}

class _MasonryColumn extends StatelessWidget {
  const _MasonryColumn({required this.items});

  final List<({String? url, double height, bool forSale, String? price})> items;

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
  });

  final String? url;
  final double height;
  final bool forSale;
  final String? price;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null && url!.isNotEmpty)
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
              ColoredBox(color: Colors.grey.shade300),
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
        ...leftItems.map((e) => (url: null as String?, height: e.h, forSale: false, price: null as String?)),
        ...rightItems.map((e) => (url: null as String?, height: e.h, forSale: false, price: null as String?)),
      ],
    );
  }
}
