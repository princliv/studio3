import 'package:flutter/material.dart';

import '../models/feed_item.dart';
import '../models/feed_row.dart';
import '../services/feed_service.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/feed_layout_generator.dart';
import '../widgets/home_feed/home_feed_widgets.dart';
import '../widgets/studio_loading.dart';
import '../widgets/studio_logo.dart';
import 'artwork_detail_page.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  static const double _loadMoreThreshold = 200;

  final FeedLayoutGenerator _generator = FeedLayoutGenerator();
  final ScrollController _scrollController = ScrollController();
  final List<FeedRowModel> _rows = [];
  final List<FeedItem> _apiItems = [];
  bool _loadingMore = false;
  bool _useApi = false;
  bool _refreshingApi = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _rows.addAll(_generator.nextBatch(16));
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
      final items = await FeedService.instance.getFollowing();
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
        _rows.addAll(_generator.nextBatch(10));
        _loadingMore = false;
      });
    });
  }

  void _openDetailFromCard(String imageUrl, FeedCardData data) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ArtworkDetailPage(
          imageUrl: imageUrl,
          artistName: data.artist.name,
          medium: data.medium,
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
      loading: _refreshingApi || _loadingMore,
      child: Scaffold(
        backgroundColor: HomeFeedTokens.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  HomeFeedTokens.sideMargin,
                  8,
                  HomeFeedTokens.sideMargin,
                  12,
                ),
                child: const Row(
                  children: [
                    StudioHeaderLogo(),
                    Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: _useApi
                    ? RefreshIndicator(
                        onRefresh: _loadFeed,
                        child: GridView.builder(
                            padding: EdgeInsets.fromLTRB(
                              HomeFeedTokens.sideMargin,
                              0,
                              HomeFeedTokens.sideMargin,
                              bottomInset,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _apiItems.length,
                            itemBuilder: (context, index) {
                              final item = _apiItems[index];
                              final url = item.mediaUrl;
                              return GestureDetector(
                                onTap: () => _openApiItem(item),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    HomeFeedTokens.cardRadius,
                                  ),
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
                                        ColoredBox(
                                          color: Colors.grey.shade300,
                                        ),
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
                                              color: Colors.black
                                                  .withValues(alpha: 0.65),
                                              borderRadius:
                                                  BorderRadius.circular(6),
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
                        )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(bottom: bottomInset),
                      itemCount: _rows.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: HomeFeedTokens.rowGap,
                          ),
                          child: FeedRowView(
                            model: _rows[index],
                            onImageTap: _openDetailFromCard,
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
