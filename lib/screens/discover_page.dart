import 'package:flutter/material.dart';

import '../models/feed_item.dart';
import '../services/feed_service.dart';
import '../theme/app_theme.dart';
import '../widgets/studio_loading.dart';
import 'artwork_detail_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String _filter = 'All';
  final _filters = ['All', 'Painting', 'Sculpture', 'Photography', 'Digital'];
  List<FeedItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExplore();
  }

  Future<void> _loadExplore() async {
    setState(() => _loading = true);
    try {
      final medium = _filter == 'All' ? null : _filter.toLowerCase();
      final items = await FeedService.instance.getExplore(medium: medium);
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

  void _openItem(FeedItem item) {
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
    return StudioLoadingGate(
      loading: _loading,
      child: Scaffold(
        backgroundColor: AppColors.slate50,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadExplore,
            child: CustomScrollView(
              slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(Icons.search,
                                  size: 20, color: AppColors.slate500),
                              const SizedBox(width: 8),
                              Text('Search',
                                  style: TextStyle(
                                      fontSize: 14, color: AppColors.slate500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    itemBuilder: (context, i) {
                      final f = _filters[i];
                      final active = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f),
                          selected: active,
                          onSelected: (_) {
                            setState(() => _filter = f);
                            _loadExplore();
                          },
                          backgroundColor: AppColors.slate100,
                          selectedColor: AppColors.slate900,
                          labelStyle: TextStyle(
                            color: active ? AppColors.white : AppColors.slate600,
                            fontSize: 13,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (_items.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No pieces found')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final item = _items[i];
                        return GestureDetector(
                          onTap: () => _openItem(item),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (item.mediaUrl != null)
                                  Image.network(item.mediaUrl!, fit: BoxFit.cover)
                                else
                                  Container(color: AppColors.slate200),
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
                                        color: AppColors.slate900
                                            .withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.priceDisplay!,
                                        style: const TextStyle(
                                          color: AppColors.white,
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
                      childCount: _items.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
