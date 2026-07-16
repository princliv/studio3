import 'package:flutter/material.dart';

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
import '../widgets/explore/nearby_sellers_row.dart';
import '../widgets/explore/explore_sticky_header.dart';
import '../widgets/feed_skeleton.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  ExploreCategory _category = ExploreCategory.all;
  List<FeedItem> _allItems = [];
  UserProfile? _profile;
  FeedItem? _featured;
  bool _loading = true;
  bool _loadingMore = false;
  String? _nextCursor;
  String _searchQuery = '';
  int _visibleCycleCount = 2;

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

  Future<void> _loadData({bool append = false, bool refresh = false}) async {
    if (append) {
      if (_loadingMore || _nextCursor == null || _nextCursor!.isEmpty) return;
      setState(() => _loadingMore = true);
    } else if (refresh) {
      setState(() => _loading = true);
    } else if (_allItems.isEmpty) {
      setState(() => _loading = true);
    }

    try {
      final page = await FeedService.instance.getExplore(
        cursor: append ? _nextCursor : null,
      );
      UserProfile? profile = _profile;
      if (!append) {
        try {
          profile = await UserService.instance.getMe();
        } catch (_) {
          profile = null;
        }
      }
      if (!mounted) return;
      setState(() {
        if (append) {
          _allItems.addAll(page.items);
        } else {
          _allItems = page.items;
        }
        _nextCursor = page.nextCursor;
        _profile = profile;
        _loading = false;
        _loadingMore = false;
      });
      if (!append) {
        final filtered = _filterItems(_allItems, _category, _searchQuery);
        final featured = ExploreFeaturedRanker.pickFeatured(
          filtered,
          profile: profile,
        );
        if (!mounted) return;
        setState(() {
          _featured = featured;
          _visibleCycleCount = 2;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (!append) {
          _allItems = [];
          _featured = null;
          _nextCursor = null;
        }
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  List<FeedItem> get _sourceItems => _allItems;

  FeedItem? get _effectiveFeatured => _featured;

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
    if (!_scrollController.hasClients || _loadingMore || _loading) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 300) return;

    final maxCycles = ExploreLayoutEngine.cycleCountForItems(_feedItems.length);
    if (_visibleCycleCount < maxCycles &&
        _visibleCycleCount < ExploreLayoutEngine.maxCycles) {
      setState(() {
        _visibleCycleCount =
            (_visibleCycleCount + 2).clamp(0, maxCycles);
      });
      return;
    }

    if (_nextCursor != null && _nextCursor!.isNotEmpty) {
      _loadData(append: true);
    }
  }

  String get _emptyMessage {
    if (_searchQuery.isNotEmpty) {
      return 'No results for "$_searchQuery".';
    }
    return 'Nothing to explore yet.';
  }

  @override
  Widget build(BuildContext context) {
    final showSkeleton = _loading && _allItems.isEmpty;

    return Scaffold(
      backgroundColor: ExploreTokens.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: ExploreTokens.textPrimary,
          onRefresh: () => _loadData(refresh: true),
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
              if (!showSkeleton && _effectiveFeatured != null)
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
              const SliverToBoxAdapter(
                child: NearbySellersRow(),
              ),
              if (showSkeleton)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 48),
                    child: ExploreFeedSkeleton(),
                  ),
                )
              else
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
