import 'package:flutter/material.dart';

import '../models/feed_item.dart';
import '../services/feed_service.dart';
import '../widgets/reels/reel_player_page.dart';
import '../widgets/studio_loading.dart';

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

  Future<void> _loadItems() async {
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      setState(() {
        _items = List<FeedItem>.from(widget.initialItems!);
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final items = await FeedService.instance.getVideoScenes();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadItems();
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

    return StudioLoadingGate(
      loading: _loading,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _items.isEmpty
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
                  onPageChanged: (index) => setState(() => _currentIndex = index),
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
      ),
    );
  }
}
