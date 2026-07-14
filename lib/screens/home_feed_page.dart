import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/feed_item.dart';
import '../models/feed_preview_item.dart' show FeedAvailabilityFilter;
import '../theme/home_feed_tokens.dart';
import '../utils/explore_detail_route.dart';
import '../utils/image_aspect_ratio_resolver.dart';
import '../widgets/home_feed/home_feed_widgets.dart';
import '../services/feed_service.dart';

class HomeFeedPage extends StatefulWidget {
  /// For You feed — mixed Pieces and Scenes with All / Available filters.
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  static const double _loadMoreThreshold = 200;

  final List<FeedItem> _apiItems = [];
  FeedAvailabilityFilter _filter = FeedAvailabilityFilter.all;
  bool _loading = true;
  bool _loadingMore = false;
  String? _nextCursor;
  final ScrollController _scrollController = ScrollController();

  List<FeedItem> get _visibleItems {
    if (_filter == FeedAvailabilityFilter.all) return _apiItems;
    return _apiItems.where((item) => item.isForSale).toList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFeed();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed({bool append = false, bool refresh = false}) async {
    if (_loadingMore) return;
    if (append && (_nextCursor == null || _nextCursor!.isEmpty)) return;

    setState(() {
      if (append) {
        _loadingMore = true;
      } else {
        _loading = true;
      }
    });
    try {
      final page = await FeedService.instance.getForYou(
        cursor: append ? _nextCursor : null,
      );
      if (!mounted) return;
      setState(() {
        if (append) {
          _apiItems.addAll(page.items);
        } else {
          _apiItems
            ..clear()
            ..addAll(page.items);
        }
        _nextCursor = page.nextCursor;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (!append) _apiItems.clear();
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_loadingMore) return;
    if (_nextCursor == null || _nextCursor!.isEmpty) return;
    final pos = _scrollController.position;
    if (!pos.hasPixels || !pos.hasViewportDimension) return;
    if (pos.pixels >= pos.maxScrollExtent - _loadMoreThreshold) {
      _loadFeed(append: true);
    }
  }

  void _onFilterChanged(FeedAvailabilityFilter filter) {
    if (_filter == filter) return;
    setState(() => _filter = filter);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _openApiItem(FeedItem item) {
    openExploreDetail(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 100;

    return Scaffold(
      backgroundColor: HomeFeedTokens.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
              child: FeedHomeHeader(
                filter: _filter,
                onFilterChanged: _onFilterChanged,
                onAddTap: () => Navigator.pushNamed(context, '/post'),
              ),
            ),
            Expanded(child: _buildFeed(bottomInset)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed(double bottomInset) {
    if (_loading && _apiItems.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final visible = _visibleItems;
    if (visible.isEmpty) {
      return Center(
        child: Text(
          _filter == FeedAvailabilityFilter.available
              ? 'No available pieces yet'
              : 'No feed items yet',
          style: TextStyle(
            color: HomeFeedTokens.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadFeed(refresh: true),
      child: MasonryGridView.count(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          HomeFeedTokens.sideMargin,
          0,
          HomeFeedTokens.sideMargin,
          bottomInset,
        ),
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        itemCount: visible.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= visible.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final item = visible[index];
          return _ApiFeedTile(item: item, onTap: () => _openApiItem(item));
        },
      ),
    );
  }
}

/// A "For You" grid tile that sizes itself to the item's real posted
/// aspect ratio (3:4 or 16:9) instead of a fixed shape, so the image shows
/// fully instead of being cropped to a mismatched box.
class _ApiFeedTile extends StatefulWidget {
  const _ApiFeedTile({required this.item, required this.onTap});

  final FeedItem item;
  final VoidCallback onTap;

  @override
  State<_ApiFeedTile> createState() => _ApiFeedTileState();
}

class _ApiFeedTileState extends State<_ApiFeedTile> {
  double _aspectRatio = ImageAspectRatioResolver.portrait3x4;

  @override
  void initState() {
    super.initState();
    _resolveAspectRatio();
  }

  @override
  void didUpdateWidget(covariant _ApiFeedTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.mediaUrl != widget.item.mediaUrl) {
      _resolveAspectRatio();
    }
  }

  void _resolveAspectRatio() {
    final url = widget.item.mediaUrl;
    if (url == null) return;
    final cached = ImageAspectRatioResolver.cached(url);
    if (cached != null) {
      _aspectRatio = cached;
      return;
    }
    ImageAspectRatioResolver.resolve(url).then((ratio) {
      if (mounted) setState(() => _aspectRatio = ratio);
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final url = item.mediaUrl;

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
        child: AspectRatio(
          aspectRatio: _aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url != null)
                CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  memCacheWidth: 480,
                  errorWidget: (context, error, stackTrace) =>
                      ColoredBox(color: Colors.grey.shade300),
                )
              else
                ColoredBox(color: Colors.grey.shade300),
              if (item.type == FeedItemType.piece)
                FeedApiCardOverlay(
                  avatarUrl: item.authorAvatarUrl,
                  name: item.authorName ?? 'Artist',
                  medium: item.piece?.medium,
                  authorUsername: item.authorUsername,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
