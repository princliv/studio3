import 'package:flutter/material.dart';

import '../models/feed_item.dart';
import '../theme/home_feed_tokens.dart';
import '../utils/feed_layout_generator.dart';
import '../widgets/home_feed/home_feed_widgets.dart';
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
  final List<FeedItem> _items = [];
  FeedAvailabilityFilter _filter = FeedAvailabilityFilter.all;
  bool _loadingMore = false;

  List<FeedItem> get _visibleItems {
    if (_filter == FeedAvailabilityFilter.all) return _items;
    return _items.where((item) => item.isAvailable).toList();
  }

  @override
  void initState() {
    super.initState();
    _items.addAll(_generator.nextBatch(_initialBatch));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore) return;
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
        _items.addAll(_generator.nextBatch(_loadMoreCount));
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

  void _openDetail(FeedItem item, {int imageIndex = 0}) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => PieceDetailPage(
          item: item,
          initialImageIndex: imageIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 100;
    final visible = _visibleItems;

    return Scaffold(
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
              child: visible.isEmpty
                  ? Center(
                      child: Text(
                        'No available pieces yet',
                        style: TextStyle(
                          color: HomeFeedTokens.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: HomeFeedTokens.rowGap,
                          ),
                          child: FeedItemCard(
                            item: visible[index],
                            onTap: _openDetail,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
