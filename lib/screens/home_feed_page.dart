import 'package:flutter/material.dart';

import '../data/home_feed_dummy.dart';
import '../models/feed_item.dart';
import '../models/feed_pop_result.dart';
import '../models/feed_preview_item.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/explore_detail_route.dart';
import '../utils/feed_layout_generator.dart';
import '../utils/slide_up_page_route.dart';
import '../widgets/home_feed/home_feed_widgets.dart';
import '../widgets/studio_loading.dart';
import '../services/feed_service.dart';
import 'available_piece_detail_page.dart';
import 'piece_detail_page.dart';

class HomeFeedPage extends StatefulWidget {
  /// For You feed — mixed Pieces and Scenes with All / Available filters.
  const HomeFeedPage({super.key, this.onThemeToggle});

  final VoidCallback? onThemeToggle;

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  static const int _initialBatch = 16;
  static const int _loadMoreCount = 10;
  static const double _loadMoreThreshold = 200;

  final FeedLayoutGenerator _generator = FeedLayoutGenerator();
  final ScrollController _scrollController = ScrollController();
  final List<FeedPreviewItem> _previewItems = [];
  final List<FeedItem> _apiItems = [];
  FeedAvailabilityFilter _filter = FeedAvailabilityFilter.all;
  bool _loadingMore = false;
  bool _useApi = false;
  bool _refreshingApi = false;
  bool _didJumpForAdvance = false;

  List<FeedPreviewItem> get _visiblePreviewItems {
    if (_filter == FeedAvailabilityFilter.all) return _previewItems;
    return _previewItems.where((item) => item.isAvailable).toList();
  }

  List<FeedItem> get _visibleApiItems {
    if (_filter == FeedAvailabilityFilter.all) return _apiItems;
    return _apiItems.where((item) => item.isForSale).toList();
  }

  @override
  void initState() {
    super.initState();
    _previewItems.addAll(_generator.nextBatch(_initialBatch));
    _scrollController.addListener(_onScroll);
    _loadFeed();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    if (_refreshingApi) return;
    setState(() => _refreshingApi = true);
    try {
      final items = await FeedService.instance.getForYou();
      if (!mounted) return;
      setState(() {
        _apiItems
          ..clear()
          ..addAll(items);
        _useApi = items.isNotEmpty;
        _refreshingApi = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _useApi = false;
        _refreshingApi = false;
      });
    }
  }

  void _onScroll() {
    if (_loadingMore || _useApi) return;
    final pos = _scrollController.position;
    if (!pos.hasPixels || !pos.hasViewportDimension) return;
    if (pos.pixels >= pos.maxScrollExtent - _loadMoreThreshold) {
      _loadMore();
    }
  }

  void _loadMore() {
    setState(() => _loadingMore = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _previewItems.addAll(_generator.nextBatch(_loadMoreCount));
        _loadingMore = false;
      });
    });
  }

  void _onFilterChanged(FeedAvailabilityFilter filter) {
    if (_filter == filter) return;
    setState(() => _filter = filter);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  double _cardWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width -
        2 * HomeFeedTokens.sideMargin;
  }

  double _cardHeight(FeedPreviewItem item, BuildContext context) {
    return _cardWidth(context) / item.aspectRatioValue;
  }

  double _offsetForIndex(int index, BuildContext context) {
    final visible = _visiblePreviewItems;
    var offset = 0.0;
    for (var i = 0; i < index && i < visible.length; i++) {
      offset += _cardHeight(visible[i], context) + HomeFeedTokens.rowGap;
    }
    return offset;
  }

  void _jumpToFeedIndex(int index) {
    if (!_scrollController.hasClients) return;

    final visible = _visiblePreviewItems;
    if (visible.isEmpty) return;

    final targetIndex = index.clamp(0, visible.length - 1);
    final offset = _offsetForIndex(targetIndex, context);
    final maxExtent = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(offset.clamp(0.0, maxExtent));
    _didJumpForAdvance = true;
  }

  Future<void> _scrollToFeedIndex(int index) async {
    if (!_scrollController.hasClients) return;

    final visible = _visiblePreviewItems;
    if (visible.isEmpty) return;

    var targetIndex = index;
    if (targetIndex >= visible.length) {
      if (targetIndex >= visible.length && !_loadingMore) {
        _loadMore();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
        final updated = _visiblePreviewItems;
        if (targetIndex >= updated.length) {
          targetIndex = updated.length - 1;
        }
      } else {
        targetIndex = visible.length - 1;
      }
    }

    if (targetIndex < 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final offset = _offsetForIndex(targetIndex, context);
      final maxExtent = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        offset.clamp(0.0, maxExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  bool _isCollectible(FeedPreviewItem item) => item.isAvailable;

  Future<void> _openPreviewDetail(
    FeedPreviewItem item, {
    int imageIndex = 0,
  }) async {
    final visible = _visiblePreviewItems;
    final index = visible.indexWhere((i) => i.id == item.id);
    final tappedIndex = index >= 0 ? index : 0;
    _didJumpForAdvance = false;

    final page = _isCollectible(item)
        ? AvailablePieceDetailPage(
            item: item,
            initialImageIndex: imageIndex,
            tappedIndex: tappedIndex,
            filter: _filter,
            onWillAdvance: _jumpToFeedIndex,
          )
        : PieceDetailPage(
            item: item,
            initialImageIndex: imageIndex,
            tappedIndex: tappedIndex,
            filter: _filter,
            onWillAdvance: _jumpToFeedIndex,
          );

    final result = await Navigator.of(context).push<FeedPopResult>(
      SlideUpPageRoute<FeedPopResult>(page: page),
    );

    if (!mounted || result == null) return;
    if (result.filter != _filter) return;
    if (_didJumpForAdvance) return;
    await _scrollToFeedIndex(result.nextIndex);
  }

  void _openApiItem(FeedItem item) {
    openExploreDetail(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 100;

    return StudioLoadingGate(
      loading: _refreshingApi,
      child: Scaffold(
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
                  onMoonTap: widget.onThemeToggle,
                ),
              ),
              Expanded(
                child: _useApi
                    ? _buildApiFeed(bottomInset)
                    : _buildPreviewFeed(bottomInset),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiFeed(double bottomInset) {
    final visible = _visibleApiItems;
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
      onRefresh: _loadFeed,
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(
          HomeFeedTokens.sideMargin,
          0,
          HomeFeedTokens.sideMargin,
          bottomInset,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final item = visible[index];
          final url = item.mediaUrl;
          return GestureDetector(
            onTap: () => _openApiItem(item),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(HomeFeedTokens.cardRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (url != null)
                    Image.network(
                      url,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  else
                    ColoredBox(color: Colors.grey.shade300),
                  if (item.type == FeedItemType.piece)
                    FeedApiCardOverlay(
                      avatarUrl: picsumAvatarUrl(item.id.hashCode),
                      name: item.authorName ?? 'Artist',
                      medium: item.piece?.medium,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewFeed(double bottomInset) {
    final visible = _visiblePreviewItems;
    if (visible.isEmpty) {
      return Center(
        child: Text(
          'No available pieces yet',
          style: TextStyle(
            color: HomeFeedTokens.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: bottomInset),
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
        return Padding(
          padding: const EdgeInsets.only(bottom: HomeFeedTokens.rowGap),
          child: FeedItemCard(
            item: visible[index],
            onTap: _openPreviewDetail,
          ),
        );
      },
    );
  }
}
