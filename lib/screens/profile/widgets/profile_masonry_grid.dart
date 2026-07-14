import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../models/feed_item.dart';
import '../../../models/feed_preview_item.dart';
import '../../../models/piece_summary.dart';
import '../../../models/post_summary.dart';
import '../../../theme/home_feed_tokens.dart';
import '../../../utils/explore_detail_route.dart';
import '../../../utils/slide_up_page_route.dart';
import '../../available_piece_detail_page.dart';
import '../../piece_detail_page.dart';
import '../profile_constants.dart';

class ProfileContentGrid extends StatelessWidget {
  const ProfileContentGrid._({
    required this.items,
    this.onPostTap,
    this.onPieceTap,
    this.onDeletePost,
    this.onDeletePiece,
    this.showOwnerActions = false,
  });

  final List<
      ({
        String? url,
        double height,
        bool forSale,
        String? price,
        bool isVideo,
        PostSummary? post,
        PieceSummary? piece,
      })> items;
  final void Function(PostSummary post)? onPostTap;
  final void Function(PieceSummary piece)? onPieceTap;
  final void Function(PostSummary post)? onDeletePost;
  final void Function(PieceSummary piece)? onDeletePiece;
  final bool showOwnerActions;

  factory ProfileContentGrid.fromPieces(
    List<PieceSummary> pieces, {
    void Function(PieceSummary piece)? onPieceTap,
    void Function(PieceSummary piece)? onDeletePiece,
    bool showOwnerActions = false,
    bool forSaleListing = false,
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
          PieceSummary? piece,
        })>[];
    for (var i = 0; i < pieces.length; i++) {
      final p = pieces[i];
      mapped.add((
        url: p.mediaUrl,
        height: heights[i % heights.length],
        forSale: forSaleListing || p.isForSale,
        price: p.priceDisplay,
        isVideo: false,
        post: null,
        piece: p,
      ));
    }
    return ProfileContentGrid._(
      items: mapped,
      onPieceTap: onPieceTap,
      onDeletePiece: onDeletePiece,
      showOwnerActions: showOwnerActions,
    );
  }

  factory ProfileContentGrid.fromPosts(
    List<PostSummary> posts, {
    void Function(PostSummary post)? onPostTap,
    void Function(PostSummary post)? onDeletePost,
    bool showOwnerActions = false,
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
          PieceSummary? piece,
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
        piece: null,
      ));
    }
    return ProfileContentGrid._(
      items: mapped,
      onPostTap: onPostTap,
      onDeletePost: onDeletePost,
      showOwnerActions: showOwnerActions,
    );
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
          PieceSummary? piece,
        })>[];
    final right = <
        ({
          String? url,
          double height,
          bool forSale,
          String? price,
          bool isVideo,
          PostSummary? post,
          PieceSummary? piece,
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
        Expanded(
          child: _MasonryColumn(
            items: left,
            onPostTap: onPostTap,
            onPieceTap: onPieceTap,
            onDeletePost: onDeletePost,
            onDeletePiece: onDeletePiece,
            showOwnerActions: showOwnerActions,
          ),
        ),
        const SizedBox(width: kProfileGutter),
        Expanded(
          child: _MasonryColumn(
            items: right,
            onPostTap: onPostTap,
            onPieceTap: onPieceTap,
            onDeletePost: onDeletePost,
            onDeletePiece: onDeletePiece,
            showOwnerActions: showOwnerActions,
          ),
        ),
      ],
    );
  }
}

class _MasonryColumn extends StatelessWidget {
  const _MasonryColumn({
    required this.items,
    this.onPostTap,
    this.onPieceTap,
    this.onDeletePost,
    this.onDeletePiece,
    this.showOwnerActions = false,
  });

  final List<
      ({
        String? url,
        double height,
        bool forSale,
        String? price,
        bool isVideo,
        PostSummary? post,
        PieceSummary? piece,
      })> items;
  final void Function(PostSummary post)? onPostTap;
  final void Function(PieceSummary piece)? onPieceTap;
  final void Function(PostSummary post)? onDeletePost;
  final void Function(PieceSummary piece)? onDeletePiece;
  final bool showOwnerActions;

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
            onTap: items[i].post != null
                ? () => onPostTap?.call(items[i].post!)
                : items[i].piece != null
                    ? () => onPieceTap?.call(items[i].piece!)
                    : null,
            onDelete: !showOwnerActions
                ? null
                : items[i].post != null
                    ? () => onDeletePost?.call(items[i].post!)
                    : items[i].piece != null
                        ? () => onDeletePiece?.call(items[i].piece!)
                        : null,
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
    this.onDelete,
  });

  final String? url;
  final double height;
  final bool forSale;
  final String? price;
  final bool isVideo;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  void _showActions(BuildContext context) {
    final delete = onDelete;
    if (delete == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: Color(0xFFE05252)),
          title: const Text(
            'Delete',
            style: TextStyle(color: Color(0xFFE05252), fontWeight: FontWeight.w600),
          ),
          onTap: () {
            Navigator.pop(sheetContext);
            delete();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete != null ? () => _showActions(context) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url != null && url!.isNotEmpty && !isVideo)
                CachedNetworkImage(
                  imageUrl: url!,
                  fit: BoxFit.cover,
                  memCacheWidth: ((MediaQuery.sizeOf(context).width / 2) *
                          MediaQuery.devicePixelRatioOf(context))
                      .round(),
                  errorWidget: (context, error, stackTrace) => ColoredBox(
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
              if (onDelete != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _showActions(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                        size: 16,
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

void openProfileScene(
  BuildContext context,
  List<PostSummary> scenes,
  PostSummary post,
) {
  final item = FeedItem.post(post);
  openExploreDetail(context, item);
}

void openProfilePiece(BuildContext context, PieceSummary piece) {
  final preview = FeedPreviewItem.fromPieceSummary(piece);
  final page = preview.isAvailable
      ? AvailablePieceDetailPage(item: preview)
      : PieceDetailPage(item: preview);
  Navigator.of(context).push<void>(
    SlideUpPageRoute<void>(page: page),
  );
}
