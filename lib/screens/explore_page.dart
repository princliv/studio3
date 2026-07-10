import 'package:flutter/material.dart';

import '../data/explore_dummy.dart';
import '../models/explore_feed_block.dart';
import '../models/feed_item.dart';
import '../models/user_profile.dart';
import '../services/feed_service.dart';
import '../services/user_service.dart';
import '../theme/explore_tokens.dart';
import '../utils/explore_category_filter.dart';
import '../utils/explore_detail_route.dart';
import '../utils/explore_featured_ranker.dart';
import '../utils/explore_layout_engine.dart';
import '../widgets/explore/explore_featured_card.dart';
import '../widgets/explore/explore_feed_section.dart';
import '../widgets/explore/explore_near_you_placeholder.dart';
import '../widgets/explore/explore_sticky_header.dart';
import '../widgets/studio_loading.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  ExploreCategory _category = ExploreCategory.pieces;
  List<FeedItem> _allItems = [];
  UserProfile? _profile;
  FeedItem? _featured;
  bool _loading = true;
  String _searchQuery = '';
  int _visibleCycleCount = 2;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final items = await FeedService.instance.getExplore();
      UserProfile? profile;
      try {
        profile = await UserService.instance.getMe();
      } catch (_) {
        profile = null;
      }
      if (!mounted) return;
      _applyItems(items, profile);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allItems = [];
        _featured = null;
        _loading = false;
      });
    }
  }

  void _applyItems(List<FeedItem> items, UserProfile? profile) {
    final filtered = _filterItems(items, _category, _searchQuery);
    final featured = ExploreFeaturedRanker.pickFeatured(filtered, profile: profile);
    setState(() {
      _allItems = items;
      _profile = profile;
      _featured = featured;
      _loading = false;
      _visibleCycleCount = 2;
    });
  }

  List<FeedItem> get _sourceItems =>
      _allItems.isNotEmpty ? _allItems : kExploreFeedDummyItems;

  FeedItem? get _effectiveFeatured {
    if (_category == ExploreCategory.events) return null;
    return _featured ?? kExploreFeaturedDummy;
  }

  List<FeedItem> _filterItems(
    List<FeedItem> items,
    ExploreCategory category,
    String query,
  ) {
    var filtered = filterExploreItems(items, category);
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((item) {
        final title = item.title?.toLowerCase() ?? '';
        final author = item.authorName?.toLowerCase() ?? '';
        final medium = item.type == FeedItemType.piece
            ? item.piece?.medium?.toLowerCase() ?? ''
            : '';
        return title.contains(q) || author.contains(q) || medium.contains(q);
      }).toList();
    }
    return filtered;
  }

  List<FeedItem> get _feedItems {
    final filtered = _filterItems(_sourceItems, _category, _searchQuery);
    final featured = _effectiveFeatured;
    if (featured == null) return filtered;
    return filtered.where((item) => item.id != featured.id).toList();
  }

  List<ExploreFeedBlock> get _visibleBlocks {
    final maxCycles = ExploreLayoutEngine.cycleCountForItems(_feedItems.length);
    final count = _visibleCycleCount.clamp(0, maxCycles);
    return ExploreLayoutEngine.buildBlocks(_feedItems, maxCycles: count);
  }

  void _onCategoryChanged(ExploreCategory category) {
    if (_category == category) return;
    setState(() {
      _category = category;
      _visibleCycleCount = 2;
      final filtered = _filterItems(_allItems, category, _searchQuery);
      _featured = ExploreFeaturedRanker.pickFeatured(
        filtered,
        profile: _profile,
      );
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
      _visibleCycleCount = 2;
      final filtered = _filterItems(_allItems, _category, _searchQuery);
      _featured = ExploreFeaturedRanker.pickFeatured(
        filtered,
        profile: _profile,
      );
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _loadingMore) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 300) return;

    final maxCycles = ExploreLayoutEngine.cycleCountForItems(_feedItems.length);
    if (_visibleCycleCount >= maxCycles) return;
    if (_visibleCycleCount >= ExploreLayoutEngine.maxCycles) return;

    setState(() {
      _loadingMore = true;
      _visibleCycleCount =
          (_visibleCycleCount + 2).clamp(0, maxCycles);
      _loadingMore = false;
    });
  }

  String get _emptyMessage {
    if (_category == ExploreCategory.events) {
      return 'Events are coming soon.';
    }
    if (_searchQuery.isNotEmpty) {
      return 'No results for "$_searchQuery".';
    }
    return 'Nothing to explore yet.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExploreTokens.background,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: StudioLoadingAnimation())
            : RefreshIndicator(
                color: ExploreTokens.textPrimary,
                onRefresh: _loadData,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: ExploreStickyHeader(
                        searchController: _searchController,
                        onSearchChanged: _onSearchChanged,
                        selectedCategory: _category,
                        onCategorySelected: _onCategoryChanged,
                        onFilterTap: () {},
                      ),
                    ),
                    if (_effectiveFeatured != null)
                      SliverToBoxAdapter(
                        child: ExploreFeaturedCard(
                          item: _effectiveFeatured!,
                          onTap: () =>
                              openExploreDetail(context, _effectiveFeatured!),
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: ExploreNearYouPlaceholder(),
                    ),
                    SliverToBoxAdapter(
                      child: ExploreFeedSection(
                        blocks: _visibleBlocks,
                        emptyMessage: _emptyMessage,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
      ),
    );
  }
}
