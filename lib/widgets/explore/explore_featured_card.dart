import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/feed_item.dart';
import '../../theme/explore_tokens.dart';
import '../home_feed/home_feed_widgets.dart';

class ExploreFeaturedCard extends StatelessWidget {
  const ExploreFeaturedCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final FeedItem item;
  final VoidCallback onTap;

  String get _title => item.title ?? 'Untitled';
  String get _author => item.authorName ?? 'Artist';
  String? get _subtitle {
    if (item.type == FeedItemType.piece) {
      return item.piece?.caption ?? item.piece?.medium;
    }
    return item.post?.caption;
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = item.authorAvatarUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ExploreTokens.sideMargin,
        4,
        ExploreTokens.sideMargin,
        ExploreTokens.blockGap,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: ExploreTokens.heroHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ExploreTokens.heroRadius),
            boxShadow: ExploreTokens.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _HeroImage(url: item.mediaUrl),
              const FeedCardBottomScrim(),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ExploreTokens.textPrimary.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Featured for You',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: ExploreTokens.textInverse,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FeedCardArtistStrip(
                      avatarUrl: avatarUrl,
                      name: _author,
                      medium: item.type == FeedItemType.piece
                          ? item.piece?.medium
                          : 'Scene',
                      authorUsername: item.authorUsername,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ExploreTokens.textInverse,
                      ),
                    ),
                    if (_subtitle != null && _subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: ExploreTokens.textInverse.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const ColoredBox(color: ExploreTokens.skeleton);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth:
          (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context))
              .round(),
      errorWidget: (context, error, stackTrace) =>
          const ColoredBox(color: ExploreTokens.skeleton),
    );
  }
}
