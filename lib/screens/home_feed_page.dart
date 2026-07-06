import 'package:flutter/material.dart';

import '../models/feed_item.dart';
import '../models/feed_preview_item.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/feed_layout_generator.dart';
import '../widgets/home_feed/home_feed_widgets.dart';
import '../widgets/studio_loading.dart';
import '../services/feed_service.dart';
import 'artwork_detail_page.dart';
import 'piece_detail_page.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

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

  void _openPreviewDetail(FeedPreviewItem item, {int imageIndex = 0}) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => PieceDetailPage(
          item: item,
          initialImageIndex: imageIndex,
        ),
      ),
    );
  }

  void _openApiItem(FeedItem item) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ArtworkDetailPage(
          imageUrl: item.mediaUrl ?? '',
          artistName: item.authorName,
          medium: item.type == FeedItemType.piece ? item.piece?.medium : null,
          pieceId: item.type == FeedItemType.piece ? item.piece?.id : null,
          postId: item.type == FeedItemType.post ? item.post?.id : null,
          title: item.title,
          forSale: item.isForSale,
          price: item.priceDisplay,
        ),
      ),
    );
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
              FeedHomeHeader(
                filter: _filter,
                onFilterChanged: _onFilterChanged,
                onAddTap: () => Navigator.pushNamed(context, '/post'),
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
                  if (item.isForSale && item.priceDisplay != null)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.priceDisplay!,
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
