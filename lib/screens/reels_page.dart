import 'package:flutter/material.dart';

import '../models/feed_item.dart';
import '../services/feed_service.dart';
import '../widgets/reels/reel_player_page.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({
    super.key,
    this.initialIndex = 0,
    this.initialItems,
  });

  final int initialIndex;
  final List<FeedItem>? initialItems;

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late final PageController _pageController;
  List<FeedItem> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _nextCursor;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _loadItems();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadItems({bool append = false, bool refresh = false}) async {
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty && !append) {
      setState(() {
        _items = List<FeedItem>.from(widget.initialItems!);
        _loading = false;
      });
      return;
    }
    if (append) {
      if (_loadingMore || _nextCursor == null || _nextCursor!.isEmpty) return;
      setState(() => _loadingMore = true);
    } else if (_items.isEmpty || refresh) {
      setState(() => _loading = _items.isEmpty);
    }
    try {
      final page = await FeedService.instance.getVideoScenes(
        cursor: append ? _nextCursor : null,
      );
      if (!mounted) return;
      setState(() {
        if (append) {
          _items.addAll(page.items);
        } else {
          _items = page.items;
        }
        _nextCursor = page.nextCursor;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (!append) _items = [];
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _maybeLoadMore(int index) {
    if (_loadingMore || _nextCursor == null || _nextCursor!.isEmpty) return;
    if (index < _items.length - 2) return;
    _loadItems(append: true);
  }

  Future<void> _onRefresh() async {
    await _loadItems(refresh: true);
    if (!mounted || _items.isEmpty) return;
    final nextIndex = _currentIndex.clamp(0, _items.length - 1);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(nextIndex);
    }
    setState(() => _currentIndex = nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 72;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _loading && _items.isEmpty
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
            )
          : _items.isEmpty
            ? RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.black,
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 240),
                    Center(
                      child: Text(
                        'No scene videos yet',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.black,
                onRefresh: _onRefresh,
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  physics: const PageScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                    _maybeLoadMore(index);
                  },
                  itemBuilder: (context, index) {
                    return ReelPlayerPage(
                      key: ValueKey(_items[index].id),
                      item: _items[index],
                      isActive: index == _currentIndex,
                      bottomOverlayPadding: bottomPadding,
                    );
                  },
                ),
              ),
    );
  }
}
